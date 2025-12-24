//
//  DeviceStorage.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

import Foundation

/// Device storage information
///
/// 设备存储信息，用于获取存储空间、已用空间、可用空间等信息
///
public enum DeviceStorage {

    // MARK: - Storage Queries

    /// Total storage capacity in a formatted string (e.g., "256 GB")
    ///
    /// 总存储容量（格式化字符串，如 "256 GB"）
    public static var totalCapacity: String {
        if let storageInfo = getStorageInfo() {
            return formatBytes(storageInfo.total)
        }
        return "Unknown"
    }

    /// Available (free) storage capacity in a formatted string (e.g., "128.5 GB")
    ///
    /// 可用存储容量（格式化字符串，如 "128.5 GB"）
    public static var availableCapacity: String {
        if let storageInfo = getStorageInfo() {
            return formatBytes(storageInfo.free)
        }
        return "Unknown"
    }

    /// Used storage capacity in a formatted string (e.g., "127.5 GB")
    ///
    /// 已用存储容量（格式化字符串，如 "127.5 GB"）
    public static var usedCapacity: String {
        if let storageInfo = getStorageInfo() {
            return formatBytes(storageInfo.used)
        }
        return "Unknown"
    }

    /// Storage usage progress (0.0 to 1.0)
    ///
    /// 存储使用进度（0.0 到 1.0）
    public static var usageProgress: Float {
        if let storageInfo = getStorageInfo() {
            return Float(storageInfo.used) / Float(storageInfo.total)
        }
        return 0.0
    }

    /// Storage usage percentage (0 to 100)
    ///
    /// 存储使用百分比（0 到 100）
    public static var usagePercentage: Int {
        return Int(usageProgress * 100)
    }

    // MARK: - Raw Values

    /// Total storage capacity in bytes
    ///
    /// 总存储容量（字节）
    public static var totalCapacityInBytes: Int64 {
        return getStorageInfo()?.total ?? 0
    }

    /// Available (free) storage capacity in bytes
    ///
    /// 可用存储容量（字节）
    public static var availableCapacityInBytes: Int64 {
        return getStorageInfo()?.free ?? 0
    }

    /// Used storage capacity in bytes
    ///
    /// 已用存储容量（字节）
    public static var usedCapacityInBytes: Int64 {
        return getStorageInfo()?.used ?? 0
    }

    // MARK: - Private Helpers

    /// Storage information structure
    private struct StorageInfo {
        let total: Int64
        let free: Int64
        let used: Int64
    }

    /// Get detailed storage information
    ///
    /// 获取详细的存储信息
    private static func getStorageInfo() -> StorageInfo? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())

        do {
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])

            if let total = values.volumeTotalCapacity,
               let free = values.volumeAvailableCapacityForImportantUsage {
                let used = Int64(total) - free
                return StorageInfo(total: Int64(total), free: Int64(free), used: Int64(used))
            }
        } catch {
            // Return nil silently - caller should handle this case
        }

        return nil
    }

    /// Format bytes to human-readable string
    ///
    /// 将字节格式化为人类可读字符串
    private static func formatBytes(_ bytes: Int64, units: ByteCountFormatter.Units = .useGB) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = units
        formatter.countStyle = .decimal
        formatter.includesUnit = true
        return formatter.string(fromByteCount: bytes)
    }
}
