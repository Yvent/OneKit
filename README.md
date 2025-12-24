# OneKit

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)](https://developer.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](#english) | [简体中文](#简体中文)

---

## English

OneKit is a comprehensive Swift utility library designed to streamline iOS and macOS development. It provides a rich collection of extensions, device information APIs, and UI components to help you build better apps faster.

## Features

### 📱 Device Information
- **Hardware Info**: CPU count, CPU type, device model detection
- **Network Info**: Carrier information (MCC/MNC support for 60+ countries), IP address detection
- **Storage Info**: Total/available/used capacity, usage percentage
- **System Info**: Boot time, uptime, system name and version

### 🎨 UI Extensions
- **Gradient Backgrounds**: Linear, radial, and angular gradients with preset directions
- **Conditional Modifiers**: View modifiers for conditional hiding and accessibility identifiers
- **Color Extensions**: Random color generation, UIColor compatibility

### 🔧 Core Extensions
- **String Extensions**: Rich string manipulation utilities
- **Date Extensions**: Date formatting and calculation utilities
- **UIColor Extensions**: Enhanced color manipulation with random generation

### 🔐 Permission Management
- **PermissionManager**: Type-safe permission handling for Camera, Microphone, Photo Library, and Location
- **Status Query**: Check permission status with async/await
- **Request Permissions**: Batch permission requests with comprehensive results
- **Open Settings**: Convenient method to jump to system settings

### 📦 UI Components
- **ActivityView**: Native share sheet wrapper
- **MailView**: In-app email composer

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add OneKit to your project via Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/Yvent/OneKit.git`
3. Choose the version rule (e.g., "Up to Next Major Version")
4. Click "Add Package"

### Manual Integration

You can also add OneKit directly to your project:

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/Yvent/OneKit.git", from: "1.0.0")
]
```

## Usage

### Device Information

```swift
import OneKitCore

// Hardware Information
let cpuCount = DeviceHardware.cpuCount
let cpuType = DeviceHardware.cpuType
let deviceModel = DeviceHardware.extendedDeviceModelName

// Network Information
let carrierName = DeviceNetwork.carrierName
let carrierCode = DeviceNetwork.carrierCode
let ipAddress = DeviceNetwork.ipAddress

// Storage Information
let totalSpace = DeviceStorage.totalCapacity
let availableSpace = DeviceStorage.availableCapacity
let usedSpace = DeviceStorage.usedCapacity
let usagePercentage = DeviceStorage.usagePercentage

// System Information
let bootTime = DeviceSystem.bootTime
let uptime = DeviceSystem.uptimeString
```

### Gradient Backgrounds

```swift
import OneKitUI

// Vertical gradient
Text("Hello World")
    .gradientBackground(.blue, .purple, direction: .vertical)

// Horizontal gradient
Text("Hello World")
    .gradientBackground(.blue, .purple, direction: .horizontal)

// Custom diagonal gradient
Text("Hello World")
    .gradientBackground(
        Color.foregroundPrimary,
        Color(red: 0.4, green: 0.3, blue: 0.9),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

// Multi-stop gradient
Text("Rainbow")
    .gradientBackground(stops: [
        .init(color: .red, location: 0.0),
        .init(color: .yellow, location: 0.5),
        .init(color: .blue, location: 1.0)
    ])

// Radial gradient
Circle()
    .radialGradientBackground(.blue, .purple)

// Angular gradient
Circle()
    .angularGradientBackground(.blue, .purple, angle: .degrees(45))

// Convenience methods
Text("Hello")
    .verticalGradientBackground(.blue, .purple)
    .horizontalGradientBackground(.red, .orange)
    .diagonalGradientBackground(.green, .blue)
```

### Conditional View Modifiers

```swift
import OneKitUI

// Conditional hiding
Text("Conditional Content")
    .hidden(shouldHide)

// Conditional accessibility identifier
Text("Username")
    .accessibilityIdentifierIfAny(username)
```

### String Extensions

```swift
import OneKitCore

// Validate email
let isValidEmail = "test@example.com".isValidEmail

// Validate phone number
let isValidPhone = "13800138000".isValidPhoneNumber

// Check if string contains only numbers
let isNumeric = "12345".isNumeric
```

### Date Extensions

```swift
import OneKitCore

let date = Date()

// Format as relative time
let relative = date.relativeFormat  // e.g., "2 hours ago"

// Check if date is today
let isToday = date.isToday

// Calculate age
let birthday = Date(timeIntervalSince1970: 1234567890)
let age = birthday.age
```

### Permission Manager

```swift
import OneKitCore

// Check permission status
let status = await PermissionManager.camera.status
if status == .authorized {
    print("Camera access granted")
}

// Request single permission
let result = await PermissionManager.camera.request()
if result == .granted {
    print("Permission granted")
}

// Batch request multiple permissions
let results = await PermissionManager.request([
    .camera, .microphone, .photoLibrary
])
if results.allGranted {
    print("All permissions granted!")
} else {
    for (type, result) in results.results {
        print("\(type): \(result)")
    }
}

// Open app settings
try? await PermissionManager.camera.openSettings()
```

## Modules

OneKit is organized into three main modules:

### OneKit
The main module that re-exports OneKitCore for convenience.

### OneKitCore
Core functionality that doesn't depend on UIKit or SwiftUI:
- Device information APIs
- Foundation type extensions (String, Date, etc.)
- App information utilities

### OneKitUI
UI-specific functionality:
- SwiftUI extensions (View modifiers, Color extensions)
- UI components (ActivityView, MailView)
- UIKit compatibility layer

## Testing

OneKit has comprehensive test coverage:

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter 'DeviceNetworkTests'
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

OneKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

yvente

---

## 简体中文

OneKit 是一个全面的 Swift 工具库，旨在简化 iOS 和 macOS 开发。它提供了丰富的扩展、设备信息 API 和 UI 组件，帮助您更快地构建更好的应用程序。

## 功能特性

### 📱 设备信息
- **硬件信息**: CPU 核心数、CPU 类型、设备型号识别
- **网络信息**: 运营商信息（支持 60+ 国家的 MCC/MNC）、IP 地址检测
- **存储信息**: 总容量/可用容量/已用容量、使用百分比
- **系统信息**: 启动时间、运行时间、系统名称和版本

### 🎨 UI 扩展
- **渐变背景**: 线性、径向和角向渐变，支持预设方向
- **条件修饰符**: 用于条件隐藏和辅助功能标识符的视图修饰符
- **颜色扩展**: 随机颜色生成、UIColor 兼容性

### 🔧 核心扩展
- **字符串扩展**: 丰富的字符串操作工具
- **日期扩展**: 日期格式化和计算工具
- **UIColor 扩展**: 增强的颜色操作和随机生成

### 🔐 权限管理
- **PermissionManager**: 类型安全的权限处理（相机、麦克风、相册、位置）
- **状态查询**: 使用 async/await 检查权限状态
- **请求权限**: 批量权限请求及完整结果
- **打开设置**: 快速跳转到系统设置页面

### 📦 UI 组件
- **ActivityView**: 原生分享视图封装
- **MailView**: 应用内邮件编辑器

## 系统要求

- iOS 15.0+ / macOS 12.0+
- Swift 6.2+
- Xcode 16.0+

## 安装

### Swift Package Manager

通过 Swift Package Manager 添加 OneKit 到您的项目：

1. 在 Xcode 中，前往 **File → Add Package Dependencies...**
2. 输入仓库 URL: `https://github.com/Yvent/OneKit.git`
3. 选择版本规则（例如："Up to Next Major Version"）
4. 点击"Add Package"

### 手动集成

您也可以直接将 OneKit 添加到您的项目：

```swift
// 在 Package.swift 中
dependencies: [
    .package(url: "https://github.com/Yvent/OneKit.git", from: "1.0.0")
]
```

## 使用示例

### 设备信息

```swift
import OneKitCore

// 硬件信息
let cpuCount = DeviceHardware.cpuCount
let cpuType = DeviceHardware.cpuType
let deviceModel = DeviceHardware.extendedDeviceModelName

// 网络信息
let carrierName = DeviceNetwork.carrierName
let carrierCode = DeviceNetwork.carrierCode
let ipAddress = DeviceNetwork.ipAddress

// 存储信息
let totalSpace = DeviceStorage.totalCapacity
let availableSpace = DeviceStorage.availableCapacity
let usedSpace = DeviceStorage.usedCapacity
let usagePercentage = DeviceStorage.usagePercentage

// 系统信息
let bootTime = DeviceSystem.bootTime
let uptime = DeviceSystem.uptimeString
```

### 渐变背景

```swift
import OneKitUI

// 垂直渐变
Text("Hello World")
    .gradientBackground(.blue, .purple, direction: .vertical)

// 水平渐变
Text("Hello World")
    .gradientBackground(.blue, .purple, direction: .horizontal)

// 自定义对角渐变
Text("Hello World")
    .gradientBackground(
        Color.foregroundPrimary,
        Color(red: 0.4, green: 0.3, blue: 0.9),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

// 多点渐变
Text("Rainbow")
    .gradientBackground(stops: [
        .init(color: .red, location: 0.0),
        .init(color: .yellow, location: 0.5),
        .init(color: .blue, location: 1.0)
    ])

// 径向渐变
Circle()
    .radialGradientBackground(.blue, .purple)

// 角向渐变
Circle()
    .angularGradientBackground(.blue, .purple, angle: .degrees(45))

// 便捷方法
Text("Hello")
    .verticalGradientBackground(.blue, .purple)
    .horizontalGradientBackground(.red, .orange)
    .diagonalGradientBackground(.green, .blue)
```

### 条件视图修饰符

```swift
import OneKitUI

// 条件隐藏
Text("条件内容")
    .hidden(shouldHide)

// 条件辅助功能标识符
Text("用户名")
    .accessibilityIdentifierIfAny(username)
```

### 字符串扩展

```swift
import OneKitCore

// 验证邮箱
let isValidEmail = "test@example.com".isValidEmail

// 验证手机号
let isValidPhone = "13800138000".isValidPhoneNumber

// 检查是否只包含数字
let isNumeric = "12345".isNumeric
```

### 日期扩展

```swift
import OneKitCore

let date = Date()

// 相对时间格式化
let relative = date.relativeFormat  // 例如："2小时前"

// 检查是否是今天
let isToday = date.isToday

// 计算年龄
let birthday = Date(timeIntervalSince1970: 1234567890)
let age = birthday.age
```

### 权限管理

```swift
import OneKitCore

// 检查权限状态
let status = await PermissionManager.camera.status
if status == .authorized {
    print("相机访问已授权")
}

// 请求单个权限
let result = await PermissionManager.camera.request()
if result == .granted {
    print("权限已授予")
}

// 批量请求多个权限
let results = await PermissionManager.request([
    .camera, .microphone, .photoLibrary
])
if results.allGranted {
    print("所有权限已授予！")
} else {
    for (type, result) in results.results {
        print("\(type): \(result)")
    }
}

// 打开应用设置
try? await PermissionManager.camera.openSettings()
```

## 模块说明

OneKit 分为三个主要模块：

### OneKit
主模块，方便重新导出 OneKitCore。

### OneKitCore
不依赖 UIKit 或 SwiftUI 的核心功能：
- 设备信息 API
- Foundation 类型扩展（String、Date 等）
- 应用信息工具

### OneKitUI
UI 相关功能：
- SwiftUI 扩展（View 修饰符、Color 扩展）
- UI 组件（ActivityView、MailView）
- UIKit 兼容层

## 测试

OneKit 拥有全面的测试覆盖：

```bash
# 运行所有测试
swift test

# 运行特定测试套件
swift test --filter 'DeviceNetworkTests'
```

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

OneKit 使用 MIT 许可证。更多信息请参见 [LICENSE](LICENSE) 文件。

## 作者

yvente
