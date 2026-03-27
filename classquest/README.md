# ClassQuest 班级积分系统

一个轻量化、游戏化、公平化的学生积分管理平台。

## 🎯 核心目标

- **轻量化**：班主任和课代表10秒内完成一次加减分操作
- **游戏化**：学生端看到的不是冷冰冰的数字，而是"成长路径"
- **公平化**：通过算法权重防止"学霸通吃"，侧重进步与努力

## 🛠 技术栈

### 后端
- **框架**：FastAPI (Python)
- **数据库**：PostgreSQL
- **ORM**：SQLAlchemy
- **认证**：JWT + OAuth2
- **数据导入**：pandas + openpyxl

### 前端
- **框架**：Flutter (跨平台 iOS/Android)
- **状态管理**：Provider
- **网络请求**：HTTP
- **本地存储**：SharedPreferences
- **图表**：FL Chart
- **Excel处理**：Excel

## 👥 用户角色

1. **班主任 (Admin)**
   - 创建班级、设置积分规则、查看报表
   - 确认兑换申请、处理申诉
   - 全局权限

2. **科代表/组长 (Manager)**
   - 在指定科目或组内进行加减分
   - 提交异常记录
   - 受限权限

3. **学生 (User)**
   - 查看个人/小组积分榜
   - 兑换商城物品
   - 查看成长记录
   - 提交申诉、申请师徒结对
   - 个人权限

4. **任课教师 (Teacher)**
   - 在课堂上随时给全班或某学生加减分
   - 受限权限

## 📊 数据库设计

### 核心表 (已完成)

1. **users** - 用户表
2. **classes** - 班级表
3. **groups** - 小组表
4. **seasons** - 赛季表
5. **subjects** - 科目表
6. **rules** - 积分规则表
7. **points_logs** - 积分记录表
8. **rewards** - 奖励商品表
9. **exchanges** - 兑换记录表
10. **mentorships** - 师徒结对表
11. **appeals** - 申诉表
12. **exam_results** - 考试成绩表
13. **notifications** - 通知表

## 🚀 快速开始

### 后端启动

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 初始化数据库
python init_db.py

# 启动服务
uvicorn main:app --reload
```

### 前端启动

```bash
cd frontend

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 访问地址

- **API服务**: http://localhost:8000
- **API文档**: http://localhost:8000/docs
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔑 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | 班主任 |
| student1 | password123 | 学生 |
| manager1 | password123 | 科代表 |

## 📋 API端点

### 认证
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `GET /api/v1/auth/me` - 获取当前用户信息

### 用户管理
- `GET /api/v1/users` - 获取用户列表
- `GET /api/v1/users/{id}` - 获取用户详情
- `POST /api/v1/users/import` - 批量导入学生

### 班级管理
- `POST /api/v1/classes` - 创建班级
- `GET /api/v1/classes` - 获取班级列表
- `GET /api/v1/classes/{id}` - 获取班级详情
- `PUT /api/v1/classes/{id}` - 更新班级

### 小组管理
- `GET /api/v1/groups` - 获取小组列表
- `POST /api/v1/groups` - 创建小组
- `PUT /api/v1/groups/{id}` - 更新小组
- `POST /api/v1/groups/{id}/members` - 添加小组成员
- `DELETE /api/v1/groups/{id}/members/{user_id}` - 移除小组成员
- `DELETE /api/v1/groups/{id}` - 删除小组

### 积分操作
- `POST /api/v1/points/rules` - 创建积分规则
- `GET /api/v1/points/rules` - 获取规则列表
- `POST /api/v1/points/add` - 添加积分
- `POST /api/v1/points/subtract` - 扣减积分
- `GET /api/v1/points/logs` - 获取积分记录
- `POST /api/v1/points/logs/{id}/revoke` - 撤销积分
- `GET /api/v1/points/leaderboard` - 获取排行榜

### 商城
- `POST /api/v1/rewards` - 创建商品
- `GET /api/v1/rewards` - 获取商品列表
- `POST /api/v1/rewards/exchange` - 申请兑换
- `GET /api/v1/rewards/exchanges` - 获取兑换列表
- `PUT /api/v1/rewards/exchanges/{id}` - 审核兑换

### 申诉
- `POST /api/v1/appeals` - 提交申诉
- `GET /api/v1/appeals` - 获取申诉列表
- `PUT /api/v1/appeals/{id}` - 处理申诉

### 师徒结对
- `POST /api/v1/mentorships` - 申请结对
- `GET /api/v1/mentorships` - 获取结对列表
- `PUT /api/v1/mentorships/{id}` - 审核结对

### 成绩管理
- `POST /api/v1/exams/import` - 导入成绩
- `GET /api/v1/exams` - 获取成绩列表

### WebSocket (实时推送)
- `WS /api/v1/ws/{user_id}` - WebSocket连接

### 预警系统
- `GET /api/v1/alerts/zero-points` - 连续零分学生
- `GET /api/v1/alerts/low-points` - 低积分学生
- `GET /api/v1/alerts/statistics` - 预警统计
- `POST /api/v1/alerts/settings` - 更新预警设置
- `GET /api/v1/alerts/settings` - 获取预警设置

### 报表导出
- `GET /api/v1/reports/export/points` - 导出积分报表
- `GET /api/v1/reports/export/exchanges` - 导出兑换报表
- `GET /api/v1/reports/export/students` - 导出学生报表
- `GET /api/v1/reports/export/classes` - 导出班级报表

### 通知系统
- `GET /api/v1/notifications` - 获取通知列表
- `POST /api/v1/notifications/{id}/read` - 标记为已读
- `POST /api/v1/notifications/mark-all-read` - 全部标记为已读
- `DELETE /api/v1/notifications/{id}` - 删除通知
- `POST /api/v1/notifications/send` - 发送通知
- `POST /api/v1/notifications/broadcast` - 广播通知

### 备份恢复
- `POST /api/v1/backup/create` - 创建备份
- `GET /api/v1/backup/list` - 获取备份列表
- `POST /api/v1/backup/restore/{name}` - 恢复备份
- `DELETE /api/v1/backup/{name}` - 删除备份
- `POST /api/v1/backup/auto-backup` - 自动备份设置
- `GET /api/v1/backup/statistics` - 备份统计

### 语音搜索
- `POST /api/v1/voice/search` - 语音或文本搜索学生
- `GET /api/v1/voice/students` - 文本搜索学生
- `GET /api/v1/voice/settings` - 获取语音设置
- `POST /api/v1/voice/settings` - 更新语音设置
- `POST /api/v1/voice/quick-students` - 快速访问学生

### 权限管理
- `GET /api/v1/permissions` - 获取所有权限
- `PUT /api/v1/permissions/{id}` - 更新权限状态
- `POST /api/v1/permissions/role-mapping` - 保存角色映射
- `GET /api/v1/permissions/categories` - 获取权限类别
- `GET /api/v1/permissions/check/{id}` - 检查权限

## 📱 功能模块

### ✅ 已完成 (Phase 1)

#### 后端
- ✅ 项目结构初始化
- ✅ 数据库模型设计 (12张表)
- ✅ Pydantic Schemas
- ✅ 认证和权限系统 (JWT + RBAC)
- ✅ 班级管理API
- ✅ 用户管理API (含批量导入)
- ✅ 积分操作API
- ✅ 商城API
- ✅ 申诉API
- ✅ 师徒结对API
- ✅ 成绩导入API
- ✅ 小组管理API
- ✅ 数据库初始化脚本

#### 前端
- ✅ 项目结构初始化
- ✅ API服务层
- ✅ 认证服务
- ✅ 登录页面
- ✅ 学生端主页 (积分展示、排行榜、商城)
- ✅ 学生端成长记录页面
- ✅ 学生端个人中心页面
- ✅ 学生端师徒结对页面
- ✅ 学生端通知页面
- ✅ 班主任端主页 (完整功能)
- ✅ 班主任端学生导入页面
- ✅ 班主任端商城管理页面
- ✅ 班主任端系统设置页面
- ✅ 班主任端数据备份页面
- ✅ 班主任端赛季管理页面
- ✅ 班主任端权限配置页面
- ✅ 班主任端预警系统页面
- ✅ 班主任端报表导出页面
- ✅ 科代表端主页 (科目专属操作)
- ✅ 任课教师端主页 (快速加减分)
- ✅ 任课教师端课堂投屏看板
- ✅ 数据可视化组件库 (图表、统计卡片、环形图、实时动态)
- ✅ 小组竞赛页面
- ✅ 语音搜索组件
- ✅ 实时弹幕组件
- ✅ 通知中心组件

### ✅ 已完成 (Phase 2)

#### 动力引擎
- ✅ 小组竞赛功能
- ✅ 师徒结对UI
- ✅ 数据可视化组件

#### 自动化与体验
- ✅ 课堂投屏看板
- ✅ 学生导入功能
- ✅ 商城管理功能

### ✅ 已完成 (Phase 3)

#### 自动化与体验
- ✅ WebSocket实时推送
- ✅ 实时弹幕效果
- ✅ 预警系统 (连续零分学生、低积分提醒)
- ✅ 数据报表导出 (Excel)
- ✅ 站内信通知系统
- ✅ 数据备份和恢复
- ✅ 赛季管理
- ✅ 语音搜索功能
- ✅ 权限细分配置

## 🎨 UI设计

- 设计风格：极简/数据/赛博朋克风格
- 深色模式支持
- 命名：**XX班作战指挥系统**
- 适配高中学生心理

## 📁 项目结构

```
classquest/
├── backend/                    # FastAPI 后端
│   ├── app/
│   │   ├── api/             # API 端点
│   │   │   ├── endpoints/
│   │   │   │   ├── auth.py
│   │   │   │   ├── users.py
│   │   │   │   ├── classes.py
│   │   │   │   ├── points.py
│   │   │   │   ├── rewards.py
│   │   │   │   ├── appeals.py
│   │   │   │   ├── mentorships.py
│   │   │   │   ├── exams.py
│   │   │   │   ├── websocket.py
│   │   │   │   ├── alerts.py
│   │   │   │   ├── reports.py
│   │   │   │   ├── notifications.py
│   │   │   │   ├── backup.py
│   │   │   │   ├── voice.py
│   │   │   │   └── permissions.py
│   │   ├── deps/
│   │   ├── models/          # 数据模型
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── crud/            # 数据库操作
│   │   ├── core/            # 配置和安全
│   │   └── utils/
│   ├── main.py
│   ├── init_db.py
│   ├── requirements.txt
│   └── README.md
│
└── frontend/                   # Flutter 前端
    ├── lib/
    │   ├── admin/           # 班主任端
    │   ├── manager/         # 科代表端
    │   ├── student/         # 学生端
    │   ├── teacher/         # 任课教师端
    │   └── shared/          # 共享代码
    │       ├── models/      # 数据模型
    │       ├── services/    # 服务层
    │       ├── widgets/     # 组件
    │       ├── utils/       # 工具类
    │       └── pages/       # 页面
    ├── pubspec.yaml
    └── README.md
```

## 🔧 开发说明

### 环境要求
- Python 3.8+
- Flutter 3.0+
- PostgreSQL 12+
- Redis 6+ (可选，用于缓存和Celery)

### 后端开发
1. 安装Python依赖
2. 配置数据库连接
3. 运行数据库初始化脚本
4. 启动FastAPI服务

### 前端开发
1. 安装Flutter依赖
2. 配置API地址（如需要）
3. 在模拟器或真机上运行
4. 测试各角色功能

## 📝 开发计划

- [x] Phase 1: MVP核心闭环 (已完成)
- [x] Phase 2: 动力引擎 (已完成)
- [x] Phase 3: 自动化与体验 (已完成)

### 项目完成情况
✅ **全部功能已完成** - 100%
- 后端API：64个端点，16个模块
- 数据库表：13张核心表
- 前端页面：27个页面
- 数据可视化组件：8个
- WebSocket实时推送
- 语音搜索功能
- 权限细分配置

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 📞 联系方式

如有问题，请提交 Issue。
