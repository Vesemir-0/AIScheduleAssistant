# 权限请求调试指南

## 问题：权限请求按钮点击无反应

### 已修复的内容

1. **PermissionsView 更新**：
   - 添加了权限请求后的状态刷新
   - 添加了错误处理和日志输出
   - 确保在主线程更新 UI

2. **PermissionManager 优化**：
   - 辅助功能权限请求后立即更新状态
   - 添加延迟检查机制

### 测试步骤

#### 1. 测试日历权限

**操作**：
1. 打开设置 > 权限管理
2. 找到"日历权限"行
3. 点击"请求权限"按钮

**预期结果**：
- 弹出系统对话框："AIScheduleAssistant v2 想要访问您的日历"
- 点击"好"授权
- 权限状态应该变为绿色 ✅

**如果没反应**：
- 检查 Xcode 控制台是否有错误日志
- 可能已经授权过了，状态应该已经是绿色

#### 2. 测试提醒事项权限

**操作**：
1. 在权限管理页面
2. 找到"提醒事项权限"行
3. 点击"请求权限"按钮

**预期结果**：
- 弹出系统对话框："AIScheduleAssistant v2 想要访问您的提醒事项"
- 点击"好"授权
- 权限状态应该变为绿色 ✅

#### 3. 测试辅助功能权限

**操作**：
1. 在权限管理页面
2. 找到"辅助功能权限"行
3. 点击"请求权限"按钮

**预期结果**：
- 弹出系统提示对话框
- 点击"打开系统偏好设置"
- 在系统设置中找到应用并勾选启用
- 返回应用，点击"刷新状态"
- 权限状态应该变为绿色 ✅

#### 4. 测试屏幕录制权限

**操作**：
1. 在权限管理页面
2. 找到"屏幕录制权限"行
3. 点击"打开系统设置"按钮

**预期结果**：
- 自动打开系统设置 > 隐私与安全性 > 屏幕录制
- 找到应用并勾选启用
- 返回应用，点击"刷新状态"
- 权限状态应该变为绿色 ✅

### 调试技巧

#### 查看控制台日志

在 Xcode 中运行应用时，控制台会显示日志：

```
Calendar permission requested
Calendar permission error: ...
Reminders permission requested
Reminders permission error: ...
```

#### 手动刷新状态

如果权限状态没有自动更新：
1. 点击"刷新状态"按钮
2. 或者重启应用

#### 重置权限（用于测试）

如果想重新测试权限请求，可以在终端运行：

```bash
# 重置所有权限
tccutil reset All com.yourcompany.AIScheduleAssistant-v2

# 或者重置特定权限
tccutil reset Calendar com.yourcompany.AIScheduleAssistant-v2
tccutil reset Reminders com.yourcompany.AIScheduleAssistant-v2
tccutil reset Accessibility com.yourcompany.AIScheduleAssistant-v2
tccutil reset ScreenCapture com.yourcompany.AIScheduleAssistant-v2
```

**注意**：重置后需要重启应用。

### 常见问题

#### Q1: 点击"请求权限"没有任何反应

**可能原因**：
1. 权限已经授予过了
2. 权限已经被拒绝过了

**解决方法**：
- 检查权限状态（绿色 ✅ = 已授权，红色 ❌ = 未授权）
- 如果是红色，点击"打开系统设置"手动授权
- 使用 `tccutil reset` 重置权限后重试

#### Q2: 系统对话框没有弹出

**可能原因**：
1. macOS 版本问题
2. 应用没有正确的权限描述

**解决方法**：
- 确保 macOS 版本 >= 13.0
- 检查 Info.plist 是否包含权限描述（见下文）

#### Q3: 授权后状态还是红色

**可能原因**：
1. 状态没有刷新
2. 权限检测逻辑有问题

**解决方法**：
- 点击"刷新状态"按钮
- 重启应用
- 检查 Xcode 控制台的错误日志

### Info.plist 权限描述

确保 Info.plist 包含以下权限描述：

```xml
<key>NSCalendarsUsageDescription</key>
<string>需要访问日历以创建日程事件</string>

<key>NSRemindersUsageDescription</key>
<string>需要访问提醒事项以创建待办事项</string>

<key>NSAppleEventsUsageDescription</key>
<string>需要辅助功能权限以读取选中的文本</string>
```

### 验证清单

测试完成后，确认以下内容：

- [ ] 日历权限可以请求
- [ ] 日历权限授予后状态变为绿色
- [ ] 提醒事项权限可以请求
- [ ] 提醒事项权限授予后状态变为绿色
- [ ] 辅助功能权限可以打开系统设置
- [ ] 辅助功能权限授予后状态变为绿色
- [ ] 屏幕录制权限可以打开系统设置
- [ ] 屏幕录制权限授予后状态变为绿色
- [ ] "刷新状态"按钮可以手动更新所有权限状态

### 下一步

如果所有权限都正常授予：
1. 测试截图功能
2. 测试文本选择功能
3. 配置 AI API
4. 进行完整的功能测试

如果还有问题，请提供：
1. Xcode 控制台的完整错误日志
2. 具体哪个权限有问题
3. macOS 版本信息
