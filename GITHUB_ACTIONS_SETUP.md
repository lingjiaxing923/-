# GitHub Actions 构建配置完成

## 概述

已为您的班级管理系统（ClassQuest）配置了 GitHub Actions 自动构建工作流，可以自动构建 Android APK 和 App Bundle。

## 已创建的文件

```
.github/
├── workflows/
│   ├── build-android-apk.yml          # 基础构建工作流
│   └── build-android-complete.yml      # 完整构建工作流（含测试）
├── README.md                         # GitHub Actions 使用说明
```

## 使用步骤

### 1. 提交工作流文件

将 GitHub Actions 工作流文件提交到您的仓库：

```bash
cd /workspaces/-

# 查看新创建的文件
git status

# 添加 GitHub Actions 配置文件
git add .github/

# 提交
git commit -m "Add GitHub Actions workflow for Android APK builds"

# 推送到远程仓库
git push origin main
```

### 2. 手动触发构建

推送后，您可以手动触发构建：

1. 访问您的 GitHub 仓库
2. 点击 "Actions" 标签页
3. 选择 "Build Android Complete Package" 工作流
4. 点击 "Run workflow" 按钮
5. 在弹出框中选择：
   - **Build type**: `release` 或 `debug`
6. 点击 "Run workflow" 开始构建

### 3. 下载构建产物

构建完成后（通常需要 5-10 分钟）：

1. 在 Actions 页面找到刚刚完成的构建
2. 点击进入该次运行
3. 滚动到页面底部的 "Artifacts" 区域
4. 点击下载：
   - `android-apk-release` - 发布版 APK（可直接安装）
   - `android-appbundle-release` - App Bundle（用于 Google Play 发布）
   - `debug-apk` - 调试版 APK

## 自动触发构建

以下情况会自动触发构建：

### build-android-apk.yml（基础）
- ✅ 推送代码到 `main` 或 `master` 分支
- ✅ 创建 Pull Request
- ✅ 手动触发

### build-android-complete.yml（完整）
- ✅ 创建版本标签（如 `git tag v1.0.0`）
- ✅ 推送到 `main` 分支
- ✅ 手动触发

## 构建产物保留时间

| 工作流 | 产物保留时间 |
|---------|-------------|
| 基础构建 | 30 天 |
| 完整构建 | 90 天 |
| Debug 构建 | 7 天 |

## 构建信息

每次构建都会生成以下信息：
- 构建时间
- Flutter 版本
- 构建类型（debug/release）
- APK 文件大小

## 查看构建日志

如需查看详细构建日志：
1. 进入 Actions 页面
2. 点击具体的构建运行
3. 点击各个步骤查看详细输出

## 本地构建（备选方案）

如需本地构建，执行：

```bash
cd classquest/frontend
flutter build apk --release

# APK 位置
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## 注意事项

1. **构建时间**：首次构建可能需要 10-15 分钟（需要下载 Flutter SDK 和依赖）
2. **磁盘空间**：GitHub Actions 提供足够的构建空间
3. **版本兼容性**：工作流已配置为使用 Flutter 3.19.0 和 Java 17
4. **产物过期**：记得在过期前下载需要的产物

## 下一步

1. **提交代码**：使用上面的命令提交 GitHub Actions 配置
2. **触发构建**：手动触发第一次构建测试
3. **验证产物**：下载并测试生成的 APK
4. **版本管理**：使用 Git 标签管理版本（如 `v1.0.0`）

## 常见问题

### Q: 构建失败怎么办？
A: 查看构建日志中的错误信息，通常是：
- 依赖冲突 → 运行 `flutter pub upgrade`
- 代码错误 → 运行 `flutter analyze` 修复

### Q: 如何配置应用签名？
A: 需要添加密钥文件和签名配置，参考 Flutter 官方文档

### Q: 可以构建 iOS 版本吗？
A: 需要 macOS runner，GitHub Actions 支持 macOS，需要额外配置

## 支持与帮助

如有问题，请查看：
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Flutter 构建文档](https://docs.flutter.dev/deployment/android)
- 工作流日志中的具体错误信息
