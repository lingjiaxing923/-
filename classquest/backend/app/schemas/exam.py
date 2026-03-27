from pydantic import BaseModel, field_serializer
from datetime import datetime

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class ExamResultCreate(BaseModel):
    exam_name: str
    score: int
    rank: int
    season_id: int

class ExamResultResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    exam_name: str
    score: int
    rank: int
    season_id: int
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)
