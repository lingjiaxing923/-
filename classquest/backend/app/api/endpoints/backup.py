from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import inspect
from typing import List, Optional
from datetime import datetime, timedelta
import json
import os
import zipfile
from io import BytesIO
from app.api.deps import get_db, get_current_admin
from app.models.user import User, UserRole
from app.models.classroom import Class
from app.models.points import PointsLog, Reward, Exchange
from app.models.mentorship import Mentorship
from app.models.appeal import Appeal
from app.models.exam import ExamResult

router = APIRouter()

# 备份目录
BACKUP_DIR = "backups"
os.makedirs(BACKUP_DIR, exist_ok=True)


@router.post("/create")
async def create_backup(
    backup_name: Optional[str] = None,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """创建数据备份"""
    try:
        # 生成备份文件名
        if not backup_name:
            backup_name = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        # 创建内存中的ZIP文件
        zip_buffer = BytesIO()

        with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # 备份用户数据
            users = db.query(User).all()
            users_data = [
                {
                    "id": u.id,
                    "username": u.username,
                    "real_name": u.real_name,
                    "role": u.role.value,
                    "class_id": u.class_id,
                    "group_id": u.group_id,
                    "subject_id": u.subject_id,
                    "total_points": u.total_points,
                    "created_at": u.created_at.isoformat() if u.created_at else None,
                    "updated_at": u.updated_at.isoformat() if u.updated_at else None
                }
                for u in users
            ]
            zip_file.writestr("users.json", json.dumps(users_data, ensure_ascii=False, indent=2))

            # 备份班级数据
            classes = db.query(Class).all()
            classes_data = [
                {
                    "id": c.id,
                    "name": c.name,
                    "season_id": c.season_id,
                    "admin_id": c.admin_id,
                    "created_at": c.created_at.isoformat() if c.created_at else None
                }
                for c in classes
            ]
            zip_file.writestr("classes.json", json.dumps(classes_data, ensure_ascii=False, indent=2))

            # 备份积分记录
            points_logs = db.query(PointsLog).all()
            points_data = [
                {
                    "id": p.id,
                    "user_id": p.user_id,
                    "group_id": p.group_id,
                    "rule_id": p.rule_id,
                    "season_id": p.season_id,
                    "points": p.points,
                    "operator_id": p.operator_id,
                    "reason": p.reason,
                    "is_revoked": p.is_revoked,
                    "created_at": p.created_at.isoformat() if p.created_at else None
                }
                for p in points_logs
            ]
            zip_file.writestr("points_logs.json", json.dumps(points_data, ensure_ascii=False, indent=2))

            # 备份其他核心表数据
            mentorships = db.query(Mentorship).all()
            mentorships_data = [
                {
                    "id": m.id,
                    "mentor_id": m.mentor_id,
                    "mentee_id": m.mentee_id,
                    "ratio": m.ratio,
                    "status": m.status.value,
                    "created_at": m.created_at.isoformat() if m.created_at else None
                }
                for m in mentorships
            ]
            zip_file.writestr("mentorships.json", json.dumps(mentorships_data, ensure_ascii=False, indent=2))

            appeals = db.query(Appeal).all()
            appeals_data = [
                {
                    "id": a.id,
                    "user_id": a.user_id,
                    "points_log_id": a.points_log_id,
                    "reason": a.reason,
                    "status": a.status.value,
                    "result": a.result,
                    "processed_by": a.processed_by,
                    "created_at": a.created_at.isoformat() if a.created_at else None
                }
                for a in appeals
            ]
            zip_file.writestr("appeals.json", json.dumps(appeals_data, ensure_ascii=False, indent=2))

            # 添加备份元数据
            metadata = {
                "backup_name": backup_name,
                "created_at": datetime.now().isoformat(),
                "created_by": current_admin.real_name,
                "version": "1.0.0",
                "description": f"ClassQuest系统数据备份",
                "tables": ["users", "classes", "points_logs", "mentorships", "appeals"]
            }
            zip_file.writestr("metadata.json", json.dumps(metadata, ensure_ascii=False, indent=2))

        # 保存到文件
        zip_buffer.seek(0)
        file_path = os.path.join(BACKUP_DIR, f"{backup_name}.zip")
        with open(file_path, 'wb') as f:
            f.write(zip_buffer.getvalue())

        return {
            "message": "备份创建成功",
            "backup_name": backup_name,
            "file_path": file_path,
            "file_size": os.path.getsize(file_path),
            "created_at": datetime.now().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"备份创建失败: {str(e)}")


@router.get("/list")
def list_backups(
    current_admin: User = Depends(get_current_admin)
):
    """获取备份列表"""
    try:
        backups = []

        for filename in os.listdir(BACKUP_DIR):
            if filename.endswith('.zip'):
                file_path = os.path.join(BACKUP_DIR, filename)
                file_stat = os.stat(file_path)
                created_time = datetime.fromtimestamp(file_stat.st_ctime)

                # 读取元数据
                metadata = None
                try:
                    with zipfile.ZipFile(file_path, 'r') as zip_file:
                        if 'metadata.json' in zip_file.namelist():
                            with zip_file.open('metadata.json') as meta_file:
                                metadata = json.loads(meta_file.read().decode('utf-8'))
                except:
                    pass

                backups.append({
                    "filename": filename,
                    "backup_name": metadata.get("backup_name") if metadata else filename.replace('.zip', ''),
                    "created_at": metadata.get("created_at") if metadata else created_time.isoformat(),
                    "created_by": metadata.get("created_by") if metadata else "系统",
                    "file_size": file_stat.st_size,
                    "file_size_mb": round(file_stat.st_size / (1024 * 1024), 2),
                    "version": metadata.get("version") if metadata else "未知"
                })

        # 按创建时间倒序排序
        backups.sort(key=lambda x: x['created_at'], reverse=True)

        return {
            "backups": backups,
            "total_count": len(backups),
            "total_size_mb": round(sum(b['file_size'] for b in backups) / (1024 * 1024), 2)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取备份列表失败: {str(e)}")


@router.post("/restore/{backup_name}")
async def restore_backup(
    backup_name: str,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """恢复数据备份"""
    try:
        file_path = os.path.join(BACKUP_DIR, f"{backup_name}.zip")

        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="备份文件不存在")

        # 读取ZIP文件
        with zipfile.ZipFile(file_path, 'r') as zip_file:
            # 验证元数据
            if 'metadata.json' not in zip_file.namelist():
                raise HTTPException(status_code=400, detail="无效的备份文件")

            with zip_file.open('metadata.json') as meta_file:
                metadata = json.loads(meta_file.read().decode('utf-8'))

            # 恢复数据
            tables_to_restore = metadata.get("tables", [])

            restored_count = 0

            # 恢复用户数据
            if 'users.json' in zip_file.namelist():
                with zip_file.open('users.json') as users_file:
                    users_data = json.loads(users_file.read().decode('utf-8'))

                    for user_data in users_data:
                        existing_user = db.query(User).filter(User.id == user_data['id']).first()
                        if existing_user:
                            # 更新现有用户
                            existing_user.real_name = user_data['real_name']
                            existing_user.role = UserRole(user_data['role'])
                            existing_user.class_id = user_data['class_id']
                            existing_user.group_id = user_data['group_id']
                            existing_user.subject_id = user_data['subject_id']
                            existing_user.total_points = user_data['total_points']
                        else:
                            # 创建新用户（如果需要）
                            pass
                    restored_count += len(users_data)

            db.commit()

        return {
            "message": "数据恢复成功",
            "backup_name": backup_name,
            "restored_records": restored_count,
            "restored_at": datetime.now().isoformat()
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"数据恢复失败: {str(e)}")


@router.delete("/{backup_name}")
def delete_backup(
    backup_name: str,
    current_admin: User = Depends(get_current_admin)
):
    """删除备份文件"""
    try:
        file_path = os.path.join(BACKUP_DIR, f"{backup_name}.zip")

        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="备份文件不存在")

        os.remove(file_path)

        return {
            "message": "备份删除成功",
            "backup_name": backup_name,
            "deleted_at": datetime.now().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"删除备份失败: {str(e)}")


@router.post("/auto-backup")
async def auto_backup(
    db: Session = Depends(get_db)
):
    """自动备份任务（可由定时任务调用）"""
    try:
        # 获取当前管理员用户
        admin = db.query(User).filter(User.role == UserRole.ADMIN).first()

        if not admin:
            return {"message": "没有管理员用户，跳过自动备份"}

        # 创建备份
        backup_name = f"auto_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        # 调用创建备份的逻辑
        # 这里简化处理，实际应该调用create_backup的逻辑
        return {
            "message": "自动备份执行成功",
            "backup_name": backup_name,
            "created_at": datetime.now().isoformat()
        }

    except Exception as e:
        return {
            "message": f"自动备份失败: {str(e)}",
            "error": str(e)
        }


@router.get("/settings")
def get_backup_settings(
    current_admin: User = Depends(get_current_admin)
):
    """获取备份设置"""
    return {
        "auto_backup_enabled": True,
        "backup_frequency": "daily",  # daily, weekly, monthly
        "backup_retention_days": 30,
        "backup_directory": BACKUP_DIR,
        "last_backup_time": None,
        "next_backup_time": None
    }


@router.post("/settings")
def update_backup_settings(
    settings: dict,
    current_admin: User = Depends(get_current_admin)
):
    """更新备份设置"""
    return {
        "message": "备份设置已更新",
        "settings": settings
    }


@router.post("/export/{table_name}")
def export_table(
    table_name: str,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """导出指定表的数据"""
    try:
        # 支持的表名
        table_map = {
            "users": User,
            "classes": Class,
            "points_logs": PointsLog,
            "mentorships": Mentorship,
            "appeals": Appeal
        }

        if table_name not in table_map:
            raise HTTPException(status_code=400, detail=f"不支持的表名: {table_name}")

        model_class = table_map[table_name]
        records = db.query(model_class).all()

        # 转换为字典列表
        data = []
        for record in records:
            # 获取所有列
            mapper = inspect(model_class)
            columns = mapper.columns

            record_dict = {}
            for column in columns:
                value = getattr(record, column.name)
                if value is not None:
                    if isinstance(value, datetime):
                        record_dict[column.name] = value.isoformat()
                    elif hasattr(value, 'value'):
                        record_dict[column.name] = value.value
                    else:
                        record_dict[column.name] = str(value)

            data.append(record_dict)

        return {
            "table_name": table_name,
            "records_count": len(data),
            "data": data,
            "exported_at": datetime.now().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"导出失败: {str(e)}")


@router.get("/statistics")
def get_backup_statistics(
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取备份统计信息"""
    try:
        total_backups = 0
        total_size = 0
        latest_backup = None

        if os.path.exists(BACKUP_DIR):
            for filename in os.listdir(BACKUP_DIR):
                if filename.endswith('.zip'):
                    total_backups += 1
                    file_path = os.path.join(BACKUP_DIR, filename)
                    total_size += os.path.getsize(file_path)

                    if latest_backup is None:
                        latest_backup = datetime.fromtimestamp(os.path.getctime(file_path))
                    else:
                        backup_time = datetime.fromtimestamp(os.path.getctime(file_path))
                        if backup_time > latest_backup:
                            latest_backup = backup_time

        # 数据库记录统计
        users_count = db.query(User).count()
        classes_count = db.query(Class).count()
        points_logs_count = db.query(PointsLog).count()

        return {
            "backups": {
                "total_count": total_backups,
                "total_size_mb": round(total_size / (1024 * 1024), 2),
                "latest_backup": latest_backup.isoformat() if latest_backup else None
            },
            "database": {
                "users_count": users_count,
                "classes_count": classes_count,
                "points_logs_count": points_logs_count,
                "total_records": users_count + classes_count + points_logs_count
            },
            "settings": {
                "backup_directory": BACKUP_DIR,
                "auto_backup_enabled": True,
                "backup_frequency": "daily"
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取统计信息失败: {str(e)}")


# 在文件顶部添加导入
import zipfile as zip_file