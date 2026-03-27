from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
import pandas as pd
import io

from app.db import get_db
from app.core.security import get_current_user, get_current_admin
from app.models.user import User
from app.models.points import PointsLog, Rule
from app.models.classroom import Season
from app.models.exam import ExamResult
from app.schemas.exam import ExamResultCreate, ExamResultResponse

router = APIRouter()

@router.post("/import")
def import_exams(
    file: bytes,
    class_id: int,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    # Parse Excel file
    try:
        df = pd.read_excel(io.BytesIO(file))
        season = db.query(Season).filter(Season.is_active == 1).first()
        if not season:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="没有活跃的赛季"
            )
        
        results = []
        for _, row in df.iterrows():
            # Check required columns
            if '用户名' not in df.columns or '考试名称' not in df.columns:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Excel文件必须包含'用户名'、'考试名称'、'分数'和'排名'列"
                )
            
            # Find user
            user = db.query(User).filter(User.username == row['用户名']).first()
            if not user:
                continue
            
            # Create exam result
            result = ExamResult(
                user_id=user.id,
                exam_name=row['考试名称'],
                score=row['分数'],
                rank=row['排名'],
                season_id=season.id
            )
            db.add(result)
            results.append(result)
        
        db.commit()
        
        # Calculate progress points for students with improved rankings
        # Compare with previous exam results
        previous_exams = db.query(ExamResult).filter(
            ExamResult.season_id == season.id,
            ExamResult.user_id.in_([r.user_id for r in results])
        ).all()
        
        # Group by user and find last exam for each user
        from collections import defaultdict
        user_last_exam = defaultdict(list)
        for pe in previous_exams:
            if pe.user_id not in [r.user_id for r in results]:
                user_last_exam[pe.user_id].append(pe)
        
        # Auto-add progress points for improvements
        progress_points_added = 0
        for result in results:
            if result.user_id in user_last_exam and user_last_exam[result.user_id]:
                last_rank = min([pe.rank for pe in user_last_exam[result.user_id]])
                improvement = last_rank - result.rank
                if improvement > 10:  # Improvement threshold
                    # Create progress points
                    progress_rule = Rule(
                        name="进步分",
                        base_points=20,
                        type="positive",
                        daily_limit=0,
                        class_id=class_id
                    )
                    db.add(progress_rule)
                    db.flush()
                    
                    points_log = PointsLog(
                        user_id=result.user_id,
                        group_id=db.query(User).filter(User.id == result.user_id).first().group_id,
                        rule_id=progress_rule.id,
                        season_id=season.id,
                        points=20,
                        operator_id=current_user.id,
                        reason=f"考试排名进步 {improvement} 名"
                    )
                    db.add(points_log)
                    progress_points_added += 1
        
        db.commit()
        return {
            "message": f"成功导入 {len(results)} 条成绩记录",
            "progress_points_added": progress_points_added
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"导入失败: {str(e)}"
        )

@router.get("", response_model=list[ExamResultResponse])
def read_exams(
    season_id: int | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(ExamResult)
    if season_id:
        query = query.filter(ExamResult.season_id == season_id)
    exams = query.all()
    
    return [
        ExamResultResponse(
            id=e.id,
            user_id=e.user_id,
            user_name=db.query(User).filter(User.id == e.user_id).first().real_name if e.user_id else "",
            exam_name=e.exam_name,
            score=e.score,
            rank=e.rank,
            season_id=e.season_id,
            created_at=str(e.created_at)
        )
        for e in exams
    ]
