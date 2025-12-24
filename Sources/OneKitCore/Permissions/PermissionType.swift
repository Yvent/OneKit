//
//  PermissionType.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// Permission type
///
/// 权限类型
public enum PermissionType: Sendable, CaseIterable, Hashable {
    /// Camera permission
    /// 相机权限
    case camera

    /// Microphone permission
    /// 麦克风权限
    case microphone

    /// Photo library permission
    /// 相册权限
    case photoLibrary

    /// Location permission
    /// 位置权限
    case location
}
