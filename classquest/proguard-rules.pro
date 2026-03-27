# ClassQuest ProGuard 混淆规则

# Flutter 相关规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# 保持第三方库
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class org.json.** { *; }
-keep class io.flutter.** { *; }

# 保持应用特定类
-keep class com.classquest.** { *; }
-dontwarn com.classquest.**

# 保持枚举
-keepclassmembers enum com.classquest.** {
    public static *[] values();
    public static ** valueOf(java.lang.String);
}

# 保持序列化类
-keepclassmembers class com.classquest.models.** {
    public <init>(...);
}

# 保持 JSON 相关
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile
-keepattributes LineNumberTable
-keepattributes LocalVariableTable
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 保持 Retrofit (如果使用)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# 保持数据模型
-keep class com.classquest.**.model.** { *; }
-keep class com.classquest.**.response.** { *; }
-keep class com.classquest.**.request.** { *; }

# 优化选项
-dontusemixedcaseclassnames
-allowaccessmodification
-dontpreverify
-verbose

# 保持注解
-keep @androidx.annotation.Keep class * {*;}
-keep @android.support.annotation.Keep class * {*;}
-keep @android.annotation.SuppressLint class * {*;}
-keep @android.annotation.TargetApi class * {*;}
