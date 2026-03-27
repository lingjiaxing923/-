# GitHub Actions 工作流

本项目使用 GitHub Actions 自动构建 Android APK 和 App Bundle。

## 工作流说明

### 1. build-android-apk.yml
**触发条件：**
- 推送到 main/master 分支，且修改了 classquest/frontend/ 目录
- 创建 Pull Request 到 main/master 分支
- 手动触发

**构建产物：**
- APK (release)
- App Bundle (release)

**产物保留时间：** 30天

### 2. build-android-complete.yml
**触发条件：**
- 推送标签 (如 v1.0.0)
- 推送到 main 分支
- 手动触发（可选择 debug 或 release 构建）

**构建产物：**
- APK (debug/release)
- App Bundle (debug/release)

**产物保留时间：** 90天

**包含步骤：**
- 代码分析 (flutter analyze)
- 单元测试 (flutter test)
- APK 构建
- App Bundle 构建
- 构建信息生成

## 使用方法

### 手动触发构建

1. 进入 GitHub 仓库的 Actions 标签页
2. 选择 "Build Android Complete Package" 工作流
3. 点击 "Run workflow"
4. 选择构建类型（debug 或 release）
5. 点击 "Run workflow" 开始构建

### 下载构建产物

构建完成后：
1. 进入该次运行的 Actions 页面
2. 滚动到页面底部的 "Artifacts" 部分
3. 点击下载需要的产物：
   - `android-apk-release` - 发布版 APK
   - `android-appbundle-release` - 发布版 App Bundle
   - `debug-apk` - 调试版 APK

### 自动构建设置

如需修改触发条件，编辑 `.github/workflows/` 目录下的对应文件。

## 本地构建

如需本地构建，请确保已安装 Flutter SDK：

```bash
cd classquest/frontend
flutter build apk --release
```

APK 输出位置：`build/app/outputs/flutter-apk/app-release.apk`

## 签名配置

如需配置签名，请创建 `classquest/frontend/android/key.properties` 和 `.jks` 密钥文件，并在工作流中添加签名步骤。

参考：https://docs.flutter.dev/deployment/android#signing-the-app
