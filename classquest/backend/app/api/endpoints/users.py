from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import pandas as pd
import io

from app.db import get_db
from app.core.security import get_current_user, require_role, get_current_admin
from app.models.user import User as UserModel, UserRole
from app.schemas.user import User, UserCreate

router = APIRouter()

@router.get("", response_model=List[User])
def read_users(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.MANAGER])),
    db: Session = Depends(get_db)
):
    users = db.query(UserModel).offset(skip).limit(limit).all()
    return users

@router.get("/{user_id}", response_model=User)
def read_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.MANAGER])),
    db: Session = Depends(get_db)
):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")
    return user

@router.post("/import")
def import_students(
    file: bytes,
    class_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    # Parse Excel file
    try:
        df = pd.read_excel(io.BytesIO(file))
        created_count = 0
        
        for _, row in df.iterrows():
            # Check required columns
            if '姓名' not in df.columns or '用户名' not in df.columns:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Excel文件必须包含'姓名'和'用户名'列"
                )
            
            # Create user with default password
            db_user = UserModel(
                username=row['用户名'],
                password_hash='$2b$12$EixZaYVK1fsbw1ZfbX3OUeZbQp5b1/8Tj2pYh8vK5b1/8',  # Default: password123
                real_name=row['姓名'],
                role=UserRole.STUDENT,
                class_id=class_id,
            )
            db.add(db_user)
            created_count += 1
        
        db.commit()
        return {"message": f"成功导入 {created_count} 名学生"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"导入失败: {str(e)}"
        )
