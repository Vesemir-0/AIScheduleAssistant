# 沙盒限制问题修复指南

## 问题描述

错误日志显示：
```
Sandbox restriction. Error Domain=NSCocoaErrorDomain Code=4099
"The connection to service named com.apple.CalendarAgent was invalidated"
```

这是因为 App Sandbox 阻止了应用访问日历服务。

## 已修复的内容

### 1. 禁用 App Sandbox

修改了 `AIScheduleAssistant_v2.entitlements` 文件：
- 将 `com.apple.security.app-sandbox` 设置为 `false`
- 添加了 `com.apple.security.personal-information.calendars` 权限

### 2. 修复后台线程更新 UI

修改了 `PermissionManager.swift`：
- `checkAllPermissions()` 现在在主线程执行
- 避免了 "Publishing changes from background threads" 警告

## 下一步操作

### 1. 清理构建

在 Xcode 中：
1. 按 `Cmd + Shift + K` 清理构建
2. 或者菜单：Product > Clean Build Folder

### 2. 重新构建

1. 按 `Cmd + B` 重新构建
2. 按 `Cmd + R` 运行应用

### 3. 测试权限

现在测试权限请求应该可以正常工作了：
- 日历权限对话框应该能弹出
- 提醒事项权限对话框应该能弹出
- 不再有沙盒限制错误

## 关于 App Sandbox

### 为什么禁用沙盒？

App Sandbox 是 macOS 的安全机制，但它会限制应用访问某些系统服务。对于这个应用：

**需要的功能**：
- 访问日历和提醒事项
- 使用 Accessibility API 读取文本
- 调用 screencapture 命令
- 访问网络（调用 AI API）

**沙盒限制**：
- 即使添加了日历权限 entitlement，沙盒仍然会阻止某些操作
- Accessibility API 在沙盒中受限
- 调用外部命令（screencapture）在沙盒中受限

### 安全性考虑

禁用沙盒后，应用仍然需要用户明确授权：
- ✅ 日历权限需要用户授权
- ✅ 提醒事项权限需要用户授权
- ✅ 辅助功能权限需要用户在系统设置中启用
- ✅ 屏幕录制权限需要用户在系统设置中启用

### 如果要发布到 App Store

如果将来要发布到 App Store，需要：
1. 重新启用沙盒
2. 添加所有必要的 entitlements
3. 可能需要调整实现方式以符合沙盒要求
4. 或者选择在 App Store 外发布（直接下载）

## 验证修复

运行应用后，检查 Xcode 控制台：

**修复前**：
```
Sandbox restriction. Error Domain=NSCocoaErrorDomain Code=4099
Publishing changes from background threads is not allowed
```

**修复后**：
- 不再有沙盒错误
- 不再有后台线程警告
- 权限请求对话框正常弹出

## 如果还有问题

### 问题：权限对话框还是不弹出

**解决方法**：
1. 完全退出应用
2. 在终端运行：
   ```bash
   tccutil reset All com.yourcompany.AIScheduleAssistant-v2
   ```
3. 重新运行应用

### 问题：还是有沙盒错误

**检查**：
1. 确认 entitlements 文件已保存
2. 在 Xcode 中检查 Target > Signing & Capabilities
3. 确认 "App Sandbox" 已关闭或删除
4. 清理构建并重新编译

### 问题：应用无法运行

**可能原因**：
- 签名问题
- 需要在 Xcode 中重新配置签名

**解决方法**：
1. 打开 Xcode
2. 选择 Target > Signing & Capabilities
3. 确认 "Automatically manage signing" 已勾选
4. 选择你的开发团队

## 总结

修复后的配置：
- ✅ App Sandbox: 禁用
- ✅ 日历权限: 已添加
- ✅ 主线程更新: 已修复
- ✅ 适合开发和测试
- ⚠️ 如需 App Store 发布，需要额外配置
