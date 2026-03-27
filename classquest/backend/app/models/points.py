from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db import Base

class Rule(Base):
    __tablename__ = "rules"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    base_points = Column(Integer, nullable=False)  # 可为正负
    type = Column(String(20), nullable=False)  # "positive" or "negative"
    daily_limit = Column(Integer, default=0)  # 0表示无限制
    applicable_scope = Column(JSON, default=list)  # 适用人群ID列表
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=True)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    class_ = relationship("Class", back_populates="rules")
    subject = relationship("Subject", back_populates="rules")
    points_logs = relationship("PointsLog", back_populates="rule")
    creator = relationship("User", foreign_keys=[created_by])

class PointsLog(Base):
    __tablename__ = "points_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    group_id = Column(Integer, ForeignKey("groups.id"), nullable=True)
    rule_id = Column(Integer, ForeignKey("rules.id"), nullable=False)
    season_id = Column(Integer, ForeignKey("seasons.id"), nullable=False)
    points = Column(Integer, nullable=False)  # 可为正负
    operator_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    reason = Column(Text, nullable=True)
    is_revoked = Column(Integer, default=0)  # Boolean as integer
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id], back_populates="points_logs")
    operator = relationship("User", foreign_keys=[operator_id], back_populates="operated_logs")
    rule = relationship("Rule", back_populates="points_logs")
    group = relationship("Group", back_populates="points_logs")
    season = relationship("Season", back_populates="points_logs")
    appeals = relationship("Appeal", back_populates="points_log")

class Reward(Base):
    __tablename__ = "rewards"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    points_cost = Column(Integer, nullable=False)
    type = Column(String(20), nullable=False)  # "privilege", "physical", "virtual"
    image_url = Column(String(255), nullable=True)
    stock = Column(Integer, default=-1)  # -1表示无限制
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    class_ = relationship("Class", back_populates="rewards")
    created_by_user = relationship("User", foreign_keys=[created_by])
    exchanges = relationship("Exchange", back_populates="reward")

class Exchange(Base):
    __tablename__ = "exchanges"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    reward_id = Column(Integer, ForeignKey("rewards.id"), nullable=False)
    status = Column(String(20), default="pending")  # "pending", "approved", "rejected"
    points_cost = Column(Integer, nullable=False)
    approved_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    approved_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id], back_populates="exchanges")
    reward = relationship("Reward", back_populates="exchanges")
    approver = relationship("User", foreign_keys=[approved_by])
