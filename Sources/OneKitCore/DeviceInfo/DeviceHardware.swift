//
//  DeviceHardware.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Device hardware information
///
/// 设备硬件信息，用于获取CPU信息、设备名称等
///
public enum DeviceHardware {

    // MARK: - CPU

    /// Number of CPU cores
    ///
    /// CPU核数
    public static var cpuCount: Int {
        var ncpu: UInt = UInt(0)
        var len: size_t = MemoryLayout.size(ofValue: ncpu)
        sysctlbyname("hw.ncpu", &ncpu, &len, nil, 0)
        return Int(ncpu)
    }

    /// CPU type (e.g., "CPU_TYPE_ARM64")
    ///
    /// CPU类型
    public static var cpuType: String {
        let HOST_BASIC_INFO_COUNT = MemoryLayout<host_basic_info>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_BASIC_INFO_COUNT)
        var hostInfo = host_basic_info()

        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_info(mach_host_self(), Int32(HOST_BASIC_INFO), $0, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return "Unknown"
        }

        switch hostInfo.cpu_type {
        case CPU_TYPE_ARM: return "CPU_TYPE_ARM"
        case CPU_TYPE_ARM64: return "CPU_TYPE_ARM64"
        case CPU_TYPE_ARM64_32: return "CPU_TYPE_ARM64_32"
        case CPU_TYPE_X86: return "CPU_TYPE_X86"
        case CPU_TYPE_X86_64: return "CPU_TYPE_X86_64"
        case CPU_TYPE_ANY: return "CPU_TYPE_ANY"
        case CPU_TYPE_VAX: return "CPU_TYPE_VAX"
        case CPU_TYPE_MC680x0: return "CPU_TYPE_MC680x0"
        case CPU_TYPE_I386: return "CPU_TYPE_I386"
        case CPU_TYPE_MC98000: return "CPU_TYPE_MC98000"
        case CPU_TYPE_HPPA: return "CPU_TYPE_HPPA"
        case CPU_TYPE_MC88000: return "CPU_TYPE_MC88000"
        case CPU_TYPE_SPARC: return "CPU_TYPE_SPARC"
        case CPU_TYPE_I860: return "CPU_TYPE_I860"
        case CPU_TYPE_POWERPC: return "CPU_TYPE_POWERPC"
        case CPU_TYPE_POWERPC64: return "CPU_TYPE_POWERPC64"
        default: return "Unknown"
        }
    }

    // MARK: - Device Name

    /// User-defined device name (e.g., "张三的 iPhone")
    ///
    /// 用户定义的设备名称
    @MainActor
    public static var deviceName: String {
        #if canImport(UIKit)
        return UIDevice.current.name
        #else
        return "Unknown"
        #endif
    }

    /// Extended device model name mapping
    ///
    /// 扩展的设备型号名称映射（包含更多旧设备型号）
    public static var extendedDeviceModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return readableModel(for: identifier)
    }

    // MARK: - Private Helpers

    /// Convert device model identifier to readable name (extended version)
    ///
    /// 将设备型号代码转换为可读名称（扩展版本，包含更多旧设备）
    private static func readableModel(for model: String) -> String {
        switch model {
        // iPod
        case "iPod1,1": return "iPod Touch 1G"
        case "iPod2,1": return "iPod Touch 2G"
        case "iPod3,1": return "iPod Touch 3G"
        case "iPod4,1": return "iPod Touch 4G"
        case "iPod5,1": return "iPod Touch (5th Gen)"
        case "iPod7,1": return "iPod touch 6G"
        case "iPod9,1": return "iPod touch (7th Gen)"

        // iPhone
        case "iPhone1,1": return "iPhone 2G"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5C"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5S"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE (1st Gen)"
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
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"

        // iPad
        case "iPad1,1": return "iPad"
        case "iPad1,2": return "iPad 3G"
        case "iPad2,1": return "iPad 2 (WiFi)"
        case "iPad2,2": return "iPad 2 (GSM)"
        case "iPad2,3": return "iPad 2 (CDMA)"
        case "iPad2,4": return "iPad 2"
        case "iPad2,5": return "iPad Mini (WiFi)"
        case "iPad2,6": return "iPad Mini (GSM)"
        case "iPad2,7": return "iPad Mini (CDMA)"
        case "iPad3,1": return "iPad 3 (WiFi)"
        case "iPad3,2": return "iPad 3 (GSM+CDMA)"
        case "iPad3,3": return "iPad 3"
        case "iPad3,4": return "iPad 4 (WiFi)"
        case "iPad3,5": return "iPad 4"
        case "iPad3,6": return "iPad 4 (GSM+CDMA)"
        case "iPad4,1": return "iPad Air (WiFi)"
        case "iPad4,2": return "iPad Air (Cellular)"
        case "iPad4,4": return "iPad Mini 2 (WiFi)"
        case "iPad4,5": return "iPad Mini 2 (Cellular)"
        case "iPad4,6": return "iPad Mini 2"
        case "iPad4,7": return "iPad Mini 3 (WiFi)"
        case "iPad4,8": return "iPad Mini 3 (Cellular)"
        case "iPad4,9": return "iPad Mini 3"
        case "iPad5,1": return "iPad Mini 4 (WiFi)"
        case "iPad5,2": return "iPad Mini 4 (LTE)"
        case "iPad5,3": return "iPad Air 2 (WiFi)"
        case "iPad5,4": return "iPad Air 2 (Cellular)"
        case "iPad6,3": return "iPad Pro 9.7 (WiFi)"
        case "iPad6,4": return "iPad Pro 9.7 (Cellular)"
        case "iPad6,7": return "iPad Pro 12.9 (WiFi)"
        case "iPad6,8": return "iPad Pro 12.9 (Cellular)"
        case "iPad6,11": return "iPad (5th Gen, WiFi)"
        case "iPad6,12": return "iPad (5th Gen, Cellular)"
        case "iPad7,1": return "iPad Pro 12.9 (2nd Gen, WiFi)"
        case "iPad7,2": return "iPad Pro 12.9 (2nd Gen, Cellular)"
        case "iPad7,3": return "iPad Pro 10.5 (WiFi)"
        case "iPad7,4": return "iPad Pro 10.5 (Cellular)"
        case "iPad7,5", "iPad7,6": return "iPad (6th Gen)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro 11 (1st Gen)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro 12.9 (3rd Gen)"
        case "iPad8,9", "iPad8,10": return "iPad Pro 11 (2nd Gen)"
        case "iPad8,11", "iPad8,12": return "iPad Pro 12.9 (4th Gen)"
        case "iPad11,1", "iPad11,2": return "iPad Mini (5th Gen)"
        case "iPad11,3", "iPad11,4": return "iPad Air (4th Gen)"
        case "iPad11,6", "iPad11,7": return "iPad (8th Gen)"
        case "iPad12,1", "iPad12,2": return "iPad (9th Gen)"
        case "iPad13,1", "iPad13,2": return "iPad Air (5th Gen)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro 11 (3rd Gen)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro 12.9 (5th Gen)"
        case "iPad13,16", "iPad13,17": return "iPad Air (6th Gen)"
        case "iPad13,18", "iPad13,19": return "iPad (10th Gen, WiFi)"
        case "iPad13,20", "iPad13,21", "iPad13,22": return "iPad (10th Gen, Cellular)"
        case "iPad14,1", "iPad14,2": return "iPad Mini (6th Gen)"
        case "iPad14,3", "iPad14,4": return "iPad Pro 11 (4th Gen)"
        case "iPad14,5", "iPad14,6": return "iPad Pro 12.9 (6th Gen)"
        case "iPad14,8", "iPad14,9": return "iPad Air (7th Gen, WiFi)"
        case "iPad14,10", "iPad14,11": return "iPad Air (7th Gen, Cellular)"
        case "iPad16,1", "iPad16,2": return "iPad Mini (7th Gen)"
        case "iPad16,3", "iPad16,4": return "iPad Pro 11 (5th Gen)"
        case "iPad16,5", "iPad16,6": return "iPad Pro 12.9 (7th Gen)"

        // Apple Watch
        case "Watch1,1", "Watch1,2": return "Apple Watch (1st Gen)"
        case "Watch2,6", "Watch2,7": return "Apple Watch Series 1"
        case "Watch2,3", "Watch2,4": return "Apple Watch Series 2"
        case "Watch3,1", "Watch3,2", "Watch3,3", "Watch3,4": return "Apple Watch Series 3"
        case "Watch4,1", "Watch4,2", "Watch4,3", "Watch4,4": return "Apple Watch Series 4"

        // Apple TV
        case "AppleTV2,1": return "Apple TV 2"
        case "AppleTV3,1", "AppleTV3,2": return "Apple TV 3"
        case "AppleTV5,3": return "Apple TV 4"
        case "AppleTV6,2": return "Apple TV 4K"

        // AirPods
        case "AirPods1,1": return "AirPods (1st Gen)"

        // Simulator
        case "i386", "x86_64", "arm64": return "Simulator"

        default: return model
        }
    }
}
