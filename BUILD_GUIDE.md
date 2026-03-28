# ClassQuest Android 应用构建指南

## 当前状态

✅ **已完成**:
- 完整的 ClassQuest 业务代码（admin、student、teacher、manager、shared 模块）
- Android 项目结构完全重构
- Gradle 8.7 + AGP 8.2.2 + Kotlin 1.9.22
- Java 17
- 符合 Flutter 3.41.6 标准

## 构建方式

由于本地环境未安装 Flutter，请通过 GitHub Actions 构建：

### 方式 1: 通过 GitHub Actions 构建（推荐）

1. 访问: https://github.com/lingjiaxing923/-/actions
2. 选择工作流: "Build Android APK (Basic)"
3. 选择构建类型:
   - `debug`: 调试版本，用于开发测试
   - `release`: 发布版本，用于正式发布
4. 点击: "Run workflow"
5. 等待构建完成（约 2-3 分钟）
6. 下载生成的 APK 文件

### 方式 2: 本地构建（需要安装 Flutter）

如果你本地安装了 Flutter，可以运行：

```bash
cd classquest/frontend

# 获取依赖
flutter pub get

# 构建 Debug APK
flutter build apk --debug

# 构建 Release APK
flutter build apk --release

# APK 输出位置
# Debug: build/app/outputs/flutter-apk/app-debug.apk
# Release: build/app/outputs/flutter-apk/app-release.apk
```

## 当前配置

| 项目 | 版本 |
|------|------|
| Flutter | 3.41.6 (stable) |
| Gradle | 8.7 |
| AGP | 8.2.2 |
| Kotlin | 1.9.22 |
| Java | 17 |
| Min SDK | 21 |
| Target SDK | 34 |

## 项目结构

```
classquest/frontend/
├── lib/                    # Dart 代码
│   ├── main.dart           # 应用入口
│   ├── admin/             # 管理员模块
│   ├── student/           # 学生模块
│   ├── teacher/           # 教师模块
│   ├── manager/           # 管理者模块
│   └── shared/            # 共享模块
├── android/               # Android 项目结构
│   ├── app/
│   ├── gradle/
│   └── settings.gradle
├── pubspec.yaml           # Flutter 项目配置
└── assets/               # 资源文件
```

## 预期构建结果

✅ **成功构建后**:
- 生成 Android APK 文件
- 可在真机或模拟器上安装运行
- 包含完整的班级积分系统功能

## 常见问题

### Q: 构建失败怎么办？
A: 检查 GitHub Actions 的构建日志，查看具体错误信息

### Q: 如何安装 APK？
A:
1. 将 APK 下载到 Android 设备
2. 在设备上启用"未知来源"安装
3. 点击 APK 文件安装

### Q: Debug 和 Release 有什么区别？
A:
- Debug: 包含调试信息，体积较大，用于开发测试
- Release: 优化体积，去除调试信息，用于正式发布

## 下一步

构建成功后：
1. 测试 APK 功能
2. 如需修改，提交代码后重新触发构建
3. 正式发布前使用 Release 版本
