# ClassQuest Android 应用 - 快速开始

## 📱 Android 应用构建文件

本目录包含 ClassQuest 班级积分系统 Android 应用构建所需的所有文件和脚本。

---

## 📋 文件说明

| 文件名 | 说明 | 用途 |
|--------|------|------|
| `ANDROID_BUILD_GUIDE.md` | 完整的Android构建指南 | 详细的构建、配置、发布指南 |
| `build_android.sh` | 自动化构建脚本 | 一键构建APK/AAB文件 |
| `AndroidManifest.xml` | Android应用清单文件 | 配置应用权限和组件 |
| `proguard-rules.pro` | 代码混淆规则 | 保护应用代码安全 |
| `KEYSTORE_SETUP.md` | 密钥库签名配置指南 | 创建和管理应用签名密钥 |

---

## 🚀 快速开始

### 前置条件检查

```bash
# 1. 检查 Flutter 是否安装
flutter --version

# 2. 检查 Android SDK 是否可用
flutter doctor --android

# 3. 检查连接的设备
adb devices
```

### 方法一: 使用自动构建脚本 (推荐)

```bash
# 1. 进入项目目录
cd /workspaces/-/classquest

# 2. 给脚本执行权限
chmod +x build_android.sh

# 3. 运行构建脚本
./build_android.sh

# 4. 按提示选择构建类型:
#    1) Release APK - 直接安装到设备
#    2) App Bundle - 用于 Google Play 发布
#    3) Debug APK - 开发调试
#    4) 全部构建
```

### 方法二: 手动构建

```bash
# 1. 进入前端项目目录
cd frontend

# 2. 获取依赖
flutter pub get

# 3. 构建 Release APK
flutter build apk --release

# 4. 构建 App Bundle (用于 Google Play)
flutter build appbundle --release

# 5. 查看构建产物
ls -lh build/app/outputs/
```

---

## 📦 构建产物位置

### APK 文件
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```
- 用途: 直接安装到 Android 设备
- 目标: 第三方应用商店、企业内部分发

### App Bundle (AAB) 文件
```
frontend/build/app/outputs/bundle/release/app-release.aab
```
- 用途: 提交到 Google Play 商店
- 目标: Google Play 发布

---

## 📱 安装到设备

### 使用 ADB 安装
```bash
# 1. 连接 Android 设备（启用 USB 调试）
# 2. 查看连接的设备
adb devices

# 3. 安装 APK
adb install -r frontend/build/app/outputs/flutter-apk/app-release.apk

# 4. 启动应用
adb shell am start -n com.classquest.app/.MainActivity
```

### 手动安装
1. 将 APK 文件复制到设备
2. 在设备上打开文件管理器
3. 找到 APK 文件并点击安装

---

## 🔧 配置文件部署

### 1. AndroidManifest.xml
将 `AndroidManifest.xml` 部署到:
```
frontend/android/app/src/main/AndroidManifest.xml
```

### 2. proguard-rules.pro
将 `proguard-rules.pro` 部署到:
```
frontend/android/app/proguard-rules.pro
```

### 3. 密钥库配置
按照 `KEYSTORE_SETUP.md` 指南创建并配置密钥库:
```
1. 创建密钥库文件
2. 配置 build.gradle 中的签名设置
3. 不要将密钥库提交到版本控制
```

---

## 🎯 发布流程

### Google Play 发布
1. **构建 App Bundle**
   ```bash
   cd frontend
   flutter build appbundle --release
   ```

2. **准备应用资料**
   - 应用图标 (512x512)
   - 应用截图 (手机和tablet)
   - 应用描述 (简短+详细)
   - 隐私政策 URL
   - 内容分级问卷

3. **创建 Google Play 开发者账号**
   - 访问 https://play.google.com/console
   - 支付 $25 美元注册费
   - 创建新应用

4. **上传应用包**
   - 在 Play Console 创建新应用
   - 上传 .aab 文件
   - 填写应用信息

5. **提交审核**
   - 填写内容分级问卷
   - 提交审核
   - 等待审核 (通常1-3天)

### 第三方应用商店
1. **应用宝** (腾讯)
   - 网站: https://app.qq.com/
   - 注册开发者账号
   - 上传 APK 和资料
   - 等待审核

2. **小米应用商店**
   - 网站: https://dev.mi.com/distribute
   - 注册开发者账号
   - 上传 APK 和资料
   - 等待审核

3. **华为应用市场**
   - 网站: https://appgallery.huawei.com/
   - 注册开发者账号
   - 上传 APK 和资料
   - 等待审核

### 企业内部分发
1. **通过内网分发**
   - 将 APK 上传到公司内网
   - 员工下载安装

2. **使用 Firebase App Distribution**
   - 访问 https://console.firebase.google.com/
   - 创建项目并上传 APK
   - 邀请测试人员下载

3. **通过企业微信/钉钉分发**
   - 创建应用分发二维码
   - 扫码下载安装

---

## 🐛 调试和测试

### 查看日志
```bash
# 实时查看应用日志
adb logcat | grep "classquest"

# 保存日志到文件
adb logcat > app_log.txt

# 查看崩溃日志
adb logcat -b crash
```

### 性能分析
```bash
# 构建性能分析版本
flutter build apk --profile

# 分析性能报告
flutter analyze
```

### 热重载开发
```bash
# 连接设备后运行
flutter run

# 指定设备运行
flutter run -d <device-id>

# 热重载 (开发时)
# 在 IDE 中按 'r' 键
```

---

## 📊 应用信息

### 应用元数据
- **应用名称**: ClassQuest - 班级积分管理系统
- **包名**: com.classquest.app
- **最低版本**: Android 5.0 (API 21)
- **目标版本**: Android 11 (API 30)
- **架构支持**: arm64-v8a, armeabi-v7a, x86_64

### 核心功能
- 用户登录认证
- 积分查看和管理
- 积分排行榜
- 商城浏览和兑换
- 申诉提交和查看
- 师徒结对
- 个人成长记录
- 实时通知
- 语音搜索

---

## 🔒 安全注意事项

### 开发阶段
- ⚠️ Debug 签名仅用于开发测试
- ⚠️ 不要将 Debug 版本发布到应用商店
- ⚠️ Debug 版本可能包含敏感信息

### 生产发布
- ✅ 使用正式密钥库签名
- ✅ 启用代码混淆 (ProGuard)
- ✅ 移除调试代码和日志
- ✅ 验证所有权限配置
- ✅ 测试 APK 安装和运行

### 密钥管理
- 🔐 不要将密钥库文件提交到版本控制
- 🔐 使用强密码保护密钥库
- 🔐 定期备份密钥库文件
- 🔐 制定密钥轮换策略

---

## 📞 技术支持

### 常见问题
**Q: Flutter 构建失败怎么办？**
A: 运行 `flutter doctor` 检查环境，查看详细错误

**Q: ADB 无法连接设备？**
A:
1. 确认设备已启用 USB 调试
2. 确认设备上已授权电脑调试
3. 尝试不同的 USB 线缆和端口

**Q: 应用安装后无法打开？**
A:
1. 检查应用签名是否正确
2. 查看设备兼容性
3. 检查应用权限配置

**Q: 如何更新已发布的应用？**
A:
1. 更新版本号 (versionCode)
2. 使用相同密钥库重新签名
3. 提交新版本到应用商店

### 获取帮助
- **Flutter 官方文档**: https://flutter.dev/docs
- **Android 开发者文档**: https://developer.android.com
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/flutter
- **GitHub Issues**: https://github.com/flutter/flutter/issues

---

## 📝 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-03-26 | 初始版本，核心功能完成 |

---

**文档版本**: v1.0
**更新日期**: 2026年3月26日
**项目状态**: 核心开发完成，待生产测试
**构建状态**: 可构建 (需要Flutter SDK)
