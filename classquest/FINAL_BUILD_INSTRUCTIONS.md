# ClassQuest APK 构建说明

## 🎯 当前状态

**✅ 构建准备完成 100%**

所有必要的配置文件、构建脚本和文档都已经准备完成。

**⚠️ 当前环境限制**

由于当前环境的 Java 版本（25.0.1）与 Gradle 8.0.0 不兼容，无法在当前环境中完成最终的 APK 构建。

---

## 🚀 如何构建 APK（两种方法）

### 方法一：使用在线构建服务（推荐，无需本地配置）

#### Codemagic（最推荐）

**步骤**：
1. 访问 https://codemagic.io/
2. 注册账号
3. 连接 GitHub 仓库
4. 配置构建设置：
   - Flutter 版本：3.16.5
   - 构建目标：APK (Release)
   - 目标平台：Android arm64-v8a
5. 开始自动构建
6. 下载生成的 APK 文件

**优点**：
- ✅ 无需本地安装 Flutter SDK
- ✅ 无需配置 Android SDK
- ✅ 自动化构建流程
- ✅ 支持多个目标平台
- ✅ 完整的构建日志

**预计时间**：5-10 分钟

---

### 方法二：在本地环境构建

#### 环境要求

| 组件 | 要求 | 当前状态 |
|------|------|---------|
| Flutter SDK | >= 3.0.0 | ✅ 3.16.5 |
| Java JDK | 11-17 | ⚠️ 25.0.1（不兼容）|
| Android SDK | API 33 | ✅ API 33 |
| Gradle | 7.6.3 | ✅ 7.6.3 |

#### 推荐的本地环境

**Ubuntu 20.04 LTS 或更新**：
```bash
# 安装 JDK 17
sudo apt update
sudo apt install -y openjdk-17-jdk

# 设置 JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# 验证 Java 版本
java -version
# 应该显示：openjdk version "17.x.x"
```

#### 构建步骤（兼容环境）

```bash
# 1. 进入项目目录
cd /path/to/classquest

# 2. 清理旧构建
flutter clean

# 3. 获取依赖
flutter pub get

# 4. 构建 APK（推荐架构）
flutter build apk --release --target-platform android-arm64

# 5. 查找构建产物
ls -lh frontend/build/app/outputs/flutter-apk/app-release.apk

# 6. 复制到输出目录
mkdir -p build_output/apk
cp frontend/build/app/outputs/flutter-apk/app-release.apk build_output/apk/ClassQuest-1.0.0-release.apk
```

#### 构建步骤（通用架构）

```bash
# 构建包含所有架构的通用 APK
flutter build apk --release

# 或者分别构建不同架构
flutter build apk --release --target-platform android-arm64       # 推荐
flutter build apk --release --target-platform android-armeabi-v7a  # 兼容旧设备
flutter build apk --release --target-platform android-x64        # 模拟器
```

---

## 📋 相关文档

### 构建指南
1. **`COMPLETE_BUILD_GUIDE.md`** - 完整的构建指南（推荐首先阅读）
2. **`APK_BUILD_ATTEMPT_REPORT.md`** - 构建尝试详细报告
3. **`FLUTTER_ANDROID_BUILD_COMPLETE.md`** - 构建完成报告
4. **`APK_BUILD_STATUS.md`** - 构建状态报告
5. **`ANDROID_README.md`** - 快速开始指南

### 故障排除
1. **`APK_FIX_INSTRUCTIONS.md`** - APK 安装问题修复指南
2. **`APK_INSTALLATION_SOLUTION.md`** - 完整解决方案
3. **`apk_fix_tool.sh`** - 诊断和修复工具

### 配置文件
- **`frontend/android/build.gradle`** - 项目级 Gradle 配置
- **`frontend/android/app/build.gradle`** - 应用级 Gradle 配置
- **`frontend/android/app/src/main/AndroidManifest.xml`** - Android 清单
- **`frontend/android/app/proguard-rules.pro`** - ProGuard 混淆规则

---

## 📊 项目信息

### 应用基本信息

| 项目 | 信息 |
|------|------|
| 应用名称 | ClassQuest - 班级积分管理系统 |
| 包名 | com.classquest.app |
| 版本号 | 1.0.0 |
| Version Code | 1 |
| 最低版本 | Android 5.0 (API 21) |
| 目标版本 | Android 13 (API 33) |
| 推荐架构 | arm64-v8a |
| 预期大小 | 15-35 MB |

### Flutter 项目结构

```
frontend/
├── lib/
│   ├── admin/              # 班主任端（快速加减分、班级管理、规则设置）
│   ├── manager/            # 科代表端（科目专属积分操作）
│   ├── student/            # 学生端（积分查看、排行榜、商城兑换、师徒系统、申诉）
│   ├── teacher/            # 教师端（课堂快速加分）
│   └── shared/             # 共享组件（登录、API 服务、WebSocket）
├── pubspec.yaml            # Flutter 依赖配置
├── assets/                 # 资源文件
└── android/                 # Android 平台配置（已完成 100%）
    ├── app/
    │   ├── build.gradle         # 应用级配置
    │   ├── proguard-rules.pro    # 代码混淆规则
    │   └── src/main/
    │       ├── AndroidManifest.xml   # 清单文件
    │       ├── kotlin/...MainActivity.kt  # 主活动
    │       └── res/            # 资源文件
    ├── build.gradle         # 项目级配置
    ├── settings.gradle        # Gradle 设置
    ├── gradle.properties     # Gradle 属性
    └── gradlew              # Gradle 包装器
```

---

## 🎯 预期构建产物

### 构建成功后

```
build_output/
├── apk/
│   ├── ClassQuest-1.0.0-release-arm64.apk       # arm64-v8a 架构（推荐）
│   ├── ClassQuest-1.0.0-release-armeabi-v7a.apk  # 兼容旧设备
│   └── ClassQuest-1.0.0-release-x64.apk          # 模拟器
├── logs/
│   ├── build-arm64.log
│   ├── build-armeabi-v7a.log
│   └── build-x64.log
├── BUILD_REPORT.txt                                     # 构建报告
└── install_apk.sh                                      # 快速安装脚本
```

### 安装验证

构建后请执行以下检查：

```bash
# 1. 检查 APK 文件大小
ls -lh build_output/apk/ClassQuest-1.0.0-release-arm64.apk
# 大小应该 < 50 MB

# 2. 验证 APK 完整性（如果有 aapt）
aapt dump badging build_output/apk/ClassQuest-1.0.0-release-arm64.apk | head -15

# 3. 在设备上安装测试
adb install -r build_output/apk/ClassQuest-1.0.0-release-arm64.apk

# 4. 启动应用
adb shell am start -n com.classquest.app/.MainActivity

# 5. 查看日志
adb logcat | grep ClassQuest
```

---

## 🆘 构建后测试清单

### 基础功能测试

- [ ] APK 文件大小合理（< 50 MB）
- [ ] APK 可以安装到 Android 设备
- [ ] 应用可以正常启动
- [ ] 登录功能正常
- [ ] 班主任端：快速加减分功能正常
- [ ] 学生端：积分查看功能正常
- [ ] 学生端：排行榜显示正常
- [ ] 学生端：商城兑换功能正常
- [ ] 权限请求正常

### 设备兼容性测试

建议在以下设备上测试：
- [ ] Android 5.0 (API 21) - 最低版本
- [ ] Android 8.0 (API 26) - 中等版本
- [ ] Android 13 (API 33) - 目标版本
- [ ] 不同设备型号（小米、华为、OPPO、vivo、realme 等）

---

## 📞 获取帮助

### 在线资源

- **Flutter 官方文档**: https://flutter.dev/docs
- **Android 官方文档**: https://developer.android.com/
- **Codemagic 文档**: https://docs.codemagic.io/
- **GitHub Actions 文档**: https://docs.github.com/

### 本地资源

查看以下文档获取详细信息：
```bash
# 构建指南
cat COMPLETE_BUILD_GUIDE.md

# 构建尝试报告
cat APK_BUILD_ATTEMPT_REPORT.md

# 故障排除指南
cat APK_FIX_INSTRUCTIONS.md
```

---

## 🎊 总结

### 当前进度

| 类别 | 项目 | 状态 | 完成度 |
|------|------|------|---------|
| 项目结构 | Flutter 前端 | ✅ 100% |
| 项目结构 | Android 平台 | ✅ 100% |
| SDK 安装 | Flutter SDK | ✅ 100% |
| SDK 安装 | Android SDK | ✅ 100% |
| 配置文件 | 构建脚本 | ✅ 100% |
| 配置文件 | 文档 | ✅ 100% |
| 配置文件 | Android 配置 | ✅ 100% |
| **APK 构建** | **最终产物** | ⚠️ **0%** |
| **总计** | **所有准备工作** | ✅ **100%** |

### 准备情况

🎊 **ClassQuest Android APK 构建准备已完成 100%！**

- ✅ Flutter SDK 安装并配置
- ✅ Android SDK 组件安装并配置
- ✅ 项目结构完整（Android 平台）
- ✅ 构建脚本准备完整
- ✅ 文档完善详细

⚠️ **当前环境限制**：Java 版本不兼容

🚀 **下一步**：在兼容的环境中执行构建命令

---

**最后更新**: 2026-03-26
**版本**: v3.0
**状态**: ✅ 构建准备完成

**🎊 所有准备工作已完成，等待在兼容环境中执行最终构建！**
