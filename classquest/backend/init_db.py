"""
数据库初始化脚本
创建初始数据：管理员用户、默认科目、默认赛季
"""
from sqlalchemy.orm import Session
from app.db import SessionLocal, engine, Base, init_db
from app.models import *
from app.core.security import get_password_hash
from datetime import datetime, timedelta


def init_data(db: Session):
    """初始化基础数据"""
    # 创建表
    Base.metadata.create_all(bind=engine)
    
    # 创建默认赛季
    season = Season(
        name="2024-2025学年第一学期",
        start_date=datetime.utcnow(),
        end_date=datetime.utcnow() + timedelta(days=120),
        is_active=1
    )
    db.add(season)
    db.flush()  # Flush to get ID
    
    # 创建默认科目
    subjects = [
        Subject(name="语文"),
        Subject(name="数学"),
        Subject(name="英语"),
        Subject(name="物理"),
        Subject(name="化学"),
        Subject(name="生物"),
        Subject(name="历史"),
        Subject(name="地理"),
        Subject(name="政治"),
    ]
    for subject in subjects:
        db.add(subject)
    db.flush()
    
    # 创建默认管理员
    admin = User(
        username="admin",
        password_hash=get_password_hash("admin123"),
        real_name="管理员",
        role=UserRole.ADMIN,
    )
    db.add(admin)
    
    # 创建测试用户
    student = User(
        username="student1",
        password_hash=get_password_hash("password123"),
        real_name="张三",
        role=UserRole.STUDENT,
    )
    db.add(student)
    
    # 创建测试科代表
    manager = User(
        username="manager1",
        password_hash=get_password_hash("password123"),
        real_name="李四（语文科代表）",
        role=UserRole.MANAGER,
        subject_id=1,  # 语文
    )
    db.add(manager)
    
    # 创建测试班级
    cls = Class(
        name="高二(1)班",
        season_id=season.id,
        admin_id=1
    )
    db.add(cls)
    db.flush()
    
    # 更新用户的班级
    student.class_id = cls.id
    manager.class_id = cls.id
    
    # 创建测试小组
    group = Group(
        class_id=cls.id,
        name="第一组"
    )
    db.add(group)
    
    # 创建测试规则
    rules = [
        Rule(
            name="主动回答",
            base_points=2,
            type="positive",
            daily_limit=3,
            class_id=cls.id,
            created_by=1
        ),
        Rule(
            name="优秀作业",
            base_points=3,
            type="positive",
            daily_limit=1,
            class_id=cls.id,
            created_by=1
        ),
        Rule(
            name="迟到",
            base_points=-2,
            type="negative",
            daily_limit=0,
            class_id=cls.id,
            created_by=1
        ),
    ]
    for rule in rules:
        db.add(rule)
    
    # 创建测试奖励
    rewards = [
        Reward(
            name="免作业卡",
            description="可免除一次作业",
            points_cost=100,
            type="privilege",
            stock=-1,
            class_id=cls.id,
            created_by=1
        ),
        Reward(
            name="座位优先权",
            description="下月座位选择优先",
            points_cost=200,
            type="privilege",
            stock=5,
            class_id=cls.id,
            created_by=1
        ),
        Reward(
            name="奶茶券",
            description="一杯奶茶兑换券",
            points_cost=300,
            type="physical",
            stock=10,
            class_id=cls.id,
            created_by=1
        ),
    ]
    for reward in rewards:
        db.add(reward)
    
    db.commit()
    print("数据库初始化完成！")
    print("=" * 50)
    print("默认账号：")
    print(f"  管理员: admin / admin123")
    print(f"  学生: student1 / password123")
    print(f"  科代表: manager1 / password123")
    print("=" * 50)


if __name__ == "__main__":
    db = SessionLocal()
    try:
        init_data(db)
    finally:
        db.close()
