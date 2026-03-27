from pydantic import BaseModel, EmailStr, field_serializer
from typing import Optional
from datetime import datetime
from app.models.user import UserRole

class UserBase(BaseModel):
    username: str
    real_name: str
    role: UserRole

class UserCreate(UserBase):
    password: str
    class_id: Optional[int] = None
    group_id: Optional[int] = None
    subject_id: Optional[int] = None

class UserUpdate(BaseModel):
    real_name: Optional[str] = None
    class_id: Optional[int] = None
    group_id: Optional[int] = None
    subject_id: Optional[int] = None

class UserLogin(BaseModel):
    username: str
    password: str

class User(UserBase):
    id: int
    class_id: Optional[int] = None
    group_id: Optional[int] = None
    subject_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    @field_serializer('created_at', when_used='json')
    @field_serializer('updated_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return value.isoformat()

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
    role: Optional[UserRole] = None
