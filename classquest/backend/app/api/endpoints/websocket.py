from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from typing import List
import json
import asyncio
from datetime import datetime

router = APIRouter()


class ConnectionManager:
    """WebSocket连接管理器"""
    def __init__(self):
        # 按班级分组存储连接
        self.active_connections: dict[int, List[WebSocket]] = {}
        # 用户ID到WebSocket的映射
        self.user_connections: dict[int, WebSocket] = {}

    async def connect(self, websocket: WebSocket, class_id: int):
        """建立WebSocket连接"""
        await websocket.accept()
        if class_id not in self.active_connections:
            self.active_connections[class_id] = []
        self.active_connections[class_id].append(websocket)
        print(f"WebSocket connected: class {class_id}, total connections: {len(self.active_connections[class_id])}")

    def disconnect(self, websocket: WebSocket, class_id: int):
        """断开WebSocket连接"""
        if class_id in self.active_connections:
            if websocket in self.active_connections[class_id]:
                self.active_connections[class_id].remove(websocket)
            if not self.active_connections[class_id]:
                del self.active_connections[class_id]
        # 从用户连接映射中移除
        user_id_to_remove = None
        for uid, ws in self.user_connections.items():
            if ws == websocket:
                user_id_to_remove = uid
                break
        if user_id_to_remove:
            del self.user_connections[user_id_to_remove]
        print(f"WebSocket disconnected: class {class_id}")

    def set_user_connection(self, user_id: int, websocket: WebSocket):
        """设置用户连接"""
        self.user_connections[user_id] = websocket

    async def broadcast_to_class(self, class_id: int, message: dict):
        """向班级广播消息"""
        if class_id in self.active_connections:
            disconnected = []
            for connection in self.active_connections[class_id]:
                try:
                    await connection.send_json(message)
                except:
                    disconnected.append(connection)
            # 清理断开的连接
            for conn in disconnected:
                self.active_connections[class_id].remove(conn)

    async def send_to_user(self, user_id: int, message: dict):
        """向特定用户发送消息"""
        if user_id in self.user_connections:
            try:
                await self.user_connections[user_id].send_json(message)
            except:
                del self.user_connections[user_id]


# 全局连接管理器实例
manager = ConnectionManager()


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    class_id: int = Query(...),
    user_id: int = Query(...),
    token: str = Query(...)
):
    """WebSocket端点"""
    # TODO: 验证token
    await manager.connect(websocket, class_id)
    manager.set_user_connection(user_id, websocket)

    try:
        # 发送连接成功消息
        await websocket.send_json({
            "type": "connected",
            "message": "WebSocket连接成功",
            "timestamp": datetime.now().isoformat(),
            "user_id": user_id,
            "class_id": class_id
        })

        while True:
            # 接收客户端消息
            data = await websocket.receive_text()
            message = json.loads(data)

            # 处理不同类型的消息
            if message.get("type") == "ping":
                await websocket.send_json({
                    "type": "pong",
                    "timestamp": datetime.now().isoformat()
                })

            elif message.get("type") == "points_update":
                # 广播积分更新到全班
                await manager.broadcast_to_class(class_id, {
                    "type": "points_update",
                    "data": message.get("data"),
                    "timestamp": datetime.now().isoformat()
                })

    except WebSocketDisconnect:
        manager.disconnect(websocket, class_id)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(websocket, class_id)


@router.post("/broadcast/points")
async def broadcast_points_update(
    class_id: int,
    user_id: int,
    points: int,
    reason: str,
    operator_name: str
):
    """广播积分更新消息（用于其他端点调用）"""
    message = {
        "type": "points_update",
        "data": {
            "user_id": user_id,
            "points": points,
            "reason": reason,
            "operator_name": operator_name
        },
        "timestamp": datetime.now().isoformat()
    }
    await manager.broadcast_to_class(class_id, message)
    return {"status": "broadcasted"}


@router.post("/send/notification")
async def send_user_notification(
    user_id: int,
    title: str,
    message: str,
    notification_type: str = "info"
):
    """发送用户通知"""
    notification = {
        "type": "notification",
        "data": {
            "title": title,
            "message": message,
            "notification_type": notification_type
        },
        "timestamp": datetime.now().isoformat()
    }
    await manager.send_to_user(user_id, notification)
    return {"status": "sent"}


@router.get("/connections")
async def get_connections_status():
    """获取WebSocket连接状态"""
    return {
        "active_classes": list(manager.active_connections.keys()),
        "total_connections": sum(len(conns) for conns in manager.active_connections.values()),
        "user_connections": len(manager.user_connections)
    }
