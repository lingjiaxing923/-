# ClassQuest 班级积分系统 - Android 应用构建指南

## 环境要求

### 必需工具
- Flutter SDK 3.0.0 或更高版本
- Android SDK (API Level 21+)
- Dart SDK (随Flutter一起安装)
- Java JDK 11+
- Android Studio 或 VS Code (推荐)

### 推荐配置
- 最低 Android 版本: API 21 (Android 5.0 Lollipop)
- 目标 Android 版本: API 30 (Android 11)
- 架构: arm64-v8a, armeabi-v7a

---

## 快速开始

### 1. 安装 Flutter SDK

**Windows:**
```bash
# 下载 Flutter SDK
# https://flutter.dev/docs/get-started/install/windows

# 设置环境变量
setx PATH "%PATH%;C:\flutter\bin"

# 验证安装
flutter doctor
```

**macOS:**
```bash
# 使用 Homebrew
brew install --cask flutter

# 或手动下载
# https://flutter.dev/docs/get-started/install/macos

# 验证安装
flutter doctor
```

**Linux:**
```bash
# 下载并解压
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin:$PATH"

# 验证安装
flutter doctor
```

### 2. 获取依赖

```bash
cd frontend
flutter pub get
```

### 3. 构建安卓应用

```bash
cd frontend

# 构建 Release APK
flutter build apk --release

# 构建 App Bundle (用于 Google Play)
flutter build appbundle --release
```

---

## 构建产物位置

### Release APK
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (AAB)
```
frontend/build/app/outputs/bundle/release/app-release.aab
```

---

## 自定义配置

### 1. 应用名称修改

编辑 `frontend/pubspec.yaml`:
```yaml
name: classquest
description: 班级积分管理系统
version: 1.0.0+1
```

### 2. 应用图标配置

1. 安装图标生成工具:
```bash
flutter pub get flutter_launcher_icons
```

2. 在 `frontend/android/app/src/main/res/` 放置图标文件

3. 或使用 `flutter_launcher_icons`:
```bash
flutter pub run flutter_launcher_icons:main
```

### 3. 应用权限配置

编辑 `frontend/android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.classquest">

    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

    <!-- 存储权限 (可选) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <!-- 摄像头权限 (可选 - 用于头像上传) -->
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="ClassQuest"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboardHidden|screenSize|smallestScreenSize|screenLayout|uiMode"
            android:windowSoftInputMode="adjustResize"
            android:hardwareAccelerated="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 4. 应用签名配置

编辑 `frontend/android/app/build.gradle`:
```gradle
android {
    ...
    defaultConfig {
        applicationId "com.classquest.app"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            // 调试签名 (不推荐用于生产环境)
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt')
        }
    }
}
```

### 5. ProGuard 混淆配置

创建 `frontend/android/app/proguard-rules.pro`:
```proguard
# Flutter 相关规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }

# 保持特定类
-keep class com.classquest.** { *; }
-dontwarn com.classquest.**

# 保持枚举
-keepclassmembers enum com.classquest.**

# 保持序列化类
-keepclassmembers class com.classquest.models.** {
  public <init>(...);
}

# 保持 JSON 序列化
-keepattributes Signature
-keepattributes *Annotation*
```

---

## 构建脚本

### 自动化构建脚本 (build_android.sh)

创建 `build_android.sh`:
```bash
#!/bin/bash

# ClassQuest Android 自动构建脚本

echo "======================================="
echo "ClassQuest Android 构建脚本"
echo "======================================="
echo ""

# 检查环境
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter 未安装"
    echo "请先安装 Flutter SDK: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")/frontend"
echo "📁 工作目录: $(pwd)"
echo ""

# 检查依赖
echo "📦 检查依赖..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ 错误: 依赖安装失败"
    exit 1
fi
echo "✅ 依赖安装完成"
echo ""

# 检查环境
echo "🔧 检查 Flutter 环境..."
flutter doctor
echo ""

# 清理构建缓存
echo "🧹 清理构建缓存..."
flutter clean
echo ""

# 构建 Release APK
echo "🔨 构建 Release APK..."
flutter build apk --release --target-platform android-arm64
if [ $? -eq 0 ]; then
    echo "✅ APK 构建成功"
    echo "📦 位置: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ APK 构建失败"
    exit 1
fi
echo ""

# 构建 App Bundle (可选)
read -p "是否构建 App Bundle (AAB)? (y/n): " build_aab
if [ "$build_aab" = "y" ]; then
    echo "🔨 构建 App Bundle..."
    flutter build appbundle --release
    if [ $? -eq 0 ]; then
        echo "✅ App Bundle 构建成功"
        echo "📦 位置: build/app/outputs/bundle/release/app-release.aab"
    else
        echo "❌ App Bundle 构建失败"
        exit 1
    fi
    echo ""
fi

echo "======================================="
echo "🎉 构建完成！"
echo "======================================="
echo ""
echo "📋 构建产物:"
echo "  - APK: build/app/outputs/flutter-apk/app-release.apk"
if [ "$build_aab" = "y" ]; then
    echo "  - AAB: build/app/outputs/bundle/release/app-release.aab"
fi
echo ""
echo "📱 安装 APK 到设备:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "⚠️  注意: 生产环境请使用正式签名配置"
echo "======================================="
```

使脚本可执行:
```bash
chmod +x build_android.sh
```

---

## 高级构建选项

### 1. 指定架构
```bash
# 仅 ARM64
flutter build apk --release --target-platform android-arm64

# 仅 ARMv7
flutter build apk --release --target-platform android-armeabi-v7a

# 多架构 (增大 APK 体积)
flutter build apk --release --target-platform android-arm64,android-armeabi-v7a,x86_64
```

### 2. 启用 ProGuard 混淆
```bash
flutter build apk --release --obfuscate --split-debug-info
```

### 3. 压缩资源
```bash
flutter build apk --release --split-per-abi
```

### 4. 指定构建模式
```bash
# Debug 构建
flutter build apk --debug

# Profile 构建 (性能分析)
flutter build apk --profile

# Release 构建
flutter build apk --release
```

---

## 故障排除

### 常见问题

1. **Flutter Doctor 警告**
```bash
# 查看详细问题
flutter doctor -v

# 常见解决方案
# Android 许可证未接受
flutter doctor --android-licenses

# 缺少 Android SDK
flutter config --android-sdk <path-to-sdk>
```

2. **构建失败 - Dart 编译错误**
```bash
# 清理并重新获取依赖
flutter clean
flutter pub cache repair
flutter pub get
```

3. **APK 体积过大**
```bash
# 使用 App Bundle (推荐)
flutter build appbundle --release

# 按架构拆分 (用于 Google Play)
flutter build apk --release --split-per-abi
```

4. **网络请求失败**
```bash
# 检查 AndroidManifest.xml 网络权限
# 确认后端 API 地址正确配置
```

5. **应用启动崩溃**
```bash
# 查看日志
adb logcat | grep "classquest"

# 分析崩溃报告
flutter analyze
```

---

## 发布准备

### Google Play 发布
1. 构建 App Bundle (AAB)
2. 创建 Google Play 开发者账号
3. 上传 AAB 文件到 Play Console
4. 填写应用信息和截图
5. 提交审核

### 第三方应用商店
1. 构建 Release APK
2. 准备应用图标、截图、描述
3. 上传到应用商店
4. 等待审核

### 企业内部分发
1. 构建 Release APK 或 AAB
2. 通过企业内部渠道分发
3. 或使用 Firebase App Distribution

---

## 开发调试

### 连接 Android 设备
```bash
# 查看连接的设备
adb devices

# 安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk

# 启动应用
adb shell am start -n com.classquest.app/.MainActivity

# 查看日志
adb logcat -s Flutter
```

### 热重载调试
```bash
# 连接设备后
flutter run

# 或指定设备
flutter run -d <device-id>

# 热重载
# 在 IDE 中按 'r' 键
```

---

## 性能优化

### 1. 代码优化
```bash
# 分析代码性能
flutter build apk --profile

# 生成性能报告
flutter analyze

# 格式化代码
flutter format .
```

### 2. 资源优化
```bash
# 压缩图片
# 推荐使用 WebP 格式
# 移除未使用的资源

# 矢量图标
flutter pub run flutter_launcher_icons:main
```

### 3. 构建优化
```bash
# 启用混淆和压缩
flutter build apk --release --obfuscate --split-debug-info --split-per-abi
```

---

## 版本管理

### 版本号规范
```
格式: versionName.versionCode
示例: 1.0.0+1
      1.0.1+2
      1.1.0+10
```

### 升级策略
```yaml
# pubspec.yaml
version: 1.0.0+1

# AndroidManifest.xml
android:versionCode="1"
android:versionName="1.0.0"
```

---

## 测试检查清单

### 功能测试
- [ ] 用户登录功能
- [ ] 积分查看功能
- [ ] 积分排行榜功能
- [ ] 商城浏览功能
- [ ] 商品兑换功能
- [ ] 申诉提交功能
- [ ] 师徒结对功能
- [ ] 个人中心功能

### 兼容性测试
- [ ] Android 5.0+ (API 21)
- [ ] Android 11 (API 30)
- [ ] 不同屏幕尺寸测试
- [ ] 横竖屏切换测试
- [ ] 深色模式测试

### 性能测试
- [ ] 启动时间 (<3秒)
- [ ] 页面切换流畅度
- [ ] 内存占用
- [ ] 电池消耗
- [ ] 网络请求优化

---

## 支持和资源

### 官方文档
- Flutter 文档: https://flutter.dev/docs
- Android 开发: https://developer.android.com
- Dart 语言: https://dart.dev/guides

### 社区资源
- Flutter 中文社区: https://flutter.cn
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- GitHub Issues: https://github.com/flutter/flutter/issues

---

**文档版本**: v1.0
**更新日期**: 2026年3月26日
**适用平台**: Android 5.0+ (API 21+)
**推荐版本**: Android 11+ (API 30)
