from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Text, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.db import Base


class NotificationType(str, enum.Enum):
    """通知类型"""
    EXCHANGE_APPROVED = "exchange_approved"
    EXCHANGE_REJECTED = "exchange_rejected"
    APPEAL_PROCESSED = "appeal_processed"
    MENTORSHIP_APPROVED = "mentorship_approved"
    MENTORSHIP_REJECTED = "mentorship_rejected"
    POINTS_WARNING = "points_warning"
    SYSTEM_ANNOUNCEMENT = "system_announcement"


class Notification(Base):
    """通知表"""
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(SQLEnum(NotificationType), nullable=False, index=True)
    title = Column(String(100), nullable=False)
    content = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    read_at = Column(DateTime, nullable=True)

    # 关联
    user = relationship("User", back_populates="notifications")

    def __repr__(self):
        return f"<Notification(id={self.id}, user_id={self.user_id}, type='{self.type}')>"
