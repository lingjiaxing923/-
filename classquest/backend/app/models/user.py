from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.db import Base

class UserRole(enum.Enum):
    ADMIN = "admin"       # 班主任
    MANAGER = "manager"   # 科代表/组长
    STUDENT = "student"   # 学生
    TEACHER = "teacher"   # 任课教师

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    real_name = Column(String(50), nullable=False)
    role = Column(Enum(UserRole), nullable=False, index=True)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id"), nullable=True, index=True)
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    class_ = relationship("Class", foreign_keys="User.class_id", back_populates="students")
    group = relationship("Group", back_populates="members")
    subject = relationship("Subject", back_populates="managers")
    points_logs = relationship("PointsLog", foreign_keys="PointsLog.user_id", back_populates="user")
    operated_logs = relationship("PointsLog", foreign_keys="PointsLog.operator_id", back_populates="operator")
    rewards = relationship("Reward", foreign_keys="Reward.created_by", back_populates="created_by_user")
    exchanges = relationship("Exchange", foreign_keys="Exchange.user_id", back_populates="user")
    mentorships_as_mentor = relationship("Mentorship", foreign_keys="Mentorship.mentor_id", back_populates="mentor")
    mentorships_as_mentee = relationship("Mentorship", foreign_keys="Mentorship.mentee_id", back_populates="mentee")
    appeals = relationship("Appeal", foreign_keys="Appeal.user_id", back_populates="user")
    exam_results = relationship("ExamResult", back_populates="user")
    notifications = relationship("Notification", back_populates="user")
