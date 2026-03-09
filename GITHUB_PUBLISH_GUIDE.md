# 发布到 GitHub 指南

## 步骤 1：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `AIScheduleAssistant`
   - **Description**: `An intelligent macOS menu bar app that uses AI to recognize schedule information from screenshots or text`
   - **Visibility**: Public（公开）
   - **不要**勾选 "Initialize this repository with:"（我们已经有代码了）
3. 点击 "Create repository"

## 步骤 2：推送代码到 GitHub

在终端中执行以下命令：

```bash
cd "/Users/huangpeng/Downloads/AIScheduleAssistant v2"

# 添加远程仓库
git remote add origin https://github.com/Vesemir-0/AIScheduleAssistant.git

# 推送代码
git push -u origin main
```

如果遇到认证问题，GitHub 现在需要使用 Personal Access Token：
1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 勾选 `repo` 权限
4. 生成 token 并保存（只显示一次）
5. 推送时使用 token 作为密码

## 步骤 3：验证

推送成功后，访问 https://github.com/Vesemir-0/AIScheduleAssistant 查看：
- ✅ 代码已上传
- ✅ README.md 正确显示
- ✅ LICENSE 文件存在
- ✅ 所有文件都在

## 步骤 4：添加仓库主题标签（可选）

在仓库页面右侧点击 ⚙️ 设置，添加 topics：
- `macos`
- `swift`
- `swiftui`
- `ai`
- `calendar`
- `productivity`
- `menu-bar-app`
- `openai`
- `schedule-management`

## 步骤 5：创建第一个 Release（可选）

1. 在仓库页面点击 "Releases" → "Create a new release"
2. 填写信息：
   - **Tag version**: `v1.0.0`
   - **Release title**: `AI Schedule Assistant v1.0.0`
   - **Description**: 参考 RELEASE_CHECKLIST.md 中的内容
3. 上传编译好的 .app 文件（需要先在 Xcode 中构建）
4. 点击 "Publish release"

## 常见问题

### Q: 推送时提示 "Permission denied"
A: 需要配置 SSH key 或使用 Personal Access Token

### Q: 推送时提示 "remote: Repository not found"
A: 检查仓库名称是否正确，确保已创建仓库

### Q: 如何更新代码？
A: 修改代码后执行：
```bash
git add .
git commit -m "描述你的更改"
git push
```

## 下一步

发布成功后，你可以：
1. 在 README 中添加截图
2. 创建 Wiki 页面
3. 设置 GitHub Actions 自动构建
4. 分享到社区
