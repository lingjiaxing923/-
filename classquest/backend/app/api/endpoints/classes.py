from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin
from app.models.user import User, UserRole
from app.models.classroom import Class, Group, Season, Subject
from app.schemas.classroom import ClassCreate, ClassUpdate, ClassResponse, GroupCreate, GroupUpdate, GroupResponse

router = APIRouter()

@router.post("", response_model=ClassResponse)
def create_class(
    class_: ClassCreate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    db_class = Class(**class_.dict(), admin_id=current_user.id)
    db.add(db_class)
    db.commit()
    db.refresh(db_class)
    return db_class

@router.get("", response_model=list[ClassResponse])
def read_classes(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role == UserRole.ADMIN:
        classes = db.query(Class).filter(Class.admin_id == current_user.id).all()
    else:
        classes = db.query(Class).filter(Class.id == current_user.class_id).all()
    return classes

@router.get("/{class_id}", response_model=ClassResponse)
def read_class(
    class_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_class = db.query(Class).filter(Class.id == class_id).first()
    if not db_class:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="班级不存在")
    return db_class

@router.put("/{class_id}", response_model=ClassResponse)
def update_class(
    class_id: int,
    class_update: ClassUpdate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    db_class = db.query(Class).filter(Class.id == class_id).first()
    if not db_class:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="班级不存在")
    
    for key, value in class_update.dict(exclude_unset=True).items():
        setattr(db_class, key, value)
    
    db.commit()
    db.refresh(db_class)
    return db_class

@router.post("/groups", response_model=GroupResponse)
def create_group(
    group: GroupCreate,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    db_group = Group(class_id=group.class_id, name=group.name)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    
    # Add members to group
    if group.member_ids:
        for member_id in group.member_ids:
            user = db.query(User).filter(User.id == member_id).first()
            if user:
                user.group_id = db_group.id
    
    db.commit()
    return db_group

@router.get("/{class_id}/groups", response_model=list[GroupResponse])
def read_groups(
    class_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    groups = db.query(Group).filter(Group.class_id == class_id).all()
    return groups

@router.get("/{class_id}/students")
def read_class_students(
    class_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    students = db.query(User).filter(User.class_id == class_id).all()
    return students
