//
//  DeviceSystem.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Device system state information
///
/// 设备系统状态信息，用于获取系统启动时间等运行时状态
///
public enum DeviceSystem {

    // MARK: - System State

    /// System boot time
    ///
    /// 系统启动时间
    public static var bootTime: Date? {
        var tv = timeval()
        var tvsize = MemoryLayout<timeval>.size
        let err = sysctlbyname("kern.boottime", &tv, &tvsize, nil, 0)

        guard err == 0, tvsize == MemoryLayout<timeval>.size else {
            return nil
        }

        return Date(timeIntervalSince1970: Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0)
    }

    /// System uptime in seconds
    ///
    /// 系统运行时间（秒）
    public static var uptime: TimeInterval? {
        guard let bootTime = bootTime else {
            return nil
        }
        return Date().timeIntervalSince(bootTime)
    }

    /// System uptime formatted as a human-readable string
    ///
    /// 系统运行时间（可读字符串）
    public static var uptimeString: String {
        guard let uptime = uptime else {
            return "Unknown"
        }

        let timeInterval = Int(uptime)
        let days = timeInterval / 86400
        let hours = (timeInterval % 86400) / 3600
        let minutes = (timeInterval % 3600) / 60

        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// System name (e.g., "iOS")
    ///
    /// 系统名称（如 "iOS"）
    @MainActor
    public static var systemName: String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "macOS"
        #else
        return "Unknown"
        #endif
    }

    /// System version (e.g., "17.2")
    ///
    /// 系统版本（如 "17.2"）
    @MainActor
    public static var systemVersion: String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        #else
        return "Unknown"
        #endif
    }

    /// Device model (e.g., "iPhone")
    ///
    /// 设备型号（如 "iPhone"）
    @MainActor
    public static var deviceModel: String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0)
            }
        }
        return model ?? "Mac"
        #else
        return "Unknown"
        #endif
    }

    /// Localized device model (e.g., "iPhone")
    ///
    /// 本地化设备型号
    @MainActor
    public static var localizedModel: String {
        #if os(iOS)
        return UIDevice.current.localizedModel
        #elseif os(macOS)
        return "Mac"
        #else
        return "Unknown"
        #endif
    }
}
