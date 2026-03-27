from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import List, Optional

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin, get_current_manager
from app.models.user import User, UserRole
from app.models.points import Rule, PointsLog
from app.models.classroom import Season
from app.schemas.points import RuleCreate, RuleUpdate, RuleResponse, PointsLogResponse, LeaderboardEntry, PointsOperation

router = APIRouter()

@router.post("/rules", response_model=RuleResponse)
def create_rule(
    rule: RuleCreate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    db_rule = Rule(**rule.dict(), created_by=current_user.id)
    db.add(db_rule)
    db.commit()
    db.refresh(db_rule)
    return db_rule

@router.get("/rules", response_model=List[RuleResponse])
def read_rules(
    class_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role == UserRole.MANAGER:
        rules = db.query(Rule).filter(Rule.class_id == class_id, Rule.subject_id == current_user.subject_id).all()
    else:
        rules = db.query(Rule).filter(Rule.class_id == class_id).all()
    return rules

@router.post("/add", response_model=PointsLogResponse)
def add_points(
    operation: PointsOperation,
    current_user: User = Depends(get_current_manager),
    db: Session = Depends(get_db)
):
    # Get user and season
    target_user = db.query(User).filter(User.id == operation.user_id).first()
    if not target_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")
    
    season = db.query(Season).filter(Season.is_active == 1).first()
    if not season:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="没有活跃的赛季")
    
    # Create points log
    points_log = PointsLog(
        user_id=operation.user_id,
        group_id=target_user.group_id,
        rule_id=operation.rule_id,
        season_id=season.id,
        points=abs(operation.points),
        operator_id=current_user.id,
        reason=operation.reason
    )
    db.add(points_log)
    db.commit()
    db.refresh(points_log)
    
    return PointsLogResponse(
        id=points_log.id,
        user_id=points_log.user_id,
        user_name=target_user.real_name,
        group_id=points_log.group_id,
        rule_id=points_log.rule_id,
        season_id=points_log.season_id,
        points=points_log.points,
        operator_id=points_log.operator_id,
        operator_name=current_user.real_name,
        reason=points_log.reason,
        is_revoked=bool(points_log.is_revoked),
        created_at=str(points_log.created_at)
    )

@router.post("/subtract", response_model=PointsLogResponse)
def subtract_points(
    operation: PointsOperation,
    current_user: User = Depends(get_current_manager),
    db: Session = Depends(get_db)
):
    target_user = db.query(User).filter(User.id == operation.user_id).first()
    if not target_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")
    
    season = db.query(Season).filter(Season.is_active == 1).first()
    if not season:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="没有活跃的赛季")
    
    points_log = PointsLog(
        user_id=operation.user_id,
        group_id=target_user.group_id,
        rule_id=operation.rule_id,
        season_id=season.id,
        points=-abs(operation.points),
        operator_id=current_user.id,
        reason=operation.reason
    )
    db.add(points_log)
    db.commit()
    db.refresh(points_log)
    
    return PointsLogResponse(
        id=points_log.id,
        user_id=points_log.user_id,
        user_name=target_user.real_name,
        group_id=points_log.group_id,
        rule_id=points_log.rule_id,
        season_id=points_log.season_id,
        points=points_log.points,
        operator_id=points_log.operator_id,
        operator_name=current_user.real_name,
        reason=points_log.reason,
        is_revoked=bool(points_log.is_revoked),
        created_at=str(points_log.created_at)
    )

@router.get("/logs", response_model=List[PointsLogResponse])
def read_points_logs(
    user_id: Optional[int] = None,
    class_id: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if user_id:
        logs = db.query(PointsLog).filter(PointsLog.user_id == user_id).order_by(desc(PointsLog.created_at)).all()
    elif class_id:
        logs = db.query(PointsLog).join(User).filter(User.class_id == class_id).order_by(desc(PointsLog.created_at)).all()
    else:
        logs = db.query(PointsLog).filter(PointsLog.user_id == current_user.id).order_by(desc(PointsLog.created_at)).all()
    return logs

@router.post("/logs/{log_id}/revoke")
def revoke_log(
    log_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    log = db.query(PointsLog).filter(PointsLog.id == log_id).first()
    if not log:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="积分记录不存在")
    
    log.is_revoked = 1
    db.commit()
    return {"status": "revoked"}

@router.get("/leaderboard")
def read_leaderboard(
    class_id: int,
    db: Session = Depends(get_db)
):
    season = db.query(Season).filter(Season.is_active == 1).first()
    if not season:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="没有活跃的赛季")
    
    results = db.query(
        User.id,
        User.real_name,
        func.sum(PointsLog.points).label("total_points")
    ).join(PointsLog).filter(
        User.class_id == class_id,
        PointsLog.season_id == season.id,
        PointsLog.is_revoked == 0
    ).group_by(User.id).order_by(desc("total_points")).all()
    
    return [
        LeaderboardEntry(
            user_id=r[0],
            real_name=r[1],
            points=r[2] or 0,
            rank=index + 1
        )
        for index, r in enumerate(results)
    ]
