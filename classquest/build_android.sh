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
if [ -f "pubspec.yaml" ]; then
    flutter pub get
    if [ $? -ne 0 ]; then
        echo "❌ 错误: 依赖安装失败"
        exit 1
    fi
    echo "✅ 依赖检查完成"
else
    echo "⚠️  警告: pubspec.yaml 文件不存在"
fi
echo ""

# 检查环境
echo "🔧 检查 Flutter 环境..."
flutter doctor
echo ""

# 清理构建缓存
echo "🧹 清理构建缓存..."
flutter clean
echo ""

# 构建类型选择
echo "请选择构建类型:"
echo "1) Release APK (直接安装)"
echo "2) App Bundle (用于 Google Play)"
echo "3) Debug APK (开发调试)"
echo "4) 全部构建"
read -p "请输入选项 (1-4): " build_type

case $build_type in
    1)
        echo "🔨 构建 Release APK..."
        flutter build apk --release --target-platform android-arm64
        if [ $? -eq 0 ]; then
            echo "✅ Release APK 构建成功"
            echo "📦 位置: build/app/outputs/flutter-apk/app-release.apk"
            ls -lh build/app/outputs/flutter-apk/app-release.apk
        else
            echo "❌ Release APK 构建失败"
            exit 1
        fi
        ;;
    2)
        echo "🔨 构建 App Bundle..."
        flutter build appbundle --release
        if [ $? -eq 0 ]; then
            echo "✅ App Bundle 构建成功"
            echo "📦 位置: build/app/outputs/bundle/release/app-release.aab"
            ls -lh build/app/outputs/bundle/release/app-release.aab
        else
            echo "❌ App Bundle 构建失败"
            exit 1
        fi
        ;;
    3)
        echo "🔨 构建 Debug APK..."
        flutter build apk --debug
        if [ $? -eq 0 ]; then
            echo "✅ Debug APK 构建成功"
            echo "📦 位置: build/app/outputs/flutter-apk/app-debug.apk"
            ls -lh build/app/outputs/flutter-apk/app-debug.apk
        else
            echo "❌ Debug APK 构建失败"
            exit 1
        fi
        ;;
    4)
        echo "🔨 构建全部产物..."
        flutter build apk --release --target-platform android-arm64
        flutter build appbundle --release
        if [ $? -eq 0 ]; then
            echo "✅ 全部构建成功"
            echo "📦 产物位置:"
            echo "  - APK: build/app/outputs/flutter-apk/app-release.apk"
            echo "  - AAB: build/app/outputs/bundle/release/app-release.aab"
            ls -lh build/app/outputs/flutter-apk/app-release.apk
            ls -lh build/app/outputs/bundle/release/app-release.aab
        else
            echo "❌ 构建失败"
            exit 1
        fi
        ;;
    *)
        echo "❌ 无效的选项"
        exit 1
        ;;
esac

echo ""
echo "======================================="
echo "🎉 构建完成！"
echo "======================================="
echo ""
echo "📱 安装 APK 到设备:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "⚠️  注意: 生产环境请使用正式签名配置"
echo "======================================="
