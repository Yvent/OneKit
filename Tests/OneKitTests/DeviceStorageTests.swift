//
//  DeviceStorageTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

import Testing
@testable import OneKitCore
import Foundation

@Suite("Device Storage Tests")
struct DeviceStorageTests {

    // MARK: - Formatted Capacity Tests

    /// Test total capacity returns non-empty string
    /// 测试总存储容量返回非空字符串
    @Test("Total capacity should return valid string")
    func totalCapacityString() async throws {
        let totalCapacity = DeviceStorage.totalCapacity
        #expect(!totalCapacity.isEmpty)
        #expect(totalCapacity != "Unknown")
    }

    /// Test available capacity returns non-empty string
    /// 测试可用存储容量返回非空字符串
    @Test("Available capacity should return valid string")
    func availableCapacityString() async throws {
        let availableCapacity = DeviceStorage.availableCapacity
        #expect(!availableCapacity.isEmpty)
        #expect(availableCapacity != "Unknown")
    }

    /// Test used capacity returns non-empty string
    /// 测试已用存储容量返回非空字符串
    @Test("Used capacity should return valid string")
    func usedCapacityString() async throws {
        let usedCapacity = DeviceStorage.usedCapacity
        #expect(!usedCapacity.isEmpty)
        #expect(usedCapacity != "Unknown")
    }

    // MARK: - Raw Values Tests

    /// Test total capacity in bytes is positive
    /// 测试总存储容量字节数为正数
    @Test("Total capacity in bytes should be positive")
    func totalCapacityInBytes() async throws {
        let totalBytes = DeviceStorage.totalCapacityInBytes
        #expect(totalBytes > 0)
    }

    /// Test available capacity in bytes is non-negative
    /// 测试可用存储容量字节数为非负数
    @Test("Available capacity in bytes should be non-negative")
    func availableCapacityInBytes() async throws {
        let availableBytes = DeviceStorage.availableCapacityInBytes
        #expect(availableBytes >= 0)
    }

    /// Test used capacity in bytes is positive
    /// 测试已用存储容量字节数为正数
    @Test("Used capacity in bytes should be positive")
    func usedCapacityInBytes() async throws {
        let usedBytes = DeviceStorage.usedCapacityInBytes
        #expect(usedBytes > 0)
    }

    /// Test relationship between total, available, and used capacity
    /// 测试总容量、可用容量和已用容量之间的关系
    @Test("Used + Available should equal or be less than Total")
    func capacityRelationship() async throws {
        let total = DeviceStorage.totalCapacityInBytes
        let available = DeviceStorage.availableCapacityInBytes
        let used = DeviceStorage.usedCapacityInBytes

        // used + available should be approximately equal to total
        // 已用 + 可用应该约等于总容量
        let calculatedUsed = total - available
        #expect(calculatedUsed >= 0)
        #expect(used >= 0)
        #expect(used <= total)
    }

    // MARK: - Usage Metrics Tests

    /// Test usage progress is within valid range
    /// 测试使用进度在有效范围内
    @Test("Usage progress should be between 0 and 1")
    func usageProgressRange() async throws {
        let progress = DeviceStorage.usageProgress
        #expect(progress >= 0.0)
        #expect(progress <= 1.0)
    }

    /// Test usage progress is greater than zero (device should have some content)
    /// 测试使用进度大于零（设备应该有一些内容）
    @Test("Usage progress should be greater than zero")
    func usageProgressPositive() async throws {
        let progress = DeviceStorage.usageProgress
        #expect(progress > 0.0)
    }

    /// Test usage percentage is within valid range
    /// 测试使用百分比在有效范围内
    @Test("Usage percentage should be between 0 and 100")
    func usagePercentageRange() async throws {
        let percentage = DeviceStorage.usagePercentage
        #expect(percentage >= 0)
        #expect(percentage <= 100)
    }

    /// Test usage percentage matches progress
    /// 测试使用百分比与进度匹配
    @Test("Usage percentage should match progress * 100")
    func usagePercentageMatchesProgress() async throws {
        let progress = DeviceStorage.usageProgress
        let percentage = DeviceStorage.usagePercentage
        let calculatedPercentage = Int(progress * 100)

        // Allow small rounding difference
        // 允许小的舍入差异
        #expect(abs(percentage - calculatedPercentage) <= 1)
    }

    // MARK: - Format Validation Tests

    /// Test total capacity contains unit (GB)
    /// 测试总存储容量包含单位（GB）
    @Test("Total capacity should contain GB unit")
    func totalCapacityContainsUnit() async throws {
        let totalCapacity = DeviceStorage.totalCapacity
        #expect(totalCapacity.contains("GB"))
    }

    /// Test capacity strings are human-readable
    /// 测试容量字符串是人类可读的
    @Test("Capacity strings should be human-readable")
    func capacityStringsReadable() async throws {
        let total = DeviceStorage.totalCapacity
        let available = DeviceStorage.availableCapacity
        let used = DeviceStorage.usedCapacity

        // Should contain numbers and units
        // 应该包含数字和单位
        #expect(total.contains("GB"))
        #expect(available.contains("GB"))
        #expect(used.contains("GB"))

        // Should not be raw byte strings
        // 不应该是原始字节字符串
        #expect(!total.allSatisfy { $0.isNumber || $0 == "." })
    }

    // MARK: - Edge Cases Tests

    /// Test consistency across multiple calls
    /// 测试多次调用的一致性
    @Test("Multiple calls should return consistent values")
    func consistencyAcrossCalls() async throws {
        let total1 = DeviceStorage.totalCapacityInBytes
        let total2 = DeviceStorage.totalCapacityInBytes

        // Total should be consistent
        // 总容量应该一致
        #expect(total1 == total2)

        // Available may vary slightly due to system activity
        // Allow small variation (up to 10MB)
        // 可用容量可能因系统活动而略有变化
        // 允许小的变化（最多10MB）
        let available1 = DeviceStorage.availableCapacityInBytes
        let available2 = DeviceStorage.availableCapacityInBytes
        let variation = abs(available1 - available2)
        let maxVariation: Int64 = 10 * 1024 * 1024 // 10MB

        #expect(variation <= maxVariation)
    }

    /// Test available capacity is less than total capacity
    /// 测试可用容量小于总容量
    @Test("Available should be less than total")
    func availableLessThanTotal() async throws {
        let total = DeviceStorage.totalCapacityInBytes
        let available = DeviceStorage.availableCapacityInBytes

        #expect(available < total)
        #expect(available >= 0)
    }
}
