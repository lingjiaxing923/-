from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.endpoints import auth, users, classes, points, rewards, appeals, mentorships, exams, groups, websocket, alerts, reports, notifications, backup, voice, permissions

app = FastAPI(
    title="ClassQuest API",
    description="班级积分系统 API",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["认证"])
app.include_router(users.router, prefix="/api/v1/users", tags=["用户"])
app.include_router(classes.router, prefix="/api/v1/classes", tags=["班级"])
app.include_router(points.router, prefix="/api/v1/points", tags=["积分"])
app.include_router(rewards.router, prefix="/api/v1/rewards", tags=["商城"])
app.include_router(appeals.router, prefix="/api/v1/appeals", tags=["申诉"])
app.include_router(mentorships.router, prefix="/api/v1/mentorships", tags=["师徒"])
app.include_router(exams.router, prefix="/api/v1/exams", tags=["考试"])
app.include_router(groups.router, prefix="/api/v1/groups", tags=["小组"])
app.include_router(websocket.router, prefix="/api/v1", tags=["WebSocket"])
app.include_router(alerts.router, prefix="/api/v1/alerts", tags=["预警"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["报表"])
app.include_router(notifications.router, prefix="/api/v1/notifications", tags=["通知"])
app.include_router(backup.router, prefix="/api/v1/backup", tags=["备份"])
app.include_router(voice.router, prefix="/api/v1/voice", tags=["语音"])
app.include_router(permissions.router, prefix="/api/v1/permissions", tags=["权限"])

@app.get("/")
async def root():
    return {
        "message": "ClassQuest API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ClassQuest API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
