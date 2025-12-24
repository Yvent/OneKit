//
//  PermissionError.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// Permission-related errors
///
/// 权限相关错误
public enum PermissionError: Error, Sendable {
    /// Permission type not supported on current platform
    /// 当前平台不支持此权限类型
    case notSupported(PermissionType)

    /// Permission cannot be requested (e.g., in app extension)
    /// 无法请求权限（如App Extension中）
    case cannotRequest

    /// System settings URL unavailable
    /// 系统设置URL不可用
    case settingsURLUnavailable

    /// Request timed out
    /// 请求超时
    case timeout
}
