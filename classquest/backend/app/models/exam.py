from sqlalchemy import Column, Integer, ForeignKey, DateTime, String
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db import Base

class ExamResult(Base):
    __tablename__ = "exam_results"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    exam_name = Column(String(100), nullable=False)
    score = Column(Integer, nullable=False)
    rank = Column(Integer, nullable=False)
    season_id = Column(Integer, ForeignKey("seasons.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="exam_results")
    season = relationship("Season", back_populates="exam_results")
