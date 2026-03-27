from pydantic import BaseModel, field_serializer
from typing import Optional, List
from datetime import datetime

class ClassBase(BaseModel):
    name: str
    season_id: int

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class ClassCreate(ClassBase):
    pass

class ClassUpdate(BaseModel):
    name: Optional[str] = None
    season_id: Optional[int] = None

class ClassResponse(ClassBase):
    id: int
    admin_id: int
    created_at: datetime
    updated_at: datetime

    @field_serializer('created_at', when_used='json')
    @field_serializer('updated_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True

class GroupBase(BaseModel):
    class_id: int
    name: str

class GroupCreate(GroupBase):
    member_ids: List[int] = []

class GroupUpdate(BaseModel):
    name: Optional[str] = None
    member_ids: Optional[List[int]] = None

class GroupResponse(GroupBase):
    id: int
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True

class SeasonBase(BaseModel):
    name: str
    start_date: str
    end_date: Optional[str] = None
    is_active: bool = True

class SeasonCreate(SeasonBase):
    pass

class SeasonResponse(SeasonBase):
    id: int
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True

class SubjectBase(BaseModel):
    name: str

class SubjectCreate(SubjectBase):
    pass

class SubjectResponse(SubjectBase):
    id: int
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True
