from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class RuleBase(BaseModel):
    name: str
    base_points: int
    type: str  # "positive" or "negative"
    daily_limit: int = 0
    applicable_scope: list = []
    subject_id: Optional[int] = None
    class_id: int

class RuleCreate(RuleBase):
    pass

class RuleUpdate(BaseModel):
    name: Optional[str] = None
    base_points: Optional[int] = None
    daily_limit: Optional[int] = None
    applicable_scope: Optional[list] = None

class RuleResponse(RuleBase):
    id: int
    created_by: int
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True

class PointsLogResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    group_id: Optional[int]
    group_name: Optional[str]
    rule_id: int
    rule_name: str
    season_id: int
    points: int
    operator_id: int
    operator_name: str
    reason: Optional[str]
    is_revoked: bool
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

class LeaderboardEntry(BaseModel):
    user_id: int
    real_name: str
    points: int
    rank: int

class PointsOperation(BaseModel):
    user_id: int
    rule_id: int
    points: int
    reason: Optional[str] = None
