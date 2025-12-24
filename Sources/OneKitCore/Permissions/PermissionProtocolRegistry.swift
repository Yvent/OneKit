//
//  PermissionProtocolRegistry.swift
//  OneKit
//
//  Created by OneKit
//

import Foundation

/// Internal permission protocol registry
///
/// 内部权限协议注册表
enum PermissionProtocolRegistry {

    // MARK: - Status

    @MainActor
    static func status(for type: PermissionType) -> PermissionStatus {
        #if os(iOS)
        return iOSPermissionHandler.status(for: type)
        #elseif os(macOS)
        return macOSPermissionHandler.status(for: type)
        #else
        return .notDetermined
        #endif
    }

    // MARK: - Request

    @MainActor
    static func request(_ type: PermissionType) async -> PermissionResult {
        #if os(iOS)
        return await iOSPermissionHandler.request(type)
        #elseif os(macOS)
        return await macOSPermissionHandler.request(type)
        #else
        return .denied
        #endif
    }

    // MARK: - Open Settings

    @MainActor
    static func openSettings() throws {
        #if os(iOS)
        try iOSPermissionHandler.openSettings()
        #elseif os(macOS)
        try macOSPermissionHandler.openSettings()
        #else
        throw PermissionError.settingsURLUnavailable
        #endif
    }

    // MARK: - Can Request

    @MainActor
    static func canRequest(_ type: PermissionType) -> Bool {
        #if os(iOS)
        return iOSPermissionHandler.canRequest(type)
        #elseif os(macOS)
        return macOSPermissionHandler.canRequest(type)
        #else
        return false
        #endif
    }
}
