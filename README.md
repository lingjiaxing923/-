# ClassQuest 班级积分管理系统

一个功能完整的班级积分管理Android应用，使用Flutter构建，支持学生、教师、管理员和导师四种角色。

## 项目简介

ClassQuest 是一个现代化的班级管理系统，通过积分制度激励学生，提供完整的班级管理功能。

## 主要功能

### 核心功能
- 🎯 **积分系统** - 全面记录和管理学生积分
- 📊 **数据统计** - 可视化展示班级和学生数据
- 📱 **移动端应用** - 基于Flutter的跨平台应用
- 🔔 **实时通知** - 即时推送重要信息
- 🎮 **班级竞赛** - 增强班级凝聚力

### 角色支持
- 👨‍🎓 **学生** - 查看积分、成长记录、奖励兑换
- 👨‍🏫 **教师** - 管理班级、录入成绩、发起考勤
- 👨‍💼 **管理员** - 系统配置、权限管理、数据备份
- 👨‍🏫 **导师** - 导师制管理、个性化指导

### 特色功能
- 💬 **弹幕互动** - 增强课堂参与度
- 🎤 **语音搜索** - 快速查找功能
- 📤 **数据导出** - Excel格式导出报表
- 🔒 **安全认证** - 完整的权限控制

## 技术栈

### 前端
- **Flutter 3.41.6** - 跨平台UI框架
- **Dart** - 编程语言
- **Provider** - 状态管理
- **HTTP/WebSocket** - 网络通信

### 后端
- **FastAPI** - 现代Python Web框架
- **SQLite** - 轻量级数据库
- **Pydantic** - 数据验证
- **WebSocket** - 实时通信

## 项目结构

```
classquest/
├── frontend/              # Flutter前端项目
│   ├── lib/               # Dart源代码
│   │   ├── admin/         # 管理员页面
│   │   ├── teacher/        # 教师页面
│   │   ├── student/        # 学生页面
│   │   ├── manager/        # 管理员页面
│   │   └── shared/        # 共享组件和服务
│   ├── android/           # Android原生配置
│   └── pubspec.yaml       # 依赖配置
│
├── backend/               # Python后端项目
│   ├── app/
│   │   ├── api/           # API端点
│   │   ├── models/        # 数据模型
│   │   ├── schemas/       # Pydantic模式
│   │   └── core/          # 核心配置
│   ├── main.py             # 应用入口
│   └── requirements.txt     # Python依赖
│
└── build_output/          # 构建输出
    ├── apk/               # APK文件
    └── bundle/            # App Bundle文件
```

## 快速开始

### 前置要求
- Flutter SDK 3.19.0+
- Android SDK 34+
- Java JDK 17+
- Python 3.8+

### 本地开发

#### 1. 克隆项目
```bash
git clone <repository-url>
cd classquest
```

#### 2. 安装依赖

**前端（Flutter）:**
```bash
cd frontend
flutter pub get
```

**后端（Python）:**
```bash
cd backend
pip install -r requirements.txt
```

#### 3. 运行应用

**开发模式（Flutter）:**
```bash
cd frontend
flutter run
```

**后端服务:**
```bash
cd backend
python main.py
```

#### 4. 构建APK
```bash
cd frontend
flutter build apk --release
```

## GitHub Actions 自动构建

本项目配置了 GitHub Actions 自动构建工作流，可以自动生成 Android APK 和 App Bundle。

### 触发构建

**自动触发：**
- 推送代码到 main 分支
- 创建 Pull Request
- 推送版本标签（如 v1.0.0）

**手动触发：**
1. 进入 GitHub 仓库 Actions 页面
2. 选择 "Build Android Complete Package"
3. 选择构建类型（debug/release）
4. 点击运行

### 下载产物

构建完成后在 Actions 页面下载：
- `android-apk-release` - 发布版 APK
- `android-appbundle-release` - App Bundle
- `debug-apk` - 调试版 APK

详细说明请查看 [GITHUB_ACTIONS_SETUP.md](./GITHUB_ACTIONS_SETUP.md)

## 配置说明

### 后端环境变量
创建 `backend/.env` 文件：

```env
DATABASE_URL=sqlite:///classquest.db
SECRET_KEY=your-secret-key
DEBUG=True
```

### Android签名
如需发布到应用商店，需要配置签名密钥。参考 [KEYSTORE_SETUP.md](./classquest/KEYSTORE_SETUP.md)

## 功能模块

### 管理员模块
- 系统配置
- 权限管理
- 数据备份
- 报表导出
- 奖励管理
- 学生导入

### 教师模块
- 班级仪表盘
- 考勤管理
- 成绩录入
- 直播课堂
- 通知发布

### 学生模块
- 积分查看
- 成长记录
- 奖励兑换
- 导师制
- 个人中心

### 共享模块
- 登录认证
- 通知中心
- 班级竞赛
- 图表展示
- 弹幕组件
- 语音搜索

## API文档

启动后端服务后访问：
```
http://localhost:8000/docs
```

## 常见问题

### Q: 如何重置数据库？
```bash
cd backend
python init_db.py
```

### Q: Flutter构建失败？
确保已安装所有依赖：
```bash
flutter doctor
flutter pub get
```

### Q: 后端连接失败？
检查后端服务是否运行：
```bash
curl http://localhost:8000/health
```

## 版本历史

- **v1.0.0** - 初始版本
  - 完整的班级管理功能
  - 四种角色支持
  - 积分系统
  - GitHub Actions自动构建

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 联系方式

- 项目地址：[GitHub Repository](https://github.com/lingjiaxing923/-)
- 问题反馈：[Issues](https://github.com/lingjiaxing923/-/issues)

---

**ClassQuest - 让班级管理更智能、更有趣！**