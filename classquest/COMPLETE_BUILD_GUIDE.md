# ClassQuest Android APK 完整构建指南

## 📋 概述

本指南提供了构建 ClassQuest Android APK 的完整步骤，包括本地构建和在线构建两种方法。

---

## 🔧 方法一：本地构建（推荐）

### 前置要求

#### 1. 安装 Flutter SDK

**Linux:**
```bash
# 下载 Flutter SDK
cd /opt
sudo wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.5-stable.tar.xz

# 解压
sudo tar xf flutter_linux_3.16.5-stable.tar.xz

# 添加到 PATH
export PATH="$PATH:/opt/flutter/bin"

# 验证安装
flutter --version
```

**macOS:**
```bash
# 使用 Homebrew 安装
brew install --cask flutter

# 验证安装
flutter --version
```

**Windows:**
1. 下载 Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. 解压到 `C:\flutter`
3. 添加到系统 PATH: `C:\flutter\bin`
4. 重启命令提示符并运行: `flutter --version`

#### 2. 安装 Android SDK 和工具

```bash
# 运行 Flutter doctor 检查环境
flutter doctor

# 安装 Android Studio (包含 Android SDK)
# 下载地址: https://developer.android.com/studio

# 接受 Android 许可
flutter doctor --android-licenses

# 再次检查环境
flutter doctor --android
```

#### 3. 安装 Java

Flutter 包含 OpenJDK，但如果需要单独安装：

```bash
# Linux
sudo apt update
sudo apt install openjdk-17-jdk

# macOS
brew install openjdk@17

# Windows
# 下载并安装 JDK 17: https://adoptium.net/
```

### 构建步骤

#### 方式1：使用自动化脚本（推荐）

```bash
# 1. 进入项目根目录
cd /path/to/classquest

# 2. 运行构建脚本
./build_apk_complete.sh

# 3. 等待构建完成
# 构建产物将保存在 build_output/apk/ 目录
```

#### 方式2：手动构建

```bash
# 1. 进入 frontend 目录
cd frontend

# 2. 清理旧构建
flutter clean

# 3. 获取依赖
flutter pub get

# 4. 检查环境
flutter doctor

# 5. 构建 Release APK (推荐架构)
flutter build apk --release --target-platform android-arm64

# 6. 或者构建通用 APK
flutter build apk --release

# 7. 查找构建产物
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### 安装测试

#### 使用 ADB 安装

```bash
# 1. 连接 Android 设备并启用 USB 调试
# 2. 检查设备连接
adb devices

# 3. 使用构建脚本中的快速安装工具
cd build_output
./install_apk.sh

# 4. 或者手动安装
adb install -r ClassQuest-1.0.0-release-arm64.apk

# 5. 启动应用
adb shell am start -n com.classquest.app/.MainActivity
```

#### 手动安装

1. 将 APK 文件复制到 Android 设备
2. 在设备文件管理器中找到 APK
3. 点击 APK 文件进行安装
4. 如果提示"未知来源"，在设置中允许

---

## ☁️ 方法二：在线构建服务

### 1. Codemagic（推荐）

**优点：**
- 免费 CI/CD 支持
- 自动化构建流程
- 支持多个目标平台
- 完整的日志输出

**步骤：**

1. 注册账号: https://codemagic.io/
2. 连接 GitHub 仓库
3. 配置构建设置:
   ```yaml
   # codemagic.yaml
   workflows:
     default:
       name: Build Android APK
       triggering:
         events:
           - push
         branch_patterns:
           - pattern: main
       scripts:
         - cd frontend
         - flutter pub get
         - flutter build apk --release
       artifacts:
         - frontend/build/app/outputs/flutter-apk/*.apk
   ```
4. 开始构建
5. 下载生成的 APK

### 2. GitHub Actions

**步骤：**

1. 创建 `.github/workflows/build.yml`:
   ```yaml
   name: Build Android APK

   on:
     push:
       branches: [ main ]

   jobs:
     build:
       runs-on: ubuntu-latest

       steps:
       - uses: actions/checkout@v3

       - name: Setup Flutter
         uses: subosito/flutter-action@v2
         with:
           flutter-version: '3.16.5'
           channel: 'stable'

       - name: Build APK
         run: |
           cd frontend
           flutter pub get
           flutter build apk --release

       - name: Upload APK
         uses: actions/upload-artifact@v3
         with:
           name: release-apk
           path: frontend/build/app/outputs/flutter-apk/*.apk
   ```

2. 提交代码到 GitHub
3. 自动触发构建
4. 在 Actions 页面下载 APK

### 3. Bitrise

**步骤：**

1. 注册账号: https://bitrise.io/
2. 连接 GitHub 仓库
3. 选择 Flutter 模板
4. 配置构建步骤:
   - Install Flutter
   - Flutter Build APK
5. 开始构建

---

## 📊 构建产物说明

### 构建文件

| 文件名 | 说明 | 适用设备 |
|--------|------|----------|
| ClassQuest-1.0.0-release-arm64.apk | arm64-v8a 架构 | 现代设备（推荐） |
| ClassQuest-1.0.0-release-universal.apk | 通用架构 | 所有设备 |

### 文件大小

- arm64 APK: 约 15-25 MB
- 通用 APK: 约 20-35 MB

### 应用信息

- **包名**: com.classquest.app
- **版本**: 1.0.0 (versionCode: 1)
- **最低版本**: Android 5.0 (API 21)
- **目标版本**: Android 13 (API 33)
- **推荐架构**: arm64-v8a

---

## 🔍 故障排除

### 问题1: Flutter SDK 未找到

**解决方案：**
```bash
# 检查 Flutter 是否在 PATH 中
echo $PATH | grep flutter

# 如果没有，添加到 PATH
export PATH="$PATH:/opt/flutter/bin"

# 或者修改 ~/.bashrc 或 ~/.zshrc
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 问题2: Android SDK 未找到

**解决方案：**
```bash
# 运行 Flutter doctor 查看详细错误
flutter doctor

# 安装 Android SDK
# 方法1: 安装 Android Studio
# 方法2: 手动下载 Android SDK

# 接受许可
flutter doctor --android-licenses
```

### 问题3: 构建失败 - 依赖问题

**解决方案：**
```bash
# 清理并重新获取依赖
cd frontend
flutter clean
flutter pub get

# 检查依赖冲突
flutter pub deps
```

### 问题4: 构建失败 - 签名问题

**解决方案：**

Debug 构建使用自动生成的 debug.keystore，Release 构建需要配置签名：

1. 生成签名密钥：
```bash
keytool -genkey -v -keystore classquest-release.keystore -alias classquest -keyalg RSA -keysize 2048 -validity 10000
```

2. 配置签名（修改 `frontend/android/app/build.gradle`）：
```gradle
signingConfigs {
    release {
        storeFile file('classquest-release.keystore')
        storePassword 'your-password'
        keyAlias 'classquest'
        keyPassword 'your-password'
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### 问题5: APK 安装失败

**解决方案：**

1. 检查设备 Android 版本（需要 >= 5.0）
2. 检查设备存储空间
3. 检查是否允许安装未知来源
4. 验证 APK 文件完整性
5. 查看 ADB 日志: `adb logcat`

---

## 📋 构建检查清单

### 构建前检查

- [ ] Flutter SDK 已安装
- [ ] Android SDK 已安装
- [ ] Java 已安装
- [ ] `flutter doctor` 无错误
- [ ] 项目结构完整
- [ ] 依赖已更新

### 构建过程检查

- [ ] `flutter clean` 成功
- [ ] `flutter pub get` 成功
- [ ] `flutter build apk` 成功
- [ ] APK 文件生成
- [ ] 文件大小合理

### 构建后检查

- [ ] APK 文件完整
- [ ] APK 可安装
- [ ] 应用可启动
- [ ] 基本功能正常
- [ ] 权限请求正常

---

## 🚀 快速开始

### 最快路径（有 Flutter SDK）

```bash
# 1. 克隆项目
git clone <your-repo>
cd classquest

# 2. 运行构建脚本
./build_apk_complete.sh

# 3. 安装到设备
cd build_output
./install_apk.sh
```

### 最快路径（无 Flutter SDK）

使用在线构建服务：
1. 注册 Codemagic: https://codemagic.io/
2. 连接 GitHub 仓库
3. 配置自动构建
4. 下载生成的 APK

---

## 📚 相关文档

- `ANDROID_README.md` - 快速开始指南
- `ANDROID_BUILD_GUIDE.md` - 详细构建指南
- `APK_FIX_INSTRUCTIONS.md` - APK安装问题修复指南
- `build_output/BUILD_REPORT.txt` - 构建报告
- `frontend/android/app/build.gradle` - Android 构建配置
- `frontend/android/app/src/main/AndroidManifest.xml` - Android 清单文件

---

## 🆘 获取帮助

如果遇到问题：

1. 查看构建日志: `build_output/logs/`
2. 运行诊断工具: `./apk_fix_tool.sh`
3. 查看问题修复指南: `APK_FIX_INSTRUCTIONS.md`
4. 查看在线文档:
   - Flutter: https://flutter.dev/docs
   - Android: https://developer.android.com/
   - Codemagic: https://docs.codemagic.io/

---

## 📞 支持

- **项目主页**: [Your GitHub Repository]
- **问题反馈**: [Your GitHub Issues]
- **文档**: [Your Documentation]

---

**最后更新**: 2026-03-26
**版本**: v3.0
**状态**: ✅ 完整构建指南已准备

**🎊 ClassQuest Android APK 构建指南已准备就绪！**
