#!/bin/bash
# build-release.sh - AI Schedule Assistant 自动打包脚本

set -e

# 配置
VERSION="1.0.0"
APP_NAME="AIScheduleAssistant"
SCHEME="AIScheduleAssistant"
PROJECT="AIScheduleAssistant.xcodeproj"

echo "🚀 开始构建 ${APP_NAME} v${VERSION}..."
echo ""

# 清理
echo "🧹 清理之前的构建..."
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" -configuration Release > /dev/null 2>&1

# 构建
echo "🔨 构建 Release 版本..."
xcodebuild -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath ./build \
  build

# 检查构建是否成功
if [ ! -d "./build/Build/Products/Release/${APP_NAME}.app" ]; then
    echo "❌ 构建失败！"
    exit 1
fi

echo "✅ 构建成功！"
echo ""

# 创建发布目录
RELEASE_DIR="./release"
echo "📁 创建发布目录..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# 复制应用
echo "📦 复制应用..."
cp -R "./build/Build/Products/Release/${APP_NAME}.app" "$RELEASE_DIR/"

# 创建 ZIP
echo "🗜️  创建 ZIP 压缩包..."
cd "$RELEASE_DIR"
zip -r -q "${APP_NAME}-v${VERSION}.zip" "${APP_NAME}.app"
cd ..

# 创建 DMG
echo "💿 创建 DMG 镜像..."
hdiutil create -volname "${APP_NAME}" \
  -srcfolder "$RELEASE_DIR/${APP_NAME}.app" \
  -ov -format UDZO \
  "$RELEASE_DIR/${APP_NAME}-v${VERSION}.dmg" > /dev/null 2>&1

echo ""
echo "🎉 打包完成！"
echo ""
echo "📍 文件位置："
echo "   应用: $RELEASE_DIR/${APP_NAME}.app"
echo "   ZIP: $RELEASE_DIR/${APP_NAME}-v${VERSION}.zip"
echo "   DMG: $RELEASE_DIR/${APP_NAME}-v${VERSION}.dmg"
echo ""
echo "📊 文件大小："
ls -lh "$RELEASE_DIR"/${APP_NAME}-v${VERSION}.* | awk '{print "   " $9 ": " $5}'
echo ""
echo "✨ 下一步："
echo "   1. 测试应用: open $RELEASE_DIR/${APP_NAME}.app"
echo "   2. 发布到 GitHub: gh release create v${VERSION} $RELEASE_DIR/${APP_NAME}-v${VERSION}.{zip,dmg}"
echo ""
