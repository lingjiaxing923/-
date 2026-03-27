# ClassQuest Android 应用签名说明

## 密钥库创建

### 方法一：使用 keytool 命令
```bash
# 创建密钥库
keytool -genkey -v -keystore classquest-release.keystore \
    -alias classquest \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass classquest2024 \
    -keypass classquest2024

# 验证密钥库
keytool -list -v -keystore classquest-release.keystore -alias classquest
```

### 输入示例
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

## 配置签名

### android/app/build.gradle 配置
```gradle
android {
    signingConfigs {
        release {
            storeFile file('classquest-release.keystore')
            storePassword 'classquest2024'
            keyAlias 'classquest'
            keyPassword 'classquest2024'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 安全注意事项

1. 永远不要将密钥库文件提交到版本控制系统
2. 使用密码管理器妥善保管密钥库和密码
3. 定期备份密钥库文件
4. 制定密钥更新和轮换策略
5. 生产环境必须使用正式签名

## 验证签名

```bash
# 验证 APK 签名
jarsigner -verify -verbose -certs ClassQuest-1.0.0-release.apk

# 查看签名信息
keytool -printcert -jarfile ClassQuest-1.0.0-release.apk
```
