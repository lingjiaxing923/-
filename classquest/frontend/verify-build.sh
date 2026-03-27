#!/bin/bash

echo "🔍 Verifying Flutter Android build configuration..."

# Check Flutter installation
echo "📋 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter SDK."
    exit 1
fi
echo "✅ Flutter found: $(flutter --version | head -n1)"

# Check Java
echo "📋 Checking Java installation..."
if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install JDK 17+."
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -n1)
echo "✅ Java found: $JAVA_VERSION"

# Check Android SDK
echo "📋 Checking Android SDK..."
if [ -z "$ANDROID_SDK_ROOT" ] && [ -z "$ANDROID_HOME" ]; then
    echo "⚠️  Android SDK environment variables not set."
    echo "   This is okay for local development, but required for building."
else
    echo "✅ Android SDK root: ${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
fi

# Check local.properties
echo "📋 Checking local.properties..."
if [ ! -f "android/local.properties" ]; then
    echo "⚠️  local.properties not found. This is normal for CI."
else
    echo "✅ local.properties found"
    cat android/local.properties
fi

# Check Gradle wrapper
echo "📋 Checking Gradle wrapper..."
if [ ! -f "android/gradlew" ]; then
    echo "❌ Gradle wrapper not found."
    exit 1
fi
echo "✅ Gradle wrapper found"

# Check Flutter dependencies
echo "📋 Checking Flutter dependencies..."
echo "Running 'flutter pub get'..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to get Flutter dependencies."
    exit 1
fi
echo "✅ Flutter dependencies installed"

# Analyze code
echo "📋 Analyzing Flutter code..."
flutter analyze

if [ $? -ne 0 ]; then
    echo "⚠️  Code analysis found issues, but continuing..."
fi

echo ""
echo "✅ Build configuration verification complete!"
echo ""
echo "🚀 To build the APK, run:"
echo "   flutter build apk --release"
