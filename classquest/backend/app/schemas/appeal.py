from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class AppealCreate(BaseModel):
    points_log_id: int
    reason: str

class AppealResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    points_log_id: int
    reason: str
    status: str
    result: Optional[str] = None
    response: Optional[str] = None
    processed_by: Optional[int] = None
    processed_at: Optional[datetime] = None
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    @field_serializer('processed_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

class AppealUpdate(BaseModel):
    result: str  # "approved", "rejected"
    response: str | None = None
