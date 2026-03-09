# GitHub 上传指南

## 📋 准备工作检查

### ✅ 已完成项
- [x] 项目重命名（移除 v2）
- [x] 文档全面更新
- [x] 功能描述准确
- [x] 权限要求正确（3个权限）
- [x] 版本要求统一（macOS 14.6, Xcode 16.0）
- [x] 项目可以成功编译
- [x] 清理开发过程文档

---

## 🚀 上传步骤

### 1. 创建 Git 提交

```bash
cd /Users/huangpeng/Downloads/AIScheduleAssistant

# 查看当前状态
git status

# 创建提交
git commit -m "重命名项目并更新文档

主要更改：
- 项目重命名：移除 v2 后缀
- 更新所有文档与实际功能一致
- 修正功能描述：文本选择 -> 文本输入
- 更新权限要求：移除辅助功能权限
- 统一版本要求：macOS 14.6, Xcode 16.0
- 清理代码和文档中的过时引用

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### 2. 创建 GitHub 仓库

#### 方式一：通过 GitHub 网站
1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `AIScheduleAssistant`
   - **Description**: `智能 macOS 菜单栏应用，使用 AI 识别截图和文本中的日程信息`
   - **Public** 或 **Private**：选择公开
   - **不要**勾选 "Initialize with README"（我们已有 README）
3. 点击 "Create repository"

#### 方式二：通过 GitHub CLI（如果已安装）
```bash
gh repo create AIScheduleAssistant --public --source=. --remote=origin --description="智能 macOS 菜单栏应用，使用 AI 识别截图和文本中的日程信息"
```

### 3. 连接远程仓库并推送

```bash
# 添加远程仓库（替换 YOUR_USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/AIScheduleAssistant.git

# 查看远程仓库
git remote -v

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 4. 验证上传

访问你的 GitHub 仓库页面，确认：
- [x] README.md 正确显示
- [x] 所有文件已上传
- [x] 项目结构完整
- [x] 文档链接正常工作

---

## 📝 后续步骤（可选）

### 1. 添加 Topics 标签

在 GitHub 仓库页面，点击 "Add topics"，添加：
- `macos`
- `swift`
- `swiftui`
- `ai`
- `calendar`
- `productivity`
- `menu-bar-app`
- `openai`

### 2. 创建第一个 Release

```bash
# 创建标签
git tag -a v1.0.0 -m "首次发布

功能特性：
- 截图识别日程信息
- 文本输入识别
- AI 智能解析
- 灵活保存选项（日历/待办/两者）
- 自动添加模式
- 支持所有 OpenAI 兼容 API"

# 推送标签
git push origin v1.0.0
```

然后在 GitHub 上：
1. 进入仓库的 "Releases" 页面
2. 点击 "Draft a new release"
3. 选择标签 `v1.0.0`
4. 填写 Release 标题：`v1.0.0 - 首次发布`
5. 复制上面的功能特性到描述
6. 如果有编译好的 .app 文件，可以上传
7. 点击 "Publish release"

### 3. 设置仓库描述和网站

在仓库设置中：
- **Description**: `🗓️ 智能 macOS 菜单栏应用，使用 AI 识别截图和文本中的日程信息，自动添加到系统日历和待办清单`
- **Website**: 如果有项目网站或文档站点
- **Topics**: 添加相关标签

### 4. 启用 GitHub Pages（可选）

如果想创建项目网站：
1. 进入仓库 Settings > Pages
2. Source 选择 `main` 分支
3. 选择 `/docs` 文件夹或根目录
4. 保存

---

## 🔧 常见问题

### Q1: 推送时要求输入用户名和密码

**解决方法**：
- 使用 Personal Access Token 代替密码
- 或配置 SSH 密钥

生成 Personal Access Token：
1. GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token
3. 勾选 `repo` 权限
4. 复制 token（只显示一次）
5. 推送时使用 token 作为密码

### Q2: 推送被拒绝（rejected）

**可能原因**：
- 远程仓库有本地没有的提交

**解决方法**：
```bash
# 拉取远程更改
git pull origin main --rebase

# 再次推送
git push origin main
```

### Q3: 文件太大无法推送

**解决方法**：
- 检查是否有大文件（如 .app 文件）
- 使用 Git LFS 或将大文件添加到 .gitignore

---

## ✅ 上传完成检查清单

- [ ] 代码已提交到本地仓库
- [ ] 远程仓库已创建
- [ ] 代码已推送到 GitHub
- [ ] README 在 GitHub 上正确显示
- [ ] 所有链接正常工作
- [ ] 添加了 Topics 标签
- [ ] （可选）创建了第一个 Release
- [ ] （可选）设置了仓库描述

---

## 🎉 完成！

你的项目现在已经在 GitHub 上了！

**仓库地址**：`https://github.com/YOUR_USERNAME/AIScheduleAssistant`

可以分享给其他人，接受贡献，或继续开发新功能。
