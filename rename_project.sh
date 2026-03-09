#!/bin/bash

echo "开始重命名项目，去掉 v2..."

# 1. 重命名 Swift 文件中的类名和注释
find . -name "*.swift" -type f -not -path "*/\.*" -exec sed -i '' 's/AIScheduleAssistant_v2App/AIScheduleAssistantApp/g' {} \;
find . -name "*.swift" -type f -not -path "*/\.*" -exec sed -i '' 's/AIScheduleAssistant v2/AIScheduleAssistant/g' {} \;

# 2. 重命名主 Swift 文件
if [ -f "AIScheduleAssistant v2/AIScheduleAssistant_v2App.swift" ]; then
    mv "AIScheduleAssistant v2/AIScheduleAssistant_v2App.swift" "AIScheduleAssistant v2/AIScheduleAssistantApp.swift"
    echo "✅ 已重命名 AIScheduleAssistant_v2App.swift"
fi

# 3. 更新 README 和文档
sed -i '' 's/AIScheduleAssistant v2\.xcodeproj/AIScheduleAssistant.xcodeproj/g' README.md
sed -i '' 's/AIScheduleAssistant v2\.xcodeproj/AIScheduleAssistant.xcodeproj/g' README_CN.md
sed -i '' 's/AIScheduleAssistant v2\.xcodeproj/AIScheduleAssistant.xcodeproj/g' CONTRIBUTING.md
sed -i '' 's/AIScheduleAssistant v2\.xcodeproj/AIScheduleAssistant.xcodeproj/g' docs/TESTING_GUIDE.md
sed -i '' 's/"AIScheduleAssistant v2"/"AIScheduleAssistant"/g' GITHUB_PUBLISH_GUIDE.md
sed -i '' 's/"AIScheduleAssistant v2"/"AIScheduleAssistant"/g' RELEASE_CHECKLIST.md

# 4. 更新文档中的路径
sed -i '' 's/AIScheduleAssistant-v2/AIScheduleAssistant/g' docs/*.md

echo "✅ 文件内容已更新"
echo "⚠️  接下来需要手动操作："
echo "1. 在 Xcode 中重命名项目"
echo "2. 重命名文件夹"
