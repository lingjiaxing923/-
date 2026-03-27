from sqlalchemy import Column, Integer, ForeignKey, DateTime, Text, String, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.db import Base

class AppealStatus(enum.Enum):
    PENDING = "pending"
    PROCESSED = "processed"

class AppealResult(enum.Enum):
    APPROVED = "approved"
    REJECTED = "rejected"

class Appeal(Base):
    __tablename__ = "appeals"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    points_log_id = Column(Integer, ForeignKey("points_logs.id"), nullable=False)
    reason = Column(Text, nullable=False)
    status = Column(SQLEnum(AppealStatus), default=AppealStatus.PENDING)
    result = Column(String(20), nullable=True)  # "approved", "rejected"
    response = Column(Text, nullable=True)
    processed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    processed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id], back_populates="appeals")
    points_log = relationship("PointsLog", back_populates="appeals")
    processor = relationship("User", foreign_keys=[processed_by])
