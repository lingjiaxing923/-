from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.models.notification import Notification, NotificationType
from pydantic import BaseModel

router = APIRouter()


# Schemas
class NotificationCreate(BaseModel):
    user_id: int
    type: str
    title: str
    content: str


class NotificationUpdate(BaseModel):
    is_read: bool


@router.get("")
def get_notifications(
    unread_only: bool = False,
    limit: int = 20,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取当前用户的通知列表"""
    query = db.query(Notification).filter(
        Notification.user_id == current_user.id
    )

    if unread_only:
        query = query.filter(Notification.is_read == False)

    total_count = query.count()
    notifications = query.order_by(
        Notification.created_at.desc()
    ).offset(offset).limit(limit).all()

    result = []
    for notification in notifications:
        result.append({
            "id": notification.id,
            "type": notification.type.value,
            "title": notification.title,
            "content": notification.content,
            "is_read": notification.is_read,
            "created_at": notification.created_at.isoformat(),
            "read_at": notification.read_at.isoformat() if notification.read_at else None
        })

    return {
        "notifications": result,
        "total_count": total_count,
        "unread_count": db.query(Notification).filter(
            Notification.user_id == current_user.id,
            Notification.is_read == False
        ).count()
    }


@router.get("/unread-count")
def get_unread_count(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取未读通知数量"""
    count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()

    return {"unread_count": count}


@router.post("/{notification_id}/read")
def mark_as_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """标记通知为已读"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="通知不存在")

    notification.is_read = True
    notification.read_at = datetime.utcnow()
    db.commit()

    return {"message": "通知已标记为已读"}


@router.post("/mark-all-read")
def mark_all_as_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """标记所有通知为已读"""
    notifications = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).all()

    for notification in notifications:
        notification.is_read = True
        notification.read_at = datetime.utcnow()

    db.commit()

    return {
        "message": "所有通知已标记为已读",
        "count": len(notifications)
    }


@router.delete("/{notification_id}")
def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """删除通知"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="通知不存在")

    db.delete(notification)
    db.commit()

    return {"message": "通知已删除"}


@router.post("/send")
def send_notification(
    notification: NotificationCreate,
    db: Session = Depends(get_db)
):
    """发送通知（供其他端点调用）"""
    # 验证用户是否存在
    user = db.query(User).filter(User.id == notification.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    # 验证通知类型
    try:
        notification_type = NotificationType(notification.type)
    except ValueError:
        raise HTTPException(status_code=400, detail="无效的通知类型")

    # 创建通知
    new_notification = Notification(
        user_id=notification.user_id,
        type=notification_type,
        title=notification.title,
        content=notification.content
    )

    db.add(new_notification)
    db.commit()
    db.refresh(new_notification)

    # 通过WebSocket发送通知
    try:
        from app.api.endpoints.websocket import manager
        notification_message = {
            "type": "notification",
            "data": {
                "notification_id": new_notification.id,
                "title": new_notification.title,
                "content": new_notification.content,
                "notification_type": new_notification.type.value
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        import asyncio
        asyncio.create_task(manager.send_to_user(notification.user_id, notification_message))
    except:
        pass  # WebSocket发送失败不影响通知创建

    return {
        "message": "通知发送成功",
        "notification_id": new_notification.id
    }


@router.post("/broadcast")
def broadcast_notification(
    title: str,
    content: str,
    class_id: Optional[int] = None,
    role: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """广播通知到多个用户"""
    query = db.query(User)

    if class_id:
        query = query.filter(User.class_id == class_id)
    if role:
        from app.models.user import UserRole
        try:
            role_enum = UserRole(role)
            query = query.filter(User.role == role_enum)
        except ValueError:
            pass

    users = query.all()

    count = 0
    for user in users:
        notification = Notification(
            user_id=user.id,
            type=NotificationType.SYSTEM_ANNOUNCEMENT,
            title=title,
            content=content
        )
        db.add(notification)
        count += 1

    db.commit()

    return {
        "message": f"已向{count}个用户发送通知",
        "count": count
    }


# 便捷函数：创建各种类型的通知
def create_exchange_notification(db: Session, user_id: int, approved: bool, item_name: str = ""):
    """创建兑换结果通知"""
    title = "兑换申请已通过" if approved else "兑换申请已拒绝"
    content = f"您的{'商品' if item_name else '兑换'}申请已{'通过' if approved else '被拒绝'}。"
    if item_name:
        content += f" 商品：{item_name}"

    notification = Notification(
        user_id=user_id,
        type=NotificationType.EXCHANGE_APPROVED if approved else NotificationType.EXCHANGE_REJECTED,
        title=title,
        content=content
    )
    db.add(notification)
    db.commit()
    return notification


def create_appeal_notification(db: Session, user_id: int, approved: bool, result: str = ""):
    """创建申诉处理结果通知"""
    title = "申诉已处理"
    content = f"您的申诉已{'通过' if approved else '被拒绝'}。"
    if result:
        content += f" 处理结果：{result}"

    notification = Notification(
        user_id=user_id,
        type=NotificationType.APPEAL_PROCESSED,
        title=title,
        content=content
    )
    db.add(notification)
    db.commit()
    return notification


def create_mentorship_notification(db: Session, user_id: int, approved: bool, partner_name: str = ""):
    """创建师徒结对结果通知"""
    title = "师徒结对申请已通过" if approved else "师徒结对申请已拒绝"
    content = f"您的师徒结对申请已{'通过' if approved else '被拒绝'}。"
    if partner_name:
        content += f" 结对对象：{partner_name}"

    notification = Notification(
        user_id=user_id,
        type=NotificationType.MENTORSHIP_APPROVED if approved else NotificationType.MENTORSHIP_REJECTED,
        title=title,
        content=content
    )
    db.add(notification)
    db.commit()
    return notification


def create_warning_notification(db: Session, user_id: int, warning_type: str, message: str):
    """创建预警通知"""
    notification = Notification(
        user_id=user_id,
        type=NotificationType.POINTS_WARNING,
        title=f"积分预警：{warning_type}",
        content=message
    )
    db.add(notification)
    db.commit()
    return notification
