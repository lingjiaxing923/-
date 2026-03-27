from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from typing import List, Dict, Any
from datetime import datetime, timedelta
from app.api.deps import get_db, get_current_admin
from app.models.user import User
from app.models.points import PointsLog
from app.models.appeal import Appeal
from app.models.exam import ExamResult

router = APIRouter()


@router.get("/warnings")
def get_warnings(
    class_id: int,
    warning_type: str = "all",  # all, low_points, zero_points, declining, appeals
    days: int = 7,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取预警信息"""
    warnings = []

    # 计算日期范围
    start_date = datetime.utcnow() - timedelta(days=days)

    if warning_type in ["all", "low_points"]:
        # 低积分预警
        low_points_threshold = 100  # 可配置
        low_points_students = db.query(User).filter(
            User.class_id == class_id,
            User.role == "student",
            (User.total_points < low_points_threshold) | (User.total_points == None)
        ).all()

        for student in low_points_students:
            warnings.append({
                "type": "low_points",
                "severity": "high" if (student.total_points or 0) < 50 else "medium",
                "user_id": student.id,
                "user_name": student.real_name,
                "username": student.username,
                "current_points": student.total_points or 0,
                "threshold": low_points_threshold,
                "message": f"{student.real_name}积分偏低，当前{student.total_points or 0}分",
                "timestamp": datetime.utcnow().isoformat(),
                "suggestions": [
                    "关注该学生课堂表现",
                    "鼓励参与小组活动",
                    "给予适当的加分激励"
                ]
            })

    if warning_type in ["all", "zero_points"]:
        # 连续零分预警
        zero_points_threshold = 5  # 连续几天无积分变化

        # 查找最近几天没有积分变化的学生
        all_students = db.query(User).filter(
            User.class_id == class_id,
            User.role == "student"
        ).all()

        for student in all_students:
            # 查询该学生最近的积分记录
            latest_log = db.query(PointsLog).filter(
                PointsLog.user_id == student.id
            ).order_by(PointsLog.created_at.desc()).first()

            if latest_log:
                days_since_last = (datetime.utcnow() - latest_log.created_at).days
                if days_since_last >= zero_points_threshold:
                    warnings.append({
                        "type": "zero_points",
                        "severity": "medium" if days_since_last < 10 else "high",
                        "user_id": student.id,
                        "user_name": student.real_name,
                        "username": student.username,
                        "days_without_points": days_since_last,
                        "last_points_date": latest_log.created_at.isoformat(),
                        "message": f"{student.real_name}已连续{days_since_last}天无积分变化",
                        "timestamp": datetime.utcnow().isoformat(),
                        "suggestions": [
                            "了解该学生最近的学习状态",
                            "鼓励参与课堂互动",
                            "检查是否有特殊情况"
                        ]
                    })

    if warning_type in ["all", "declining"]:
        # 积分下滑预警
        decline_threshold = 0.2  # 下降20%

        for student in all_students:
            # 查询本周和上周的积分
            this_week_logs = db.query(func.sum(PointsLog.points)).filter(
                and_(
                    PointsLog.user_id == student.id,
                    PointsLog.created_at >= start_date
                )
            ).scalar() or 0

            last_week_start = start_date - timedelta(days=7)
            last_week_logs = db.query(func.sum(PointsLog.points)).filter(
                and_(
                    PointsLog.user_id == student.id,
                    PointsLog.created_at >= last_week_start,
                    PointsLog.created_at < start_date
                )
            ).scalar() or 0

            if last_week_logs > 0 and this_week_logs < last_week_logs:
                decline_rate = (last_week_logs - this_week_logs) / last_week_logs
                if decline_rate >= decline_threshold:
                    warnings.append({
                        "type": "declining",
                        "severity": "medium",
                        "user_id": student.id,
                        "user_name": student.real_name,
                        "username": student.username,
                        "this_week_points": this_week_logs,
                        "last_week_points": last_week_logs,
                        "decline_rate": round(decline_rate * 100, 1),
                        "message": f"{student.real_name}本周积分较上周下降{round(decline_rate * 100, 1)}%",
                        "timestamp": datetime.utcnow().isoformat(),
                        "suggestions": [
                            "与学生沟通了解情况",
                            "分析积分下降原因",
                            "给予鼓励和指导"
                        ]
                    })

    if warning_type in ["all", "appeals"]:
        # 申诉预警
        pending_appeals = db.query(Appeal).filter(
            Appeal.status == "pending"
        ).all()

        if pending_appeals:
            for appeal in pending_appeals:
                student = db.query(User).filter(User.id == appeal.user_id).first()
                if student and student.class_id == class_id:
                    warnings.append({
                        "type": "appeals",
                        "severity": "high",
                        "appeal_id": appeal.id,
                        "user_id": student.id,
                        "user_name": student.real_name,
                        "username": student.username,
                        "appeal_reason": appeal.reason,
                        "appeal_date": appeal.created_at.isoformat(),
                        "message": f"{student.real_name}提交了申诉，待处理",
                        "timestamp": datetime.utcnow().isoformat(),
                        "suggestions": [
                            "及时查看申诉详情",
                            "公正处理学生诉求",
                            "做好沟通解释工作"
                        ]
                    })

    # 按严重程度和类型排序
    severity_order = {"high": 0, "medium": 1, "low": 2}
    warnings.sort(key=lambda x: (severity_order.get(x["severity"], 3), x["type"]))

    return {
        "warnings": warnings,
        "total_count": len(warnings),
        "high_severity_count": len([w for w in warnings if w["severity"] == "high"]),
        "medium_severity_count": len([w for w in warnings if w["severity"] == "medium"]),
        "low_severity_count": len([w for w in warnings if w["severity"] == "low"]),
        "date_range": f"最近{days}天"
    }


@router.get("/statistics")
def get_alert_statistics(
    class_id: int,
    days: int = 7,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取预警统计信息"""
    start_date = datetime.utcnow() - timedelta(days=days)

    # 统计各种预警的数量
    low_points_count = db.query(User).filter(
        User.class_id == class_id,
        User.role == "student",
        (User.total_points < 100) | (User.total_points == None)
    ).count()

    # 连续零分的学生数
    zero_points_count = 0
    all_students = db.query(User).filter(
        User.class_id == class_id,
        User.role == "student"
    ).all()

    for student in all_students:
        latest_log = db.query(PointsLog).filter(
            PointsLog.user_id == student.id
        ).order_by(PointsLog.created_at.desc()).first()

        if latest_log:
            days_since_last = (datetime.utcnow() - latest_log.created_at).days
            if days_since_last >= 5:
                zero_points_count += 1

    # 待处理申诉数
    pending_appeals_count = db.query(Appeal).filter(
        Appeal.status == "pending"
    ).join(User, Appeal.user_id == User.id).filter(
        User.class_id == class_id
    ).count()

    # 本周总积分变化
    this_week_total = db.query(func.sum(PointsLog.points)).filter(
        and_(
            PointsLog.created_at >= start_date
        )
    ).scalar() or 0

    return {
        "low_points_count": low_points_count,
        "zero_points_count": zero_points_count,
        "pending_appeals_count": pending_appeals_count,
        "this_week_total_points": this_week_total,
        "total_students": len(all_students),
        "date_range": f"最近{days}天",
        "timestamp": datetime.utcnow().isoformat()
    }


@router.post("/settings")
def update_alert_settings(
    settings: Dict[str, Any],
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """更新预警设置"""
    # 这里可以将设置保存到数据库或配置文件
    # 目前返回成功响应
    return {
        "message": "预警设置已更新",
        "settings": settings
    }


@router.get("/settings")
def get_alert_settings(
    current_admin: User = Depends(get_current_admin)
):
    """获取预警设置"""
    return {
        "low_points_threshold": 100,
        "zero_points_threshold": 5,  # 连续几天无积分变化
        "decline_threshold": 20,  # 下降百分比
        "alert_enabled": True,
        "notification_enabled": True
    }
