from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.api.deps import get_db, get_current_admin
from app.models.user import User
from datetime import datetime

router = APIRouter()

# 预定义的权限配置
PERMISSIONS_CONFIG = [
    {
        "id": "points_view",
        "name": "查看积分",
        "category": "points",
        "description": "查看学生积分详情和积分记录",
        "roles": ["admin", "manager", "teacher", "student"],
        "enabled": True
    },
    {
        "id": "points_add",
        "name": "添加积分",
        "category": "points",
        "description": "为学生添加积分",
        "roles": ["admin", "manager", "teacher"],
        "enabled": True
    },
    {
        "id": "points_subtract",
        "name": "扣除积分",
        "category": "points",
        "description": "扣除学生积分",
        "roles": ["admin", "manager", "teacher"],
        "enabled": True
    },
    {
        "id": "points_revoke",
        "name": "撤销积分",
        "category": "points",
        "description": "撤销已添加的积分记录",
        "roles": ["admin", "manager"],
        "enabled": True
    },
    {
        "id": "users_view",
        "name": "查看用户",
        "category": "users",
        "description": "查看用户信息和列表",
        "roles": ["admin", "manager", "teacher"],
        "enabled": True
    },
    {
        "id": "users_import",
        "name": "导入用户",
        "category": "users",
        "description": "批量导入学生信息",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "users_manage",
        "name": "管理用户",
        "category": "users",
        "description": "编辑和删除用户",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "classes_view",
        "name": "查看班级",
        "category": "classes",
        "description": "查看班级信息",
        "roles": ["admin", "manager", "teacher", "student"],
        "enabled": True
    },
    {
        "id": "classes_create",
        "name": "创建班级",
        "category": "classes",
        "description": "创建新班级",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "classes_manage",
        "name": "管理班级",
        "category": "classes",
        "description": "编辑班级设置和管理成员",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "rewards_view",
        "name": "查看商城",
        "category": "rewards",
        "description": "浏览商城商品",
        "roles": ["admin", "manager", "teacher", "student"],
        "enabled": True
    },
    {
        "id": "rewards_exchange",
        "name": "兑换商品",
        "category": "rewards",
        "description": "使用积分兑换商品",
        "roles": ["admin", "manager", "teacher", "student"],
        "enabled": True
    },
    {
        "id": "rewards_manage",
        "name": "管理商城",
        "category": "rewards",
        "description": "添加、编辑和删除商品",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "rewards_approve",
        "name": "审批兑换",
        "category": "rewards",
        "description": "审批商品兑换申请",
        "roles": ["admin", "manager"],
        "enabled": True
    },
    {
        "id": "reports_view",
        "name": "查看报表",
        "category": "reports",
        "description": "查看数据报表和分析",
        "roles": ["admin", "manager", "teacher"],
        "enabled": True
    },
    {
        "id": "reports_export",
        "name": "导出报表",
        "category": "reports",
        "description": "导出Excel报表",
        "roles": ["admin", "manager"],
        "enabled": True
    },
    {
        "id": "reports_alerts",
        "name": "查看预警",
        "category": "reports",
        "description": "查看预警信息和学生状态",
        "roles": ["admin", "manager", "teacher"],
        "enabled": True
    },
    {
        "id": "system_settings",
        "name": "系统设置",
        "category": "system",
        "description": "修改系统配置",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "system_backup",
        "name": "数据备份",
        "category": "system",
        "description": "创建和恢复数据备份",
        "roles": ["admin"],
        "enabled": True
    },
    {
        "id": "system_notifications",
        "name": "发送通知",
        "category": "system",
        "description": "发送系统通知",
        "roles": ["admin"],
        "enabled": True
    },
]

# 运行时权限状态存储（实际应该存储在数据库）
_permissions_state = {p["id"]: p for p in PERMISSIONS_CONFIG}


@router.get("")
async def get_permissions(
    current_admin: User = Depends(get_current_admin)
):
    """获取所有权限配置"""
    return {
        "permissions": list(_permissions_state.values()),
        "total": len(_permissions_state)
    }


@router.put("/{permission_id}")
async def update_permission(
    permission_id: str,
    enabled: bool = None,
    current_admin: User = Depends(get_current_admin)
):
    """更新权限状态"""
    if permission_id not in _permissions_state:
        raise HTTPException(
            status_code=404,
            detail=f"权限 {permission_id} 不存在"
        )

    if enabled is not None:
        _permissions_state[permission_id]["enabled"] = enabled

    return {
        "message": "权限设置已更新",
        "permission": _permissions_state[permission_id]
    }


@router.post("/role-mapping")
async def save_role_mapping(
    current_admin: User = Depends(get_current_admin)
):
    """保存角色权限映射（占位符，实际应该存储到数据库）"""
    # 实际实现中，这里应该将当前的角色-权限映射关系保存到数据库
    return {
        "message": "角色权限映射已保存",
        "timestamp": datetime.utcnow().isoformat()
    }


@router.get("/categories")
async def get_permission_categories(
    current_admin: User = Depends(get_current_admin)
):
    """获取权限类别列表"""
    categories = {
        "points": {
            "name": "积分权限",
            "icon": "stars",
            "description": "积分相关操作权限"
        },
        "users": {
            "name": "用户权限",
            "icon": "people",
            "description": "用户管理权限"
        },
        "classes": {
            "name": "班级权限",
            "icon": "class",
            "description": "班级管理权限"
        },
        "rewards": {
            "name": "商城权限",
            "icon": "card_giftcard",
            "description": "商城和兑换权限"
        },
        "reports": {
            "name": "报表权限",
            "icon": "assessment",
            "description": "报表和数据分析权限"
        },
        "system": {
            "name": "系统权限",
            "icon": "settings",
            "description": "系统配置和管理权限"
        }
    }

    return categories


@router.get("/check/{permission_id}")
async def check_permission(
    permission_id: str,
    current_user: User = Depends(get_current_admin)
):
    """检查当前用户是否有某个权限"""
    if permission_id not in _permissions_state:
        raise HTTPException(
            status_code=404,
            detail=f"权限 {permission_id} 不存在"
        )

    permission = _permissions_state[permission_id]
    has_permission = (
        permission["enabled"] and
        current_user.role.value in permission["roles"]
    )

    return {
        "permission_id": permission_id,
        "enabled": permission["enabled"],
        "has_permission": has_permission,
        "user_role": current_user.role.value,
        "allowed_roles": permission["roles"]
    }
