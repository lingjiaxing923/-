# ClassQuest Backend

班级积分系统后端服务

## 技术栈
- FastAPI (Python Web框架)
- PostgreSQL (数据库)
- SQLAlchemy (ORM)
- Pydantic (数据验证)

## 安装依赖

```bash
pip install -r requirements.txt
```

## 配置环境变量

复制 `.env.example` 到 `.env` 并修改配置：

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```env
DATABASE_URL=postgresql://user:password@localhost/classquest
SECRET_KEY=your-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080
ENVIRONMENT=development
REDIS_URL=redis://localhost:6379/0
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

## 初始化数据库

```bash
python init_db.py
```

## 启动服务

**开发环境：**
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**生产环境：**
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## API文档

启动服务后访问：

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API端点

### 认证
- POST `/api/v1/auth/register` - 用户注册
- POST `/api/v1/auth/login` - 用户登录
- GET `/api/v1/auth/me` - 获取当前用户信息

### 用户管理
- GET `/api/v1/users` - 获取用户列表
- GET `/api/v1/users/{id}` - 获取用户详情
- POST `/api/v1/users/import` - 批量导入学生（Excel）

### 班级管理
- POST `/api/v1/classes` - 创建班级
- GET `/api/v1/classes` - 获取班级列表
- GET `/api/v1/classes/{id}` - 获取班级详情
- PUT `/api/v1/classes/{id}` - 更新班级
- POST `/api/v1/classes/groups` - 创建小组
- GET `/api/v1/classes/{id}/groups` - 获取班级小组
- GET `/api/v1/classes/{id}/students` - 获取班级学生

### 积分操作
- POST `/api/v1/points/rules` - 创建积分规则
- GET `/api/v1/points/rules` - 获取规则列表
- POST `/api/v1/points/add` - 添加积分
- POST `/api/v1/points/subtract` - 扣减积分
- GET `/api/v1/points/logs` - 获取积分记录
- POST `/api/v1/points/logs/{id}/revoke` - 撤销积分记录
- GET `/api/v1/points/leaderboard` - 获取排行榜

### 商城
- POST `/api/v1/rewards` - 创建商品
- GET `/api/v1/rewards` - 获取商品列表
- POST `/api/v1/rewards/exchange` - 申请兑换
- GET `/api/v1/rewards/exchanges` - 获取兑换列表
- PUT `/api/v1/rewards/exchanges/{id}` - 审核兑换

### 申诉
- POST `/api/v1/appeals` - 提交申诉
- GET `/api/v1/appeals` - 获取申诉列表
- PUT `/api/v1/appeals/{id}` - 处理申诉

### 师徒结对
- POST `/api/v1/mentorships` - 申请结对
- GET `/api/v1/mentorships` - 获取结对列表
- PUT `/api/v1/mentorships/{id}` - 审核结对

### 考试成绩
- POST `/api/v1/exams/import` - 导入成绩（Excel）
- GET `/api/v1/exams` - 获取成绩列表

## 数据库表结构

### 用户表 (users)
- id, username, password_hash, real_name
- role (admin/manager/student/teacher)
- class_id, group_id, subject_id
- created_at, updated_at

### 班级表 (classes)
- id, name, season_id, admin_id
- created_at, updated_at

### 小组表 (groups)
- id, class_id, name
- created_at

### 赛季表 (seasons)
- id, name, start_date, end_date, is_active
- created_at

### 科目表 (subjects)
- id, name
- created_at

### 积分规则表 (rules)
- id, name, base_points, type
- daily_limit, applicable_scope (JSON)
- subject_id, class_id, created_by
- created_at

### 积分记录表 (points_logs)
- id, user_id, group_id, rule_id, season_id
- points, operator_id, reason
- is_revoked, created_at

### 奖励商品表 (rewards)
- id, name, description, points_cost
- type (privilege/physical/virtual)
- image_url, stock, class_id
- created_by, created_at

### 兑换记录表 (exchanges)
- id, user_id, reward_id, status
- points_cost, approved_by, approved_at
- created_at

### 师徒结对表 (mentorships)
- id, mentor_id, mentee_id, ratio
- status (pending/approved/rejected)
- created_at, approved_at

### 申诉表 (appeals)
- id, user_id, points_log_id, reason
- status (pending/processed), result
- response, processed_by, processed_at
- created_at

### 考试成绩表 (exam_results)
- id, user_id, exam_name, score
- rank, season_id
- created_at

## 默认测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | 管理员 |
| student1 | password123 | 学生 |
| manager1 | password123 | 科代表 |

## 开发说明

1. 确保已安装 PostgreSQL 并创建了数据库
2. 修改 `.env` 文件中的数据库连接信息
3. 运行 `python init_db.py` 初始化数据库
4. 运行 `uvicorn main:app --reload` 启动服务
5. 访问 http://localhost:8000/docs 查看API文档

## 注意事项

1. 生产环境请修改 `SECRET_KEY`
2. 定期备份数据库
3. 根据实际需求调整 `CORS_ORIGINS`
4. 监控日志文件排查问题
