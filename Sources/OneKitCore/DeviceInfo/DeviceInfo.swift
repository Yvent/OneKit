//
//  DeviceInfo.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// DeviceInfo
///
/// A unified entry point for accessing device-related information,
/// such as system version, language, device model, and more.
///
/// 设备信息统一入口，用于获取系统版本、语言、设备型号等设备级信息。
///
public enum DeviceInfo {

    // MARK: - System Info

    /// System version string
    ///
    /// 系统版本信息（如 iOS 17.2）
    @MainActor
    public static var systemVersion: String {
        #if canImport(UIKit)
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #else
        return "Unknown"
        #endif
    }

    // MARK: - Language

    /// Current language name in localized form
    ///
    /// 当前语言名称（本地化显示，如 "中文" 而非 "zh"）
    public static var currentLanguage: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: preferredLanguage)
        return locale.localizedString(forLanguageCode: preferredLanguage) ?? preferredLanguage
    }

    /// Current language code
    ///
    /// 当前语言代码（如 "zh-Hans"、"en"）
    public static var currentLanguageCode: String {
        Locale.preferredLanguages.first ?? "en"
    }

    // MARK: - Device Model

    /// Device model identifier
    ///
    /// 设备型号代码（如 "iPhone14,2"、"iPad13,16"）
    public static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0)
            }
        }
        return model ?? "Unknown"
    }

    /// Device model name (human-readable)
    ///
    /// 设备型号名称（可读形式，如 "iPhone 13 Pro"）
    public static var deviceModelName: String {
        return readableModel(for: deviceModel)
    }

    // MARK: - Private Helpers

    /// Convert device model identifier to readable name
    ///
    /// 将设备型号代码转换为可读名称
    private static func readableModel(for model: String) -> String {
        switch model {
        // iPhone
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd Gen)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,6": return "iPhone SE (3rd Gen)"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"
        case "iPhone17,5": return "iPhone 16e"
        case "iPhone18,1": return "iPhone 17 Pro"
        case "iPhone18,2": return "iPhone 17 Pro Max"
        case "iPhone18,3": return "iPhone 17"
        case "iPhone18,4": return "iPhone Air"

        // iPad Pro
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro 11 (1st Gen)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro 12.9 (3rd Gen)"
        case "iPad8,9", "iPad8,10": return "iPad Pro 11 (2nd Gen)"
        case "iPad8,11", "iPad8,12": return "iPad Pro 12.9 (4th Gen)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro 11 (3rd Gen)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro 12.9 (5th Gen)"
        case "iPad14,3", "iPad14,4": return "iPad Pro 11 (4th Gen)"
        case "iPad14,5", "iPad14,6": return "iPad Pro 12.9 (6th Gen)"
        case "iPad16,3", "iPad16,4": return "iPad Pro 11 (5th Gen)"
        case "iPad16,5", "iPad16,6": return "iPad Pro 12.9 (7th Gen)"

        // iPad Air
        case "iPad11,3", "iPad11,4": return "iPad Air (4th Gen)"
        case "iPad13,1", "iPad13,2": return "iPad Air (5th Gen)"
        case "iPad13,16", "iPad13,17": return "iPad Air (6th Gen)"
        case "iPad14,8", "iPad14,9": return "iPad Air (7th Gen)"
        case "iPad14,10", "iPad14,11": return "iPad Air (7th Gen)"

        // iPad
        case "iPad11,6", "iPad11,7": return "iPad (8th Gen)"
        case "iPad12,1", "iPad12,2": return "iPad (9th Gen)"
        case "iPad13,18", "iPad13,19": return "iPad (10th Gen)"
        case "iPad13,20", "iPad13,21", "iPad13,22": return "iPad (10th Gen)"

        // iPad mini
        case "iPad11,1", "iPad11,2": return "iPad mini (5th Gen)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th Gen)"
        case "iPad16,1", "iPad16,2": return "iPad mini (7th Gen)"

        // iPod
        case "iPod9,1": return "iPod touch (7th Gen)"

        // Simulator
        case "i386", "x86_64", "arm64": return "Simulator"

        // Unknown
        default: return model
        }
    }
}
