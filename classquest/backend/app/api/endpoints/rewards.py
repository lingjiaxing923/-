from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin, get_current_student
from app.models.user import User, UserRole
from app.models.points import Reward, Exchange
from app.schemas.reward import RewardCreate, RewardUpdate, RewardResponse, ExchangeCreate, ExchangeResponse

router = APIRouter()

@router.post("", response_model=RewardResponse)
def create_reward(
    reward: RewardCreate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    db_reward = Reward(**reward.dict(), created_by=current_user.id)
    db.add(db_reward)
    db.commit()
    db.refresh(db_reward)
    return db_reward

@router.get("", response_model=list[RewardResponse])
def read_rewards(
    class_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rewards = db.query(Reward).filter(Reward.class_id == class_id).all()
    return rewards

@router.post("/exchange", response_model=ExchangeResponse)
def create_exchange(
    exchange: ExchangeCreate,
    current_user: User = Depends(get_current_student),
    db: Session = Depends(get_db)
):
    # Check if user has enough points
    from sqlalchemy import func, desc
    from app.models.classroom import Season
    season = db.query(Season).filter(Season.is_active == 1).first()
    if not season:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="没有活跃的赛季")
    
    total_points = db.query(func.sum(Reward.points_cost)).filter(
        Reward.user_id == current_user.id,
        Reward.is_revoked == 0
    ).scalar() or 0
    
    if total_points < exchange.points_cost:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="积分不足"
        )
    
    # Check reward stock
    reward = db.query(Reward).filter(Reward.id == exchange.reward_id).first()
    if reward and reward.stock >= 0 and reward.stock < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="商品库存不足"
        )
    
    # Create exchange
    db_exchange = Exchange(**exchange.dict())
    db.add(db_exchange)
    db.commit()
    db.refresh(db_exchange)
    
    # Update stock
    if reward and reward.stock >= 0:
        reward.stock -= 1
    
    return db_exchange

@router.get("/exchanges", response_model=list[ExchangeResponse])
def read_exchanges(
    class_id: int,
    status: str | None = None,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    query = db.query(Exchange).join(Reward).filter(Reward.class_id == class_id)
    if status:
        query = query.filter(Exchange.status == status)
    exchanges = query.all()
    return exchanges

@router.put("/exchanges/{exchange_id}")
def approve_exchange(
    exchange_id: int,
    approved: bool,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    exchange = db.query(Exchange).filter(Exchange.id == exchange_id).first()
    if not exchange:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="兑换记录不存在")
    
    exchange.status = "approved" if approved else "rejected"
    exchange.approved_by = current_user.id
    db.commit()
    return {"status": exchange.status}
