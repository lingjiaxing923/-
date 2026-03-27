# GitHub Actions 构建故障排除指南

## 常见构建问题及解决方案

### 问题1: local.properties缺失

**错误信息：**
```
flutter.sdk not set in local.properties
```

**原因：**
local.properties文件在.gitignore中被忽略，GitHub Actions环境没有该文件。

**解决方案：**
✅ 已修复 - 在GitHub Actions工作流中添加了自动创建local.properties的步骤：

```yaml
- name: Create local.properties
  working-directory: ./classquest/frontend/android
  run: |
    echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
    echo "flutter.buildMode=release" >> local.properties
    echo "flutter.versionName=1.0.0" >> local.properties
    echo "flutter.versionCode=1" >> local.properties
```

### 问题2: Flutter Gradle Plugin版本不兼容

**错误信息：**
```
Error: Your project's Android Gradle Plugin version is lower than Flutter's minimum supported version
```

**原因：**
Flutter Gradle Plugin版本与Flutter SDK版本不匹配。

**解决方案：**
更新`settings.gradle`中的AGP版本：
```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.6.0" apply false
}
```

### 问题3: Kotlin版本冲突

**错误信息：**
```
Error: Your project's Kotlin version is lower than Flutter's minimum supported version
```

**原因：**
Kotlin版本与Flutter插件要求的版本不匹配。

**解决方案：**
更新`build.gradle`中的Kotlin版本：
```gradle
buildscript {
    ext.kotlin_version = '2.3.0'
    // ...
}
```

### 问题4: Gradle下载失败

**错误信息：**
```
Exception in thread "main" java.io.FileNotFoundException
```

**原因：**
Gradle版本不兼容或下载网络问题。

**解决方案：**
1. 更新`gradle-wrapper.properties`中的Gradle版本：
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip
```

2. 或者在GitHub Actions中使用缓存的Gradle

### 问题5: 依赖下载超时

**错误信息：**
```
Gradle threw an error while downloading artifacts from the network
```

**原因：**
网络问题或依赖服务器响应慢。

**解决方案：**
增加GitHub Actions超时时间：
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 90  # 增加到90分钟
```

## 验证构建配置

使用提供的验证脚本：

```bash
cd classquest/frontend
./verify-build.sh
```

该脚本会检查：
- ✅ Flutter安装
- ✅ Java版本
- ✅ Android SDK配置
- ✅ local.properties
- ✅ Gradle wrapper
- ✅ Flutter依赖
- ✅ 代码分析

## 本地调试构建问题

### 1. 清理构建缓存

```bash
cd classquest/frontend
flutter clean
cd android
./gradlew clean
```

### 2. 重新获取依赖

```bash
flutter pub get
flutter pub upgrade
```

### 3. 检查Flutter环境

```bash
flutter doctor -v
```

### 4. 测试本地构建

```bash
flutter build apk --debug
```

## GitHub Actions调试

### 查看详细日志

1. 进入GitHub Actions页面
2. 点击失败的构建运行
3. 展开失败的步骤查看详细日志
4. 查找错误信息（搜索"Error"、"Failure"、"exception"）

### 重新运行失败的构建

1. 进入失败的构建页面
2. 点击右上角"Re-run all jobs"
3. 或者使用API：
   ```
   gh run list  # 列出运行
   gh run rerun <run-id>
   ```

## 当前配置状态

### ✅ 已修复的问题

1. **local.properties缺失**
   - 在工作流中添加自动创建步骤
   - 使用环境变量而非硬编码路径

2. **Flutter Gradle Plugin版本**
   - 更新到8.6.0
   - 与Flutter 3.19.0+兼容

3. **Kotlin版本**
   - 更新到2.3.0
   - 匹配插件要求

4. **Gradle版本**
   - 更新到8.7
   - 支持Java 17

### 📋 配置文件版本

- **Flutter**: 3.19.0
- **Java**: 17
- **Gradle**: 8.7
- **Android Gradle Plugin**: 8.6.0
- **Kotlin**: 2.3.0

## 获取帮助

### GitHub Actions文档
- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Flutter构建文档](https://docs.flutter.dev/deployment/android)

### 常见问题

**Q: 构建时间过长？**
A: 首次构建需要下载依赖（5-15分钟），后续构建有缓存会更快（2-5分钟）。

**Q: 如何查看构建日志？**
A: 在GitHub Actions页面点击具体运行，然后展开步骤查看详细输出。

**Q: 本地构建成功但CI失败？**
A: 检查本地环境和CI环境的差异，特别是环境变量和路径配置。

**Q: 如何配置应用签名？**
A: 创建keystore文件并在工作流中添加签名步骤，参考Flutter官方文档。

## 联系支持

如果问题仍然存在：
1. 查看GitHub Issues: https://github.com/lingjiaxing923/-/issues
2. 检查构建日志中的详细错误
3. 验证本地构建配置：`./verify-build.sh`

---

**提示：大多数构建问题都与依赖版本和配置路径相关，请首先检查这两个方面。**
