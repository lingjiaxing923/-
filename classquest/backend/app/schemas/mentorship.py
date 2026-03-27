from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class MentorshipCreate(BaseModel):
    mentee_id: int
    ratio: int = 20

class MentorshipResponse(BaseModel):
    id: int
    mentor_id: int
    mentee_id: int
    mentor_name: str
    mentee_name: str
    ratio: int
    status: str
    created_at: datetime
    approved_at: Optional[datetime] = None

    @field_serializer('created_at', when_used='json')
    @field_serializer('approved_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

class MentorshipUpdate(BaseModel):
    status: str  # "approved", "rejected"
