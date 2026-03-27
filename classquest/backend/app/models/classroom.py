from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db import Base

class Class(Base):
    __tablename__ = "classes"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    season_id = Column(Integer, ForeignKey("seasons.id"), nullable=False)
    admin_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    admin = relationship("User", foreign_keys=[admin_id])
    season = relationship("Season", back_populates="classes")
    students = relationship("User", foreign_keys="User.class_id", back_populates="class_")
    groups = relationship("Group", back_populates="class_")
    rules = relationship("Rule", back_populates="class_")
    rewards = relationship("Reward", back_populates="class_")

class Group(Base):
    __tablename__ = "groups"
    
    id = Column(Integer, primary_key=True, index=True)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    name = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    class_ = relationship("Class", back_populates="groups")
    members = relationship("User", back_populates="group")
    points_logs = relationship("PointsLog", back_populates="group")

class Season(Base):
    __tablename__ = "seasons"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=True)
    is_active = Column(Integer, default=1)  # Boolean as integer
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    classes = relationship("Class", back_populates="season")
    points_logs = relationship("PointsLog", back_populates="season")
    exam_results = relationship("ExamResult", back_populates="season")

class Subject(Base):
    __tablename__ = "subjects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    managers = relationship("User", back_populates="subject")
    rules = relationship("Rule", back_populates="subject")
