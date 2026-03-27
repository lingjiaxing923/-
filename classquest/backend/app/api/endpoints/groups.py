from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.api.deps import get_db, get_current_admin, get_current_user
from app.models.user import User, UserRole
from app.models.classroom import Group

router = APIRouter()


@router.get("")
def get_groups(
    class_id: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取小组列表"""
    query = db.query(Group)
    if current_user.role != UserRole.ADMIN:
        query = query.filter(Group.class_id == current_user.class_id)
    if class_id:
        query = query.filter(Group.class_id == class_id)

    groups = query.all()
    result = []

    for group in groups:
        # 获取小组成员及其积分
        members = db.query(User).filter(User.group_id == group.id).all()
        total_points = sum([user.total_points or 0 for user in members])
        member_list = [
            {
                "id": member.id,
                "name": member.real_name,
                "username": member.username,
                "points": member.total_points or 0
            }
            for member in members
        ]

        result.append({
            "id": group.id,
            "name": group.name,
            "class_id": group.class_id,
            "member_count": len(members),
            "total_points": total_points,
            "members": member_list
        })

    # 获取用户所在的小组
    my_group = None
    if current_user.group_id:
        group = db.query(Group).filter(Group.id == current_user.group_id).first()
        if group:
            members = db.query(User).filter(User.group_id == group.id).all()
            total_points = sum([user.total_points or 0 for user in members])
            member_list = [
                {
                    "id": member.id,
                    "name": member.real_name,
                    "username": member.username,
                    "points": member.total_points or 0
                }
                for member in members
            ]

            my_group = {
                "id": group.id,
                "name": group.name,
                "class_id": group.class_id,
                "member_count": len(members),
                "total_points": total_points,
                "members": member_list
            }

    return {
        "groups": result,
        "my_group": my_group
    }


@router.post("")
def create_group(
    name: str,
    class_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """创建小组（仅班主任）"""
    group = Group(name=name, class_id=class_id)
    db.add(group)
    db.commit()
    db.refresh(group)
    return {"message": "小组创建成功", "group_id": group.id}


@router.put("/{group_id}")
def update_group(
    group_id: int,
    name: Optional[str] = None,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """更新小组（仅班主任）"""
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="小组不存在")

    if name:
        group.name = name

    db.commit()
    return {"message": "小组更新成功"}


@router.post("/{group_id}/members")
def add_member(
    group_id: int,
    user_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """添加小组成员（仅班主任）"""
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="小组不存在")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    if user.group_id:
        raise HTTPException(status_code=400, detail="用户已属于其他小组")

    user.group_id = group_id
    db.commit()

    return {"message": "成员添加成功"}


@router.delete("/{group_id}/members/{user_id}")
def remove_member(
    group_id: int,
    user_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """移除小组成员（仅班主任）"""
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="小组不存在")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    if user.group_id != group_id:
        raise HTTPException(status_code=400, detail="用户不属于该小组")

    user.group_id = None
    db.commit()

    return {"message": "成员移除成功"}


@router.delete("/{group_id}")
def delete_group(
    group_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """删除小组（仅班主任）"""
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="小组不存在")

    # 将小组成员的group_id设为null
    db.query(User).filter(User.group_id == group_id).update({"group_id": None})

    db.delete(group)
    db.commit()

    return {"message": "小组删除成功"}
