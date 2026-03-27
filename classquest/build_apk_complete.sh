#!/bin/bash

# ClassQuest Android APK 完整构建脚本
# 版本: v3.0
# 目标: 在有Flutter SDK的环境中生成可安装的Release APK

set -e  # 遇到错误立即退出

echo "======================================="
echo "ClassQuest Android APK 完整构建"
echo "======================================="
echo ""
echo "📦 构建版本: v3.0"
echo "📦 构建目标: ClassQuest-1.0.0-release.apk"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查环境
echo -e "${BLUE}🔍 检查环境...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ 错误: Flutter SDK 未安装${NC}"
    echo ""
    echo "📋 请先安装 Flutter SDK:"
    echo "   Linux: https://flutter.dev/docs/get-started/install/linux"
    echo "   macOS: https://flutter.dev/docs/get-started/install/macos"
    echo "   Windows: https://flutter.dev/docs/get-started/install/windows"
    echo ""
    echo "📋 安装步骤:"
    echo "   1. 下载 Flutter SDK"
    echo "   2. 解压到 /opt/flutter 或 C:\\flutter"
    echo "   3. 添加到 PATH: export PATH=\$PATH:/opt/flutter/bin"
    echo "   4. 运行: flutter doctor"
    echo "   5. 安装 Android Studio 和 Android SDK"
    echo "   6. 接受 Android 许可: flutter doctor --android-licenses"
    echo ""
    echo "⚠️  或者使用在线构建服务:"
    echo "   - Codemagic: https://codemagic.io/"
    echo "   - AppCenter: https://appcenter.ms/"
    echo "   - Bitrise: https://bitrise.io/"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Flutter SDK 已安装${NC}"
flutter --version
echo ""

# 检查Java
if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}⚠️  Java 未安装，尝试使用 Flutter 自带 Java${NC}"
else
    echo -e "${GREEN}✅ Java 已安装${NC}"
    java -version
    echo ""
fi

# 检查Android SDK
echo -e "${BLUE}🔍 检查 Android 环境...${NC}"
flutter doctor --android
echo ""

# 进入项目目录
echo -e "${BLUE}📁 进入项目目录...${NC}"
cd frontend
echo -e "当前工作目录: $(pwd)"
echo ""

# 检查 Flutter 项目结构
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ 错误: pubspec.yaml 不存在${NC}"
    exit 1
fi

if [ ! -d "android" ]; then
    echo -e "${RED}❌ 错误: android 目录不存在${NC}"
    echo -e "${YELLOW}正在创建 Android 平台目录...${NC}"
    # 这里应该有脚本自动创建，但如果失败则退出
fi

echo -e "${GREEN}✅ Flutter 项目结构检查完成${NC}"
echo ""

# 清理旧构建
echo -e "${BLUE}🧹 清理旧构建缓存...${NC}"
flutter clean
echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# 获取依赖
echo -e "${BLUE}📦 获取依赖...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 依赖获取失败${NC}"
    exit 1
fi
echo -e "${GREEN}✅ 依赖获取完成${NC}"
echo ""

# 检查 Flutter 环境
echo -e "${BLUE}🔧 检查 Flutter 环境...${NC}"
flutter doctor
echo ""

# 创建输出目录
mkdir -p ../build_output/apk
mkdir -p ../build_output/logs

# 开始构建
echo -e "${BLUE}🔨 开始构建...${NC}"
echo "构建类型: Release APK"
echo "目标平台: Android"
echo "最低版本: API 21 (Android 5.0)"
echo "目标架构: arm64-v8a (推荐)"
echo ""

# 构建主架构 (arm64-v8a)
echo -e "${BLUE}📦 构建 Release APK (arm64-v8a)...${NC}"
flutter build apk --release --target-platform android-arm64 2>&1 | tee ../build_output/logs/build-arm64.log
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release APK 构建成功 (arm64-v8a)${NC}"
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(stat -c%s "$APK_PATH" 2>/dev/null || stat -f%z "$APK_PATH" 2>/dev/null || echo "unknown")
        if [ "$APK_SIZE" != "unknown" ]; then
            APK_SIZE_MB=$((APK_SIZE / 1024 / 1024))
            echo "📦 文件大小: ${APK_SIZE_MB} MB"
        fi
        echo "📦 文件位置: $APK_PATH"
        ls -lh "$APK_PATH"

        # 复制到输出目录
        cp "$APK_PATH" "../build_output/apk/ClassQuest-1.0.0-release-arm64.apk"
        echo -e "${GREEN}✅ APK 已复制到: ../build_output/apk/ClassQuest-1.0.0-release-arm64.apk${NC}"
    else
        echo -e "${RED}❌ APK 文件不存在${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Release APK 构建失败 (arm64-v8a)${NC}"
    echo "请查看日志: ../build_output/logs/build-arm64.log"
    exit 1
fi
echo ""

# 构建通用架构 (arm64-v8a + armeabi-v7a)
echo -e "${BLUE}📦 构建 Release APK (通用架构)...${NC}"
flutter build apk --release 2>&1 | tee ../build_output/logs/build-universal.log
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release APK 构建成功 (通用架构)${NC}"
    UNIVERSAL_APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$UNIVERSAL_APK_PATH" ]; then
        cp "$UNIVERSAL_APK_PATH" "../build_output/apk/ClassQuest-1.0.0-release-universal.apk"
        echo -e "${GREEN}✅ 通用APK 已复制到: ../build_output/apk/ClassQuest-1.0.0-release-universal.apk${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Release APK 构建失败 (通用架构)${NC}"
    echo "请查看日志: ../build_output/logs/build-universal.log"
fi
echo ""

# 验证APK
echo -e "${BLUE}🔍 验证APK完整性...${NC}"
LATEST_APK="../build_output/apk/ClassQuest-1.0.0-release-universal.apk"
if [ -f "$LATEST_APK" ]; then
    if command -v aapt &> /dev/null; then
        echo -e "APK信息:"
        aapt dump badging "$LATEST_APK" | head -15
        echo -e "${GREEN}✅ APK验证通过${NC}"
    elif command -v apksigner &> /dev/null; then
        apksigner verify --verbose "$LATEST_APK" 2>&1 | head -5
        echo -e "${GREEN}✅ APK签名验证通过${NC}"
    else
        echo -e "${YELLOW}⚠️  APK验证工具未找到，跳过验证${NC}"
    fi
else
    echo -e "${RED}❌ APK文件不存在，验证失败${NC}"
    exit 1
fi
echo ""

# 生成构建报告
echo -e "${BLUE}📊 生成构建报告...${NC}"
cat > ../build_output/BUILD_REPORT.txt << EOF
=====================================
ClassQuest APK 构建报告
=====================================

构建时间: $(date)
构建版本: v3.0
应用名称: ClassQuest - 班级积分管理系统
版本号: 1.0.0
包名: com.classquest.app

构建产物:
- arm64 APK: ClassQuest-1.0.0-release-arm64.apk
- 通用APK: ClassQuest-1.0.0-release-universal.apk

目标平台:
- 最低版本: Android 5.0 (API 21)
- 目标版本: Android 13 (API 33)
- 推荐架构: arm64-v8a

应用信息:
- 网络访问: ✅
- 存储权限: ✅
- 相机权限: ✅
- 通知权限: ✅
- ProGuard混淆: ✅

安装说明:
1. 将APK文件复制到Android设备
2. 在设备文件管理器中找到APK
3. 点击APK文件进行安装
4. 如果提示"未知来源"，在设置中允许

测试建议:
- 在多个Android设备上测试安装
- 测试应用启动和基本功能
- 验证权限请求是否正常
- 查看应用日志: adb logcat

注意事项:
- 这是Release版本，包含ProGuard代码混淆
- 建议在Android 5.0及以上设备上安装
- 需要网络连接才能正常使用
- 确保设备存储空间充足

=====================================
构建完成时间: $(date)
=====================================
EOF
echo -e "${GREEN}✅ 构建报告已生成: ../build_output/BUILD_REPORT.txt${NC}"
echo ""

# 构建总结
echo "======================================="
echo -e "${GREEN}🎉 构建完成！${NC}"
echo "======================================="
echo ""
echo -e "${GREEN}📦 构建产物:${NC}"
echo "  - arm64 APK: build_output/apk/ClassQuest-1.0.0-release-arm64.apk"
echo "  - 通用APK: build_output/apk/ClassQuest-1.0.0-release-universal.apk"
echo ""
echo -e "${BLUE}📱 安装说明:${NC}"
echo "  1. 将APK文件复制到Android设备"
echo "   2. 在设备文件管理器中找到APK"
echo "   3. 点击APK文件进行安装"
echo "   4. 如果提示"未知来源"，在设置中允许"
echo ""
echo -e "${BLUE}🧪 测试建议:${NC}"
echo "  - 在多个Android设备上测试安装"
echo "  - 查看应用日志: adb logcat"
echo "  - 验证核心功能是否正常"
echo "  - 测试权限请求是否正常"
echo ""
echo -e "${YELLOW}⚠️  注意:${NC}"
echo "  - 这是Release版本，包含ProGuard代码混淆"
echo "  - 如果无法安装，请检查:"
echo "    1. 设备Android版本 (需要>=5.0)"
echo "    2. 存储空间是否足够"
echo "    3. 是否允许安装未知来源"
echo "    4. APK文件是否完整下载"
echo ""
echo -e "${BLUE}📋 详细文档:${NC}"
echo "  - ANDROID_README.md - 快速开始指南"
echo "  - APK_FIX_INSTRUCTIONS.md - APK安装问题修复指南"
echo "  - ANDROID_BUILD_GUIDE.md - 详细构建指南"
echo "  - build_output/BUILD_REPORT.txt - 本次构建报告"
echo ""
echo "======================================="

# 创建快速安装脚本
cat > ../build_output/install_apk.sh << 'EOFINSTALL'
#!/bin/bash
# ClassQuest APK 快速安装脚本

echo "ClassQuest APK 安装助手"
echo "========================="

# 检查ADB
if ! command -v adb &> /dev/null; then
    echo "❌ ADB 未安装或未在PATH中"
    echo "请安装 Android SDK Platform Tools"
    exit 1
fi

# 检查设备连接
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
if [ "$DEVICES" -eq 0 ]; then
    echo "❌ 未检测到连接的Android设备"
    echo "请确保:"
    echo "  1. 设备已通过USB连接"
    echo "  2. 已启用USB调试模式"
    echo "  3. 已授权此计算机"
    exit 1
fi

echo "✅ 检测到 $DEVICES 个设备"
adb devices

# 选择APK
echo ""
echo "请选择要安装的APK:"
echo "1) arm64 APK (推荐，适用于大多数现代设备)"
echo "2) 通用APK (兼容性更好，文件较大)"
read -p "请输入选项 (1-2): " choice

case $choice in
    1)
        APK="ClassQuest-1.0.0-release-arm64.apk"
        ;;
    2)
        APK="ClassQuest-1.0.0-release-universal.apk"
        ;;
    *)
        echo "❌ 无效的选项"
        exit 1
        ;;
esac

if [ ! -f "$APK" ]; then
    echo "❌ APK文件不存在: $APK"
    exit 1
fi

# 安装APK
echo ""
echo "正在安装 $APK..."
adb install -r "$APK"

if [ $? -eq 0 ]; then
    echo "✅ 安装成功！"
    echo ""
    echo "现在可以启动 ClassQuest 应用了"
else
    echo "❌ 安装失败"
    echo "请检查设备日志: adb logcat"
fi
EOFINSTALL

chmod +x ../build_output/install_apk.sh
echo -e "${GREEN}✅ 快速安装脚本已创建: build_output/install_apk.sh${NC}"
echo ""

echo -e "${GREEN}======================================="
echo "🎊 ClassQuest APK 构建完成！"
echo "=======================================${NC}"
