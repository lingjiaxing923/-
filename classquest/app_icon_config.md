# ClassQuest Android 应用图标配置

## 图标要求

### 不同尺寸和类型
| 类型 | 尺寸 | 文件名 | 说明 |
|------|------|--------|------|
| Launcher | 512x512 | ic_launcher.png | 应用主图标 |
| Adaptive Icon | 512x512 | ic_launcher.png | 自适应图标 |
| Play Store | 1024x1024 | feature.png | 应用商店图标 |
| Notification | 96x96 | ic_notification.png | 通知图标 |
| Splash | 1920x1080 | splash.png | 启动画面 |

### 图标设计建议
1. **主题**: 班级积分、成长、竞技
2. **颜色**: 主色 #6366F1 (蓝色)、辅助色 #10B981 (绿色)
3. **元素**: 书本、徽章、奖杯、积分星
4. **风格**: 扁平化、简洁、现代
5. **背景**: 透明或渐变蓝色

---

## 使用 flutter_launcher_icons

### 1. 添加依赖
```yaml
# pubspec.yaml
dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 2. 配置图标
```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icon.png"
  adaptive_icon_background: "#6366F1"
  adaptive_icon_foreground: "assets/icon_foreground.png"
```

### 3. 生成图标
```bash
cd frontend
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### 4. 自定义生成
```bash
# 生成不同平台图标
flutter_launcher_icons:
  android: true
  ios: true
  web: true
  image_path: "assets/icon.png"
  adaptive_icon_background: "#6366F1"
  adaptive_icon_foreground: "assets/icon_foreground.png"
  min_sdk_android: 21
```

---

## 手动创建图标结构

### 目录结构
```
android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png (48x48)
├── mipmap-hdpi/
│   └── ic_launcher.png (72x72)
├── mipmap-xhdpi/
│   └── ic_launcher.png (96x96)
├── mipmap-xxhdpi/
│   └── ic_launcher.png (144x144)
├── mipmap-xxxhdpi/
│   └── ic_launcher.png (192x192)
└── mipmap-xxxxhdpi/
    └── ic_launcher.png (512x512)
```

### 图标生成命令

```bash
# 使用 ImageMagick (需要安装)
for size in 48 72 96 144 192 512; do
    mkdir -p "android/app/src/main/res/mipmap-$(echo $size | sed 's/512/xxxxhdpi/;s/192/xxxhdpi/;s/144/xxhdpi/;s/96/xhdpi/;s/72/hdpi/;s/48/mdpi/')"
    convert icon.png -resize ${size}x${size} "android/app/src/main/res/mipmap-$(echo $size | sed 's/512/xxxxhdpi/;s/192/xxxhdpi/;s/144/xxhdpi/;s/96/xhdpi/;s/72/hdpi/;s/48/mdpi/')/ic_launcher.png"
done
```

---

## 在线图标生成工具

### 推荐1: AppIconGenerator
- 网站: https://appicon.co/
- 功能: 生成所有平台图标
- 优势: 免费使用、快速、批处理

### 推荐2: MakeAppIcon
- 网站: https://makeappicon.com/
- 功能: 生成iOS和Android图标
- 优势: 支持圆角、效果

### 推荐3: Android Asset Studio
- 下载: https://developer.android.com/studio/projects
- 功能: 官方工具、多格式生成
- 优势: 官方支持、功能完整

### 推荐4: IconKitchen
- 网站: https://icon.kitchen/
- 功能: 在线编辑和生成图标
- 优势: 预览效果好、实时编辑

---

## 图标检查清单

### 发布前检查
- [ ] 图标符合Material Design规范
- [ ] 所有尺寸图标已生成
- [ ] 图标在不同背景下清晰可见
- [ ] 无锯齿和模糊
- [ ] 符合应用商店要求
- [ ] 包含透明背景版本
- [ ] 图标与品牌一致

### 设计检查
- [ ] 识别度高 (班级积分主题)
- [ ] 色彩搭配合理 (蓝绿色主色调)
- [ ] 元素清晰可辨 (书本、徽章等)
- [ ] 风格统一 (扁平化、现代感)
- [ ] 在小尺寸下可识别 (48x48)
- [ ] 在大尺寸下美观 (512x512)

---

## 启动画面配置

### Splash Screen要求
| 设备类型 | 尺寸 | 宽高比 |
|-----------|------|--------|
| 手机 (竖屏) | 1080x1920 | 9:16 |
| 手机 (横屏) | 1920x1080 | 16:9 |
| 平板 (竖屏) | 1536x2048 | 3:4 |
| 平板 (横屏) | 2048x1536 | 4:3 |

### 配置代码
```xml
<!-- android/app/src/main/res/values/styles.xml -->
<style name="LaunchTheme" parent="@android:style/Theme.Material.NoActionBar.Fullscreen">
    <item name="android:windowBackground">@drawable/splash</item>
    <item name="android:windowContentOverlay">@null</item>
    <item name="android:android:windowFullscreen">true</item>
</style>
```

---

## 性能优化建议

### 1. 图标优化
- 使用WebP格式减少体积 (Android 4.0+)
- 使用矢量图标 (VectorDrawable) 减少资源
- 避免使用过多尺寸的图标

### 2. 资源优化
- 压缩PNG文件 (推荐工具: TinyPNG)
- 移除未使用的资源文件
- 使用9-patch图减少重复资源

### 3. APK体积优化
- 启用代码压缩 (ProGuard)
- 启用资源压缩 (shrinkResources)
- 使用App Bundle替代APK (Google Play推荐)

---

**配置文件版本**: v1.0
**更新日期**: 2026年3月26日
**适用版本**: Android 5.0+ (API 21+)
