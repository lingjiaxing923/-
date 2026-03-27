from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, desc
from typing import List, Optional
from datetime import datetime, timedelta
from app.api.deps import get_db, get_current_admin
from app.models.user import User, UserRole
from app.models.points import PointsLog
from app.models.classroom import Class
import pandas as pd
from io import BytesIO

router = APIRouter()


@router.get("/class/{class_id}")
def get_class_report(
    class_id: int,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    format: str = "json",  # json, excel
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取班级报表"""
    # 验证班级权限
    class_ = db.query(Class).filter(Class.id == class_id).first()
    if not class_:
        raise HTTPException(status_code=404, detail="班级不存在")

    # 查询班级所有学生
    students = db.query(User).filter(
        User.class_id == class_id,
        User.role == UserRole.STUDENT
    ).all()

    # 时间范围过滤
    start_dt = None
    end_dt = None
    if start_date:
        start_dt = datetime.fromisoformat(start_date)
    if end_date:
        end_dt = datetime.fromisoformat(end_date)

    # 构建学生数据
    report_data = []
    for student in students:
        # 查询积分记录
        query = db.query(PointsLog).filter(PointsLog.user_id == student.id)

        if start_dt:
            query = query.filter(PointsLog.created_at >= start_dt)
        if end_dt:
            query = query.filter(PointsLog.created_at <= end_dt)

        points_logs = query.all()

        # 计算统计数据
        total_points = sum([log.points for log in points_logs])
        add_points = sum([log.points for log in points_logs if log.points > 0])
        subtract_points = sum([log.points for log in points_logs if log.points < 0])

        report_data.append({
            "student_id": student.id,
            "name": student.real_name,
            "username": student.username,
            "group_id": student.group_id,
            "total_points": total_points,
            "add_points": add_points,
            "subtract_points": abs(subtract_points),
            "operations_count": len(points_logs),
            "current_total": student.total_points or 0
        })

    # 按总积分排序
    report_data.sort(key=lambda x: x['current_total'], reverse=True)

    if format == "excel":
        return generate_excel_report(report_data, class_.name)
    else:
        return {
            "class_name": class_.name,
            "start_date": start_date,
            "end_date": end_date,
            "total_students": len(students),
            "report_data": report_data,
            "generated_at": datetime.utcnow().isoformat()
        }


@router.get("/points/{class_id}")
def get_points_report(
    class_id: int,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取积分明细报表"""
    # 时间范围过滤
    start_dt = None
    end_dt = None
    if start_date:
        start_dt = datetime.fromisoformat(start_date)
    if end_date:
        end_dt = datetime.fromisoformat(end_date)

    # 查询积分记录
    query = db.query(PointsLog).join(User).filter(
        User.class_id == class_id
    )

    if start_dt:
        query = query.filter(PointsLog.created_at >= start_dt)
    if end_dt:
        query = query.filter(PointsLog.created_at <= end_dt)

    points_logs = query.order_by(desc(PointsLog.created_at)).all()

    report_data = []
    for log in points_logs:
        student = db.query(User).filter(User.id == log.user_id).first()
        report_data.append({
            "id": log.id,
            "student_name": student.real_name if student else "未知",
            "username": student.username if student else "未知",
            "group_name": student.group.name if student and student.group else None,
            "points": log.points,
            "reason": log.reason,
            "operator_id": log.operator_id,
            "created_at": log.created_at.isoformat(),
            "is_revoked": log.is_revoked == 1
        })

    return {
        "class_id": class_id,
        "start_date": start_date,
        "end_date": end_date,
        "total_records": len(report_data),
        "report_data": report_data,
        "generated_at": datetime.utcnow().isoformat()
    }


@router.get("/group/{group_id}")
def get_group_report(
    group_id: int,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取小组报表"""
    # 查询小组成员
    members = db.query(User).filter(
        User.group_id == group_id
    ).all()

    if not members:
        raise HTTPException(status_code=404, detail="小组不存在或没有成员")

    group = members[0].group
    class_ = members[0].class_

    # 计算小组统计数据
    total_points = sum([member.total_points or 0 for member in members])
    avg_points = total_points // len(members)

    # 本周积分
    week_ago = datetime.utcnow() - timedelta(days=7)
    this_week_points = db.query(func.sum(PointsLog.points)).filter(
        and_(
            PointsLog.group_id == group_id,
            PointsLog.created_at >= week_ago
        )
    ).scalar() or 0

    report_data = []
    for member in members:
        report_data.append({
            "student_id": member.id,
            "name": member.real_name,
            "username": member.username,
            "total_points": member.total_points or 0,
            "rank": 0  # 班级排名
        })

    # 计算班级排名
    all_students = db.query(User).filter(
        User.class_id == class_.id,
        User.role == UserRole.STUDENT
    ).order_by(desc(User.total_points)).all()

    for idx, student in enumerate(all_students):
        for member_data in report_data:
            if member_data['student_id'] == student.id:
                member_data['rank'] = idx + 1
                break

    return {
        "group_name": group.name,
        "class_name": class_.name,
        "total_members": len(members),
        "total_points": total_points,
        "avg_points": avg_points,
        "this_week_points": this_week_points,
        "members_data": report_data,
        "generated_at": datetime.utcnow().isoformat()
    }


@router.get("/leaderboard/{class_id}")
def get_leaderboard_report(
    class_id: int,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """获取排行榜报表"""
    students = db.query(User).filter(
        User.class_id == class_id,
        User.role == UserRole.STUDENT
    ).order_by(desc(User.total_points)).all()

    report_data = []
    for idx, student in enumerate(students):
        group_name = student.group.name if student.group else "未分组"
        report_data.append({
            "rank": idx + 1,
            "student_id": student.id,
            "name": student.real_name,
            "username": student.username,
            "group_name": group_name,
            "total_points": student.total_points or 0,
            "is_top_three": idx < 3
        })

    return {
        "class_id": class_id,
        "total_students": len(students),
        "leaderboard": report_data,
        "generated_at": datetime.utcnow().isoformat()
    }


def generate_excel_report(data: List[dict], class_name: str):
    """生成Excel报表"""
    df = pd.DataFrame(data)

    # 重命名列
    df.columns = ['学号', '姓名', '用户名', '小组ID', '统计期内积分', '加分', '扣分', '操作次数', '当前总积分']

    # 创建Excel文件
    output = BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='学生积分报表', index=False)

        # 获取工作表
        worksheet = writer.sheets['学生积分报表']

        # 设置列宽
        for column in worksheet.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except:
                    pass
            adjusted_width = min(max_length + 2, 50)
            worksheet.column_dimensions[column_letter].width = adjusted_width

        # 添加标题行
        worksheet.insert_rows(1)
        worksheet['A1'] = f'{class_name} - 学生积分报表'
        worksheet['A1'].font = Font(size=16, bold=True)
        worksheet.merge_cells('A1:I1')

        worksheet['A2'] = f'生成时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}'
        worksheet['A2'].font = Font(size=10, italic=True)

    output.seek(0)

    from fastapi.responses import Response
    return Response(
        content=output.getvalue(),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={
            "Content-Disposition": f"attachment; filename={class_name}_积分报表_{datetime.now().strftime('%Y%m%d')}.xlsx"
        }
    )


# 导入Font类
from openpyxl.styles import Font
