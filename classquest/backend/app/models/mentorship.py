from sqlalchemy import Column, Integer, ForeignKey, DateTime, String, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.db import Base

class MentorshipStatus(enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class Mentorship(Base):
    __tablename__ = "mentorships"
    
    id = Column(Integer, primary_key=True, index=True)
    mentor_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    mentee_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    ratio = Column(Integer, default=20)  # 徒弟得分时师傅获得的百分比
    status = Column(SQLEnum(MentorshipStatus), default=MentorshipStatus.PENDING)
    created_at = Column(DateTime, default=datetime.utcnow)
    approved_at = Column(DateTime, nullable=True)
    
    # Relationships
    mentor = relationship("User", foreign_keys=[mentor_id], back_populates="mentorships_as_mentor")
    mentee = relationship("User", foreign_keys=[mentee_id], back_populates="mentorships_as_mentee")
