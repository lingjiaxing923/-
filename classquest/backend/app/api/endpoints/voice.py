from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.api.deps import get_db, get_current_admin, get_current_manager
from app.models.user import User, UserRole
import os

router = APIRouter()

# 语音识别服务 (使用Web Speech API或集成第三方服务)
class VoiceRecognitionService:
    def __init__(self):
        self.supported = False
        self.api_key = None

    def initialize(self):
        """初始化语音识别服务"""
        # 这里可以集成语音识别API
        # 暂时返回模拟数据
        pass

    async def recognize(self, audio_data: bytes) -> str:
        """识别音频数据，返回文本"""
        # 模拟识别结果
        return "张三"  # 实际应该返回识别的文本

    def is_supported(self) -> bool:
        """检查是否支持语音识别"""
        return self.supported


voice_service = VoiceRecognitionService()


@router.post("/search")
async def voice_search(
    audio_data: bytes = None,
    text: str = None,
    limit: int = 10,
    class_id: int = None,
    current_admin: User = Depends(get_current_admin)
):
    """语音或文本搜索学生"""
    try:
        # 确定搜索关键词
        search_keyword = text

        # 如果有音频数据，进行语音识别
        if audio_data is not None:
            search_keyword = await voice_service.recognize(audio_data)

        if not search_keyword or len(search_keyword.strip()) < 1:
            raise HTTPException(
                status_code=400,
                detail="搜索关键词不能为空"
            )

        # 搜索学生
        results = await search_students(
            search_keyword,
            limit,
            class_id,
            current_admin
        )

        return {
            "keyword": search_keyword,
            "results": results,
            "total_count": len(results),
            "is_voice_search": audio_data is not None
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"搜索失败: {str(e)}"
        )


async def search_students(
    keyword: str,
    limit: int,
    class_id: Optional[int],
    current_admin: User
) -> List[dict]:
    """搜索学生"""
    # 这里应该从数据库中搜索
    # 现在返回模拟数据

    mock_students = [
        {"id": 1, "name": "张三", "username": "2024001", "class_name": "三年二班"},
        {"id": 2, "name": "张思", "username": "2024002", "class_name": "三年二班"},
        {"id": 3, "name": "王五", "username": "2024003", "class_name": "三年二班"},
    ]

    # 简单的模糊匹配
    matched_students = []
    for student in mock_students:
        if keyword.lower() in student['name'].lower() or \
           keyword.lower() in student['username'].lower():
            matched_students.append(student)
            if len(matched_students) >= limit:
                break

    return matched_students


@router.get("/students")
def get_voice_search_students(
    keyword: str,
    limit: int = 10,
    class_id: Optional[int] = None,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取语音搜索的学生列表"""
    try:
        # 从数据库搜索学生
        query = db.query(User).filter(User.role == UserRole.STUDENT)

        if class_id:
            query = query.filter(User.class_id == class_id)

        # 模糊搜索姓名和学号
        students = query.filter(
            (User.real_name.ilike(f'%{keyword}%')) |
            (User.username.ilike(f'%{keyword}%'))
        ).limit(limit).all()

        results = []
        for student in students:
            results.append({
                "id": student.id,
                "name": student.real_name,
                "username": student.username,
                "class_name": student.class_.name if student.class_ else "未知",
                "group_name": student.group.name if student.group else "未分组",
                "total_points": student.total_points or 0,
                "avatar": None
            })

        return {
            "keyword": keyword,
            "results": results,
            "total_count": len(results)
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"搜索失败: {str(e)}"
        )


@router.get("/settings")
def get_voice_settings(
    current_admin: User = Depends(get_current_admin)
):
    """获取语音搜索设置"""
    return {
        "voice_enabled": voice_service.is_supported(),
        "auto_start_timeout": 3,  # 自动开始录音超时(秒)
        "max_record_duration": 10, # 最长录音时长(秒)
        "language": "zh-CN",  # 语言设置
        "api_provider": "本地模拟"  # API提供商
    }


@router.post("/settings")
def update_voice_settings(
    voice_enabled: Optional[bool] = None,
    auto_start_timeout: Optional[int] = None,
    max_record_duration: Optional[int] = None,
    language: Optional[str] = None,
    current_admin: User = Depends(get_current_admin)
):
    """更新语音搜索设置"""
    settings = {}

    if voice_enabled is not None:
        settings['voice_enabled'] = voice_enabled
    if auto_start_timeout is not None:
        settings['auto_start_timeout'] = auto_start_timeout
    if max_record_duration is not None:
        settings['max_record_duration'] = max_record_duration
    if language is not None:
        settings['language'] = language

    # 实际应该保存到数据库或配置文件

    return {
        "message": "语音搜索设置已更新",
        "settings": settings
    }


@router.post("/quick-students")
def get_quick_students(
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取快速访问的学生列表（常用学生）"""
    try:
        # 获取最近积分变化的学生
        from app.models.points import PointsLog
        from datetime import datetime, timedelta

        week_ago = datetime.utcnow() - timedelta(days=7)

        # 查询最近有积分变化的学生
        recent_student_ids = db.query(PointsLog).filter(
            PointsLog.created_at >= week_ago
        ).distinct(PointsLog.user_id).all()

        recent_student_ids = [log.user_id for log in recent_student_ids]

        # 获取这些学生的信息
        if recent_student_ids:
            students = db.query(User).filter(
                User.id.in_(recent_student_ids)
            ).all()
        else:
            students = []

        results = []
        for student in students:
            results.append({
                "id": student.id,
                "name": student.real_name,
                "username": student.username,
                "class_name": student.class_.name if student.class_ else "未知",
                "group_name": student.group.name if student.group else "未分组",
                "total_points": student.total_points or 0,
                "recent_activity": "最近7天活跃"
            })

        return {
            "students": results,
            "count": len(results)
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"获取快速访问学生失败: {str(e)}"
        )
