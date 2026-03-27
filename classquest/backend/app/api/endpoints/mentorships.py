from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin, get_current_student
from app.models.user import User, UserRole
from app.models.mentorship import Mentorship, MentorshipStatus
from app.schemas.mentorship import MentorshipCreate, MentorshipResponse, MentorshipUpdate

router = APIRouter()

@router.post("", response_model=MentorshipResponse)
def create_mentorship(
    mentorship: MentorshipCreate,
    current_user: User = Depends(get_current_student),
    db: Session = Depends(get_db)
):
    # Check if already has mentor
    existing = db.query(Mentorship).filter(
        Mentorship.mentee_id == current_user.id,
        Mentorship.status == MentorshipStatus.APPROVED
    ).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="已有师傅"
        )
    
    # Check if mentor exists
    mentor = db.query(User).filter(User.id == mentorship.mentee_id).first()
    if not mentor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="目标用户不存在"
        )
    
    db_mentorship = Mentorship(
        mentor_id=mentorship.mentee_id,
        mentee_id=current_user.id,
        ratio=mentorship.ratio,
        status=MentorshipStatus.PENDING
    )
    db.add(db_mentorship)
    db.commit()
    db.refresh(db_mentorship)
    
    return MentorshipResponse(
        id=db_mentorship.id,
        mentor_id=db_mentorship.mentor_id,
        mentee_id=db_mentorship.mentee_id,
        mentor_name=mentor.real_name,
        mentee_name=current_user.real_name,
        ratio=db_mentorship.ratio,
        status=db_mentorship.status.value,
        created_at=str(db_mentorship.created_at)
    )

@router.get("", response_model=list[MentorshipResponse])
def read_mentorships(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role == UserRole.STUDENT:
        mentorships = db.query(Mentorship).filter(
            Mentorship.mentee_id == current_user.id
        ).order_by(desc(Mentorship.created_at)).all()
    else:
        mentorships = db.query(Mentorship).filter(
            Mentorship.status == MentorshipStatus.PENDING
        ).order_by(desc(Mentorship.created_at)).all()
    
    responses = []
    for ms in mentorships:
        mentor = db.query(User).filter(User.id == ms.mentor_id).first()
        mentee = db.query(User).filter(User.id == ms.mentee_id).first()
        responses.append(MentorshipResponse(
            id=ms.id,
            mentor_id=ms.mentor_id,
            mentee_id=ms.mentee_id,
            mentor_name=mentor.real_name if mentor else "",
            mentee_name=mentee.real_name if mentee else "",
            ratio=ms.ratio,
            status=ms.status.value,
            created_at=str(ms.created_at),
            approved_at=str(ms.approved_at) if ms.approved_at else None
        ))
    
    return responses

@router.put("/{mentorship_id}")
def update_mentorship(
    mentorship_id: int,
    mentorship_update: MentorshipUpdate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    mentorship = db.query(Mentorship).filter(Mentorship.id == mentorship_id).first()
    if not mentorship:
        raise HTTPException(status_code=404, detail="师徒关系不存在")
    
    if mentorship_update.status == "approved":
        mentorship.status = MentorshipStatus.APPROVED
        # Set approval time
        from datetime import datetime
        mentorship.approved_at = datetime.utcnow()
    elif mentorship_update.status == "rejected":
        mentorship.status = MentorshipStatus.REJECTED
    
    db.commit()
    return {"status": mentorship.status.value}
