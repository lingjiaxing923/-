# ClassQuest Android 应用签名配置

## 签名说明

Android 应用必须经过数字签名才能安装。签名分为两种类型：

### 1. Debug 签名 (开发测试)
- 自动生成，用于开发阶段
- 不可发布到应用商店

### 2. Release 签名 (生产发布)
- 需要创建自己的密钥库 (Keystore)
- 用于发布到应用商店
- 需要妥善保管密钥库和密码

---

## 创建密钥库 (Keystore)

### 方法一: 使用 keytool (推荐)

```bash
# 创建密钥库
keytool -genkey -v -keystore classquest-release.keystore -alias classquest -keyalg RSA -keysize 2048 -validity 10000 -storepass classquest2024 -keypass classquest2024

# 验证密钥库
keytool -list -v -keystore classquest-release.keystore -alias classquest
```

**输入示例:**
```
What is your first and last name?
  [Unknown]:  ClassQuest Development Team

What is the name of your organizational unit?
  [Unknown]:  Development

What is the name of your organization?
  [Unknown]:  ClassQuest

What is the name of your City or Locality?
  [Unknown]:  Beijing

What is the name of your State or Province?
  [Unknown]:  Beijing

What is the two-letter country code for this unit?
  [Unknown]:  CN

Is CN=ClassQuest Development Team, OU=Development, O=ClassQuest, L=Beijing, ST=Beijing, C=CN correct?
  [no]:  yes

Enter key password for <classquest>
        [RETURN if same as keystore password]: classquest2024
```

### 方法二: 使用 Android Studio

1. 打开 Android Studio
2. 选择 Build > Generate Signed Bundle/APK
3. 选择 "Create new keystore"
4. 填写密钥库信息
5. 生成 keystore 文件

### 方法三: 使用在线工具

访问: https://keystore-explorer.org/
生成并下载密钥库文件

---

## 配置签名

### 编辑 android/app/build.gradle

```gradle
android {
    defaultConfig {
        applicationId "com.classquest.app"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }

        release {
            // 使用正式密钥库
            storeFile file('classquest-release.keystore')
            storePassword 'your-store-password'
            keyAlias 'classquest'
            keyPassword 'your-key-password'
        }
    }

    buildTypes {
        debug {
            signingConfig signingConfigs.debug
            applicationIdSuffix ".debug"
            debuggable true
        }

        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 密钥库安全管理

### ⚠️ 重要安全提示

1. **永远不要将密钥库文件提交到版本控制系统**
   - 将 keystore 文件添加到 .gitignore
   - 不要上传到 GitHub 或其他公开仓库

2. **妥善保管密码**
   - 使用密码管理器
   - 不要在代码中硬编码密码
   - 不要在共享文档中记录密码

3. **定期备份密钥库**
   - 将密钥库文件备份到安全位置
   - 备份密码信息（加密存储）

4. **密钥库轮换策略**
   - 制定密钥更新计划
   - 定期生成新的密钥库
   - 保留旧密钥库用于已发布版本

### .gitignore 配置

创建 `.gitignore` 文件:
```
# Android Keystore
*.keystore
*.jks

# 密钥库配置
keystore.properties
```

### 安全存储示例

创建 `keystore.properties` (不要提交到版本控制):
```properties
storeFile=classquest-release.keystore
storePassword=your-encrypted-store-password
keyAlias=classquest
keyPassword=your-encrypted-key-password
```

---

## 不同环境的签名配置

### 开发环境 (Debug)
```gradle
signingConfigs {
    debug {
        storeFile file('debug.keystore')
        storePassword 'android'
        keyAlias 'androiddebugkey'
        keyPassword 'android'
    }
}
```

### 测试环境 (Beta)
```gradle
signingConfigs {
    beta {
        storeFile file('beta-release.keystore')
        storePassword 'beta-password'
        keyAlias 'classquest-beta'
        keyPassword 'beta-password'
    }
}
```

### 生产环境 (Release)
```gradle
signingConfigs {
    release {
        storeFile file('classquest-release.keystore')
        storePassword 'release-password'
        keyAlias 'classquest-release'
        keyPassword 'release-password'
    }
}
```

---

## 应用签名验证

### 验证签名

```bash
# 验证 APK 签名
jarsigner -verify -verbose -certs my.apk

# 查看签名信息
keytool -printcert -jarfile my.apk

# 验证密钥库
keytool -list -v -keystore classquest-release.keystore
```

### 测试安装

```bash
# 安装签名后的 APK
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 卸载应用
adb uninstall com.classquest.app

# 启动应用
adb shell am start -n com.classquest.app/.MainActivity
```

---

## 发布前检查清单

### 构建前检查
- [ ] 使用正确的密钥库签名
- [ ] 版本号已更新
- [ ] 应用图标已更新
- [ ] 应用名称和包名正确
- [ ] 隐私政策已准备
- [ ] 应用截图已准备
- [ ] 应用描述已完善

### 签名后检查
- [ ] 签名验证通过
- [ ] APK 体积合理 (< 50MB)
- [ ] 应用安装正常
- [ ] 所有功能测试通过
- [ ] 无崩溃和严重Bug
- [ ] 性能测试合格

---

## 签名相关的常见问题

### Q: 为什么签名后应用无法安装？
A: 检查签名是否正确，使用 jarsigner 验证签名

### Q: 如何找回丢失的密钥库？
A: 密钥库丢失后无法更新应用，需要创建新密钥库并发布新版本

### Q: 是否可以使用不同的密钥库？
A: 可以，但需要更新应用签名并重新发布

### Q: 如何提高应用安全性？
A: 使用强密码，定期更换密钥库，启用代码混淆

---

**文档版本**: v1.0
**更新日期**: 2026年3月26日
**适用平台**: Android 5.0+ (API 21+)
