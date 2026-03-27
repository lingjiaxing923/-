#!/bin/bash

# ClassQuest Android 应用重新构建脚本
# 版本: v2.0
# 目标: 生成可安装的Release APK

echo "======================================="
echo "ClassQuest Android APK 重新构建"
echo "======================================="
echo ""
echo "📦 构建版本: v2.0"
echo "📦 构建目标: ClassQuest-1.0.0-release.apk"
echo ""

# 检查环境
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter SDK 未安装"
    echo ""
    echo "📋 请先安装 Flutter SDK:"
    echo "   Windows: https://flutter.dev/docs/get-started/install/windows"
    echo "   macOS: https://flutter.dev/docs/get-started/install/macos"
    echo "   Linux: https://flutter.dev/docs/get-started/install/linux"
    echo ""
    echo "📋 安装后返回本脚本执行"
    echo ""
    echo "⚠️  或者使用在线构建服务:"
    echo "   - Codemagic: https://codemagic.io/"
    echo "   - AppCenter: https://appcenter.ms/"
    echo "   - Buildkaste: https://buildkaste.com/"
    echo ""
    exit 1
fi

echo "✅ Flutter SDK 已安装"
echo ""

# 进入项目目录
cd frontend
echo "📁 当前工作目录: $(pwd)"
echo ""

# 清理旧构建
echo "🧹 清理旧构建缓存..."
flutter clean
if [ $? -ne 0 ]; then
    echo "❌ 清理失败"
    exit 1
fi
echo "✅ 清理完成"
echo ""

# 获取依赖
echo "📦 检查依赖..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ 依赖获取失败"
    exit 1
fi
echo "✅ 依赖获取完成"
echo ""

# 检查Flutter环境
echo "🔧 检查 Flutter 环境..."
flutter doctor --android
echo ""

# 构建配置
echo "🔨 开始构建..."
echo "构建类型: Release APK"
echo "目标平台: Android"
echo "最低版本: API 21 (Android 5.0)"
echo "目标架构: arm64-v8a (推荐)"
echo ""

# 构建Release APK
echo "📦 构建 Release APK (arm64-v8a)..."
flutter build apk --release --target-platform android-arm64
if [ $? -eq 0 ]; then
    echo "✅ Release APK 构建成功 (arm64-v8a)"
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(stat -f%s "$APK_PATH" 2>/dev/null || echo "unknown")
        echo "📦 文件大小: $((APK_SIZE / 1024 / 1024)) MB"
        echo "📦 文件位置: $APK_PATH"
        ls -lh "$APK_PATH"
    else
        echo "❌ APK 文件不存在"
    fi
else
    echo "❌ Release APK 构建失败 (arm64-v8a)"
fi
echo ""

# 构建arm32-v7a (兼容旧设备)
echo "📦 构建 Release APK (arm32-v7a)..."
flutter build apk --release --target-platform android-armeabi-v7a
if [ $? -eq 0 ]; then
    echo "✅ Release APK 构建成功 (arm32-v7a)"
else
    echo "❌ Release APK 构建失败 (arm32-v7a)"
fi
echo ""

# 构建x86_64 (模拟器)
echo "📦 构建 Release APK (x86_64)..."
flutter build apk --release --target-platform android-x64
if [ $? -eq 0 ]; then
    echo "✅ Release APK 构建成功 (x86_64)"
else
    echo "❌ Release APK 构建失败 (x86_64)"
fi
echo ""

# 检查构建产物
echo "📊 检查构建产物..."
BUILD_DIR="build/app/outputs/flutter-apk"

if [ -d "$BUILD_DIR" ]; then
    APK_COUNT=$(find "$BUILD_DIR" -name "*.apk" | wc -l)
    echo "✅ 发现 $APK_COUNT 个APK文件:"
    find "$BUILD_DIR" -name "*.apk" -exec ls -lh {} \;
    echo ""

    # 显示最新的APK
    LATEST_APK=$(find "$BUILD_DIR" -name "*.apk" -type f -printf '%T@ %t\n' | sort -n | tail -1)
    if [ -n "$LATEST_APK" ]; then
        echo "✅ 最新APK: $LATEST_APK"
        ls -lh "$LATEST_APK"
    else
        echo "❌ 未找到APK文件"
    fi
else
    echo "❌ 构建产物目录不存在"
fi
echo ""

# 验证APK
if [ -n "$LATEST_APK" ]; then
    echo "🔍 验证APK完整性..."
    if command -v aapt &> /dev/null; then
        aapt dump badging "$LATEST_APK" > /dev/null 2>&1 | head -10
        echo "✅ APK验证通过"
    else
        echo "⚠️ aapt工具未找到，跳过验证"
    fi
fi
echo ""

# 构建总结
echo "======================================="
echo "🎉 构建完成！"
echo "======================================="
echo ""
echo "📦 构建产物:"
echo "  - APK文件: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📱 安装说明:"
echo "  1. 将APK文件复制到Android设备"
echo "   2. 在设备文件管理器中找到APK"
echo "   3. 点击APK文件进行安装"
echo "   4. 如果提示"未知来源"，在设置中允许"
echo ""
echo "🧪 测试建议:"
echo "  - 在多个Android设备上测试安装"
echo "  - 查看应用日志: adb logcat"
echo "  - 验证核心功能是否正常"
echo "  - 测试权限请求是否正常"
echo ""
echo "⚠️ 注意:"
echo "  - 这是Release版本，包含ProGuard代码混淆"
echo "  - 如果无法安装，请检查:"
echo "    1. 设备Android版本 (需要>=5.0)"
echo "    2. 存储空间是否足够"
echo "    3. 是否允许安装未知来源"
echo "    4. APK文件是否完整下载"
echo ""
echo "📋 详细文档:"
echo "  - ANDROID_README.md - 快速开始指南"
echo "  - APK_FIX_INSTRUCTIONS.md - APK安装问题修复指南"
echo "  - ANDROID_BUILD_GUIDE.md - 详细构建指南"
echo ""
echo "======================================="
