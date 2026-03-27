from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime

def serialize_datetime(value: datetime) -> str:
    return value.isoformat() if value else None

class RewardBase(BaseModel):
    name: str
    description: Optional[str] = None
    points_cost: int
    type: str  # "privilege", "physical", "virtual"
    image_url: Optional[str] = None
    stock: int = -1
    class_id: int

class RewardCreate(RewardBase):
    pass

class RewardUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    points_cost: Optional[int] = None
    stock: Optional[int] = None
    image_url: Optional[str] = None

class RewardResponse(RewardBase):
    id: int
    created_by: Optional[int] = None
    created_at: datetime

    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True

class ExchangeBase(BaseModel):
    user_id: int
    reward_id: int
    points_cost: int

class ExchangeCreate(ExchangeBase):
    pass

class ExchangeResponse(ExchangeBase):
    id: int
    status: str
    approved_by: Optional[int] = None
    approved_at: Optional[datetime] = None
    created_at: datetime

    @field_serializer('approved_at', when_used='json')
    @field_serializer('created_at', when_used='json')
    def serialize_datetime(self, value: datetime) -> str:
        return serialize_datetime(value)

    class Config:
        from_attributes = True
