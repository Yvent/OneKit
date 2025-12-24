//
//  PermissionResult.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// Permission request result
///
/// 权限请求结果
public enum PermissionResult: Equatable, Sendable {
    /// Permission granted
    /// 权限已授予
    case granted

    /// Permission denied
    /// 权限已拒绝
    case denied

    /// Permission restricted
    /// 权限受限
    case restricted
}

/// Batch permission request result
///
/// 批量权限请求结果
public struct BatchPermissionResult: Sendable {
    /// Results for each permission type
    /// 各权限类型的请求结果
    public let results: [PermissionType: PermissionResult]

    /// Overall success status
    /// 总体成功状态
    public let allGranted: Bool

    public init(results: [PermissionType: PermissionResult]) {
        self.results = results
        self.allGranted = results.allSatisfy { $0.value == .granted }
    }
}
