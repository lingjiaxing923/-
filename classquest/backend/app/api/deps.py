from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db, SessionLocal
from app.core.security import get_current_user
from app.models.user import User, UserRole

# Re-export get_db for convenience
__all__ = ['get_db', 'get_current_user', 'get_current_active_user', 'get_current_admin', 'get_current_manager', 'get_current_teacher']

def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    return current_user

def get_current_admin(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前登录的班主任"""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="权限不足，需要班主任权限"
        )
    return current_user

def get_current_manager(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前登录的科代表"""
    if current_user.role not in [UserRole.ADMIN, UserRole.MANAGER]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="权限不足，需要科代表或班主任权限"
        )
    return current_user

def get_current_teacher(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前登录的教师"""
    if current_user.role not in [UserRole.ADMIN, UserRole.MANAGER, UserRole.TEACHER]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="权限不足，需要教师、科代表或班主任权限"
        )
    return current_user
