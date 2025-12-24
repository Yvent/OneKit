//
//  PermissionStatus.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// Permission status
///
/// 权限状态
public enum PermissionStatus: Equatable, Sendable {
    /// Permission not yet requested
    /// 尚未请求权限
    case notDetermined

    /// Permission granted
    /// 权限已授予
    case authorized

    /// Permission denied
    /// 权限已拒绝
    case denied

    /// Permission restricted (e.g., parental controls)
    /// 权限受限（如家长控制）
    case restricted

    /// Limited access granted (e.g., Photos picker)
    /// 有限访问权限
    case limited
}
