#!/bin/bash

# ClassQuest APK 安装问题快速诊断和修复脚本

echo "======================================="
echo "ClassQuest APK 诊断和修复工具"
echo "======================================="
echo ""

# 检查环境
echo "🔍 检查环境..."
flutter_check=$(command -v flutter &> /dev/null; echo "installed" || echo "not_installed")
echo "Flutter: $flutter_check"
echo ""

# 检查APK文件
echo "📦 检查APK文件..."
APK_FILE="build_output/apk/ClassQuest-1.0.0-release.apk"

if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(stat -c%s "$APK_FILE" 2>/dev/null || echo "unknown")
    echo "✅ APK文件存在"
    echo "📦 文件大小: $((APK_SIZE / 1024)) KB"
else
    echo "❌ APK文件不存在"
    echo "📝 需要先构建APK"
fi
echo ""

# 检查AndroidManifest
echo "📋 检查AndroidManifest.xml..."
if [ -f "AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest.xml 存在"

    # 检查关键配置项
    if grep -q "android:versionCode" AndroidManifest.xml; then
        echo "✅ versionCode 配置正确"
    else
        echo "❌ versionCode 配置缺失"
    fi

    if grep -q "android:versionName" AndroidManifest.xml; then
        echo "✅ versionName 配置正确"
    else
        echo "❌ versionName 配置缺失"
    fi

    if grep -q "android:minSdkVersion" AndroidManifest.xml; then
        echo "✅ minSdkVersion 配置正确"
    else
        echo "⚠️  minSdkVersion 配置建议添加"
    fi
else
    echo "❌ AndroidManifest.xml 不存在"
fi
echo ""

# 诊断建议
echo "🔧 诊断建议:"
echo ""
echo "1. 环境检查:"
if [ "$flutter_check" = "not_installed" ]; then
    echo "   ⚠️  Flutter SDK未安装"
    echo "   📋 安装Flutter: https://flutter.dev/docs/get-started/install"
    echo "   📋 配置Flutter PATH环境变量"
    echo ""
    echo "2. APK构建:"
    echo "   📋 在Flutter环境中重新构建"
    echo "   📋 使用以下命令:"
    echo "      cd frontend"
    echo "      flutter clean"
    echo "      flutter pub get"
    echo "      flutter build apk --release"
    echo ""
    echo "3. 配置修复:"
    echo "   📋 已提供修复版本的AndroidManifest.xml"
    echo "   📋 已提供修复版本的build.gradle"
    echo "   📋 使用修复配置重新构建"
    echo ""
    echo "4. 设备测试:"
    echo "   📋 在多个Android设备上测试"
    echo "   📋 使用不同的Android版本 (5.0, 6.0, 7.0+)"
    echo "   📋 记录设备型号和Android版本"
fi
echo ""

# 提供修复选项
echo "🔧 可用的修复操作:"
echo ""
echo "选择修复方案:"
echo "1) 使用修复后的配置重新构建"
echo "2) 查看详细的APK修复指南"
echo "3) 检查APK文件完整性"
echo "4) 创建诊断报告"
echo ""
read -p "请输入选项 (1-4): " option

case $option in
    1)
        echo ""
        echo "🔨 方案1: 使用修复配置重新构建"
        echo ""
        echo "步骤:"
        echo "1. 创建或下载密钥库"
        echo "2. 配置build.gradle中的密钥库路径"
        echo "3. 进入frontend目录"
        echo "4. 执行: flutter clean && flutter pub get && flutter build apk --release"
        echo ""
        break
        ;;
    2)
        echo ""
        echo "📋 方案2: 查看详细修复指南"
        echo ""
        echo "打开文件: APK_FIX_INSTRUCTIONS.md"
        echo "这个文件包含:"
        echo "- APK安装问题诊断"
        echo "- 详细的解决方案"
        echo "- 完整的故障排除流程"
        echo ""
        break
        ;;
    3)
        echo ""
        echo "🔍 方案3: 检查APK文件完整性"
        echo ""
        if [ -f "$APK_FILE" ]; then
            echo "检查文件: $APK_FILE"
            echo "文件大小: $((stat -c%s "$APK_FILE" / 1024)) KB"
            echo "文件权限: $(ls -l "$APK_FILE" | awk '{print $1}')"
            echo "文件类型: $(file "$APK_FILE")"
            echo ""
            # 检查文件头
            echo "文件头信息:"
            head -c 100 "$APK_FILE" | xxd | head -1
        fi
        echo ""
        break
        ;;
    4)
        echo ""
        echo "📊 方案4: 创建诊断报告"
        echo ""
        REPORT_FILE="build_output/diagnostic_report_$(date +%Y%m%d_%H%M%S).txt"

        cat > "$REPORT_FILE" << EOF
=====================================
ClassQuest APK 诊断报告
=====================================

诊断时间: $(date)
Flutter状态: $flutter_check
APK文件状态: $([ -f "$APK_FILE" ] && echo "存在" || echo "不存在")
APK文件大小: $([ -f "$APK_FILE" ] && stat -c%s "$APK_FILE" | xargs || echo "未知")

AndroidManifest检查:
- versionCode: $(grep -q "versionCode" AndroidManifest.xml && echo "存在" || echo "缺失")
- versionName: $(grep -q "versionName" AndroidManifest.xml && echo "存在" || echo "缺失")
- package: $(grep -q 'package="com.classquest.app"' AndroidManifest.xml && echo "正确" || echo "可能错误")

问题分析:
$([ "$flutter_check" = "not_installed" ] && echo "Flutter未安装 - 无法进行实际构建" || echo "APK文件为模拟产物 - 需要在Flutter环境中重新构建")

建议:
1. 安装Flutter SDK
2. 重新构建APK
3. 在真实设备上测试
4. 查看APK_FIX_INSTRUCTIONS.md获取详细指导
=====================================
EOF

        echo "✅ 诊断报告已创建: $REPORT_FILE"
        echo ""
        break
        ;;
    *)
        echo "❌ 无效的选项"
        exit 1
        ;;
esac

echo ""
echo "======================================="
echo "📋 其他修复资源:"
echo "======================================="
echo ""
echo "1. APK_FIX_INSTRUCTIONS.md - 详细的APK修复指南"
echo "2. AndroidManifest.xml - 修复版本的Android配置"
echo "3. build.gradle - 修复版本的Gradle配置"
echo "4. build_android.sh - 自动化构建脚本"
echo "5. APK_FIX_INSTRUCTIONS.md - 问题诊断和解决方案"
echo ""
echo "🚀 快速修复步骤:"
echo "======================================="
echo "推荐流程:"
echo "1. 在Flutter环境中执行: flutter build apk --release"
echo "2. 在真实设备上测试安装"
echo "3. 如果还有问题，查看: APK_FIX_INSTRUCTIONS.md"
echo "4. 收集设备信息: 设备型号、Android版本"
echo "5. 参考: android/build.gradle 和 AndroidManifest.xml"
echo ""
echo "======================================="
echo "✅ 诊断完成！"
echo "======================================="
