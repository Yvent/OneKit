//
//  PermissionManager.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// PermissionManager
///
/// Unified permission management API for iOS and macOS.
/// Provides type-safe, async permission request functionality.
///
/// 统一的权限管理API，支持iOS和macOS。
/// 提供类型安全的异步权限请求功能。
///
/// Example:
/// ```swift
/// import OneKitCore
///
/// // Check permission status
/// let status = await PermissionManager.camera.status
///
/// // Request permission
/// let result = await PermissionManager.camera.request()
///
/// // Batch request
/// let results = await PermissionManager.request([
///     .camera, .microphone, .photoLibrary
/// ])
/// ```
public enum PermissionManager {

    // MARK: - Configuration

    /// Automatically show settings alert when permission is denied
    ///
    /// 当权限被拒绝时自动显示设置引导弹窗
    ///
    /// When enabled, if a user denies a permission and requests it again,
    /// an alert will be shown prompting them to go to Settings.
    ///
    /// 启用后，如果用户拒绝权限后再次请求，会显示弹窗引导用户前往设置。
    ///
    /// Default: true
    ///
    /// To disable and handle denied permissions manually:
    /// ```swift
    /// PermissionManager.autoShowSettingsAlert = false
    /// ```
    public nonisolated(unsafe) static var autoShowSettingsAlert: Bool = true

    /// Custom permission denied handler
    ///
    /// 自定义权限拒绝处理器
    ///
    /// If provided, this handler will be called when a permission is denied.
    /// Return true to indicate you've handled the alert yourself,
    /// or false to use the default OneKit alert.
    ///
    /// 如果提供了这个处理器，当权限被拒绝时会被调用。
    /// 返回 true 表示你已经自己处理了弹窗，
    /// 返回 false 则使用 OneKit 的默认弹窗。
    ///
    /// Example:
    /// ```swift
    /// PermissionManager.permissionDeniedHandler = { type in
    ///     // Show custom alert
    ///     myCustomAlert(for: type)
    ///     return true  // Handled, don't show default alert
    /// }
    /// ```
    public nonisolated(unsafe) static var permissionDeniedHandler: ((PermissionType) -> Bool)?

    /// Custom alert configuration
    ///
    /// 自定义权限弹窗配置
    ///
    /// Configure all aspects of permission alerts for specific permission types.
    /// This includes title, message, and button titles.
    ///
    /// 为特定权限配置弹窗的所有文案，包括标题、消息和按钮。
    ///
    /// Example:
    /// ```swift
    /// PermissionManager.customAlertConfiguration = [
    ///     .camera: (
    ///         title: "需要相机权限",
    ///         message: "请在设置中开启相机访问权限",
    ///         cancelButton: "取消",
    ///         openSettingsButton: "去设置"
    ///     ),
    ///     .microphone: (
    ///         title: "需要麦克风权限",
    ///         message: "请在设置中开启麦克风访问权限",
    ///         cancelButton: "取消",
    ///         openSettingsButton: "去设置"
    ///     )
    /// ]
    /// ```
    public nonisolated(unsafe) static var customAlertConfiguration: [PermissionType: (title: String, message: String, cancelButton: String, openSettingsButton: String)]?

    // MARK: - Individual Permission APIs

    /// Camera permission
    ///
    /// 相机权限
    public static var camera: PermissionHandle {
        PermissionHandle(type: .camera)
    }

    /// Microphone permission
    ///
    /// 麦克风权限
    public static var microphone: PermissionHandle {
        PermissionHandle(type: .microphone)
    }

    /// Photo library permission
    ///
    /// 相册权限
    public static var photoLibrary: PermissionHandle {
        PermissionHandle(type: .photoLibrary)
    }

    /// Location permission
    ///
    /// 位置权限
    public static var location: PermissionHandle {
        PermissionHandle(type: .location)
    }

    // MARK: - Batch Permission Requests

    /// Request multiple permissions at once
    ///
    /// 批量请求多个权限
    ///
    /// Example:
    /// ```swift
    /// let results = await PermissionManager.request([
    ///     .camera, .microphone
    /// ])
    /// if results.allGranted {
    ///     print("All permissions granted")
    /// }
    /// ```
    ///
    /// - Parameter permissions: Array of permission types to request
    /// - Returns: Batch permission request results
    @discardableResult
    public static func request(_ permissions: [PermissionType]) async -> BatchPermissionResult {
        var results: [PermissionType: PermissionResult] = [:]

        for permission in permissions {
            let handle = PermissionHandle(type: permission)
            let result = await handle.request()
            results[permission] = result
        }

        return BatchPermissionResult(results: results)
    }

    /// Check status of multiple permissions
    ///
    /// 批量检查多个权限状态
    ///
    /// - Parameter permissions: Array of permission types to check
    /// - Returns: Dictionary mapping permission types to their status
    public static func checkStatus(_ permissions: [PermissionType]) async -> [PermissionType: PermissionStatus] {
        var statuses: [PermissionType: PermissionStatus] = [:]

        for permission in permissions {
            let handle = PermissionHandle(type: permission)
            let status = await handle.status
            statuses[permission] = status
        }

        return statuses
    }
}

/// Permission handle for individual permission operations
///
/// 单个权限操作句柄
public struct PermissionHandle: Sendable {
    let type: PermissionType

    /// Check current permission status
    ///
    /// 检查当前权限状态
    ///
    /// Example:
    /// ```swift
    /// let status = await PermissionManager.camera.status
    /// switch status {
    /// case .authorized:
    ///     print("Permission granted")
    /// case .denied:
    ///     print("Permission denied")
    /// default:
    ///     print("Status: \(status)")
    /// }
    /// ```
    ///
    /// - Returns: Current permission status
    public var status: PermissionStatus {
        get async {
            await PermissionProtocolRegistry.status(for: type)
        }
    }

    /// Request permission
    ///
    /// 请求权限
    ///
    /// Example:
    /// ```swift
    /// let result = await PermissionManager.camera.request()
    /// if result == .granted {
    ///     print("Permission granted")
    /// }
    /// ```
    ///
    /// - Returns: Permission request result
    @discardableResult
    public func request() async -> PermissionResult {
        await PermissionProtocolRegistry.request(type)
    }

    /// Open app settings page
    ///
    /// 打开应用设置页面
    ///
    /// Example:
    /// ```swift
    /// try? await PermissionManager.camera.openSettings()
    /// ```
    public func openSettings() async throws {
        try await PermissionProtocolRegistry.openSettings()
    }

    /// Check if permission can be requested
    ///
    /// 检查是否可以请求权限
    ///
    /// - Returns: True if permission can be requested
    public var canRequest: Bool {
        get async {
            await PermissionProtocolRegistry.canRequest(type)
        }
    }
}
