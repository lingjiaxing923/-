from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin, get_current_student
from app.models.user import User, UserRole
from app.models.appeal import Appeal
from app.schemas.appeal import AppealCreate, AppealResponse, AppealUpdate

router = APIRouter()

@router.post("", response_model=AppealResponse)
def create_appeal(
    appeal: AppealCreate,
    current_user: User = Depends(get_current_student),
    db: Session = Depends(get_db)
):
    db_appeal = Appeal(**appeal.dict(), user_id=current_user.id, status="pending")
    db.add(db_appeal)
    db.commit()
    db.refresh(db_appeal)
    
    # Fetch related data for response
    db_appeal.user = current_user
    db_appeal.points_log = db.query(Appeal.points_log_id).first()
    
    return AppealResponse(
        id=db_appeal.id,
        user_id=db_appeal.user_id,
        user_name=current_user.real_name,
        points_log_id=db_appeal.points_log_id,
        reason=db_appeal.reason,
        status=db_appeal.status.value,
        created_at=str(db_appeal.created_at)
    )

@router.get("", response_model=list[AppealResponse])
def read_appeals(
    class_id: int | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role == UserRole.STUDENT:
        appeals = db.query(Appeal).filter(Appeal.user_id == current_user.id).all()
    else:
        appeals = db.query(Appeal).all()
    return appeals

@router.put("/{appeal_id}")
def process_appeal(
    appeal_id: int,
    appeal_update: AppealUpdate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    appeal = db.query(Appeal).filter(Appeal.id == appeal_id).first()
    if not appeal:
        raise HTTPException(status_code=404, detail="申诉不存在")
    
    appeal.result = appeal_update.result
    appeal.status = "processed"
    appeal.response = appeal_update.response
    appeal.processed_by = current_user.id
    
    db.commit()
    return {"status": "processed"}
