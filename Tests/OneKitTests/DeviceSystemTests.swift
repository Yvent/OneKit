//
//  DeviceSystemTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

import Testing
@testable import OneKitCore
import Foundation
#if canImport(UIKit)
import UIKit
#endif

@Suite("Device System Tests")
struct DeviceSystemTests {

    // MARK: - Boot Time Tests

    /// Test boot time is accessible
    /// 测试启动时间可访问
    @Test("Boot time should be accessible")
    func bootTimeAccessible() async throws {
        let bootTime = DeviceSystem.bootTime
        #expect(bootTime != nil)
    }

    /// Test boot time is in the past
    /// 测试启动时间是在过去
    @Test("Boot time should be in the past")
    func bootTimeInPast() async throws {
        guard let bootTime = DeviceSystem.bootTime else {
            return
        }

        let now = Date()
        #expect(bootTime < now)
    }

    /// Test boot time is reasonable (not too long ago)
    /// 测试启动时间合理（不会太久远）
    @Test("Boot time should be reasonable")
    func bootTimeReasonable() async throws {
        guard let bootTime = DeviceSystem.bootTime else {
            return
        }

        let now = Date()
        let timeSinceBoot = now.timeIntervalSince(bootTime)

        // System should have been booted within the last year
        // 系统应该在最近一年内启动过
        let secondsInYear: TimeInterval = 365 * 24 * 60 * 60
        #expect(timeSinceBoot > 0)
        #expect(timeSinceBoot < secondsInYear)
    }

    /// Test boot time is consistent
    /// 测试启动时间一致
    @Test("Boot time should be consistent across calls")
    func bootTimeConsistent() async throws {
        let bootTime1 = DeviceSystem.bootTime
        let bootTime2 = DeviceSystem.bootTime

        #expect(bootTime1 != nil)
        #expect(bootTime2 != nil)
        #expect(bootTime1 == bootTime2)
    }

    // MARK: - Uptime Tests

    /// Test uptime is accessible
    /// 测试运行时间可访问
    @Test("Uptime should be accessible")
    func uptimeAccessible() async throws {
        let uptime = DeviceSystem.uptime
        #expect(uptime != nil)
    }

    /// Test uptime is positive
    /// 测试运行时间为正数
    @Test("Uptime should be positive")
    func uptimePositive() async throws {
        guard let uptime = DeviceSystem.uptime else {
            return
        }

        #expect(uptime > 0)
    }

    /// Test uptime is reasonable (not too long)
    /// 测试运行时间合理（不会太长）
    @Test("Uptime should be reasonable")
    func uptimeReasonable() async throws {
        guard let uptime = DeviceSystem.uptime else {
            return
        }

        // Uptime should be less than a year
        // 运行时间应该小于一年
        let secondsInYear: TimeInterval = 365 * 24 * 60 * 60
        #expect(uptime > 0)
        #expect(uptime < secondsInYear)
    }

    /// Test uptime increases over time
    /// 测试运行时间随时间增加
    @Test("Uptime should increase over time")
    func uptimeIncreases() async throws {
        let uptime1 = DeviceSystem.uptime
        // Small delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        let uptime2 = DeviceSystem.uptime

        guard let u1 = uptime1, let u2 = uptime2 else {
            return
        }

        #expect(u2 >= u1)
    }

    // MARK: - Uptime String Tests

    /// Test uptime string is not empty
    /// 测试运行时间字符串不为空
    @Test("Uptime string should not be empty")
    func uptimeStringNotEmpty() async throws {
        let uptimeString = DeviceSystem.uptimeString
        #expect(!uptimeString.isEmpty)
        #expect(uptimeString != "Unknown")
    }

    /// Test uptime string contains time units
    /// 测试运行时间字符串包含时间单位
    @Test("Uptime string should contain time units")
    func uptimeStringContainsUnits() async throws {
        let uptimeString = DeviceSystem.uptimeString
        let timeUnits = ["d", "h", "m"]

        let containsUnit = timeUnits.contains { uptimeString.contains($0) }
        #expect(containsUnit)
    }

    /// Test uptime string format is valid
    /// 测试运行时间字符串格式有效
    @Test("Uptime string should have valid format")
    func uptimeStringFormat() async throws {
        let uptimeString = DeviceSystem.uptimeString

        // Should match pattern like "2d 5h 30m" or "5h 30m" or "30m"
        // 应该匹配类似 "2d 5h 30m" 或 "5h 30m" 或 "30m" 的模式
        let hasValidPattern = uptimeString.range(of: #"^\d+[dhm](\s+\d+[dhm])?(\s+\d+[dhm])?$"#, options: .regularExpression) != nil
        #expect(hasValidPattern)
    }

    // MARK: - System Name Tests

    /// Test system name is not empty
    /// 测试系统名称不为空
    @MainActor
    @Test("System name should not be empty")
    func systemNameNotEmpty() async throws {
        let systemName = DeviceSystem.systemName
        #expect(!systemName.isEmpty)
    }

    /// Test system name is iOS on iOS devices
    /// 测试iOS设备上系统名称是iOS
    @MainActor
    @Test("System name should be iOS on iOS devices")
    func systemNameIOS() async throws {
        #if os(iOS)
        let systemName = DeviceSystem.systemName
        #expect(systemName == "iOS")
        #endif
    }

    // MARK: - System Version Tests

    /// Test system version is not empty
    /// 测试系统版本不为空
    @MainActor
    @Test("System version should not be empty")
    func systemVersionNotEmpty() async throws {
        let systemVersion = DeviceSystem.systemVersion
        #expect(!systemVersion.isEmpty)
    }

    /// Test system version format is valid
    /// 测试系统版本格式有效
    @MainActor
    @Test("System version should have valid format")
    func systemVersionFormat() async throws {
        let systemVersion = DeviceSystem.systemVersion

        // On macOS, version might be "Unknown", skip validation in that case
        // 在 macOS 上，版本可能是 "Unknown"，这种情况下跳过验证
        if systemVersion == "Unknown" {
            return
        }

        // Should match pattern like "17.2" or "16.5.1"
        // 应该匹配类似 "17.2" 或 "16.5.1" 的模式
        let hasValidFormat = systemVersion.range(of: #"^\d+(\.\d+)+$"#, options: .regularExpression) != nil
        #expect(hasValidFormat)
    }

    /// Test system version is reasonable
    /// 测试系统版本合理
    @MainActor
    @Test("System version should be reasonable")
    func systemVersionReasonable() async throws {
        let systemVersion = DeviceSystem.systemVersion

        // iOS versions start from 2.0, current is around 17-18
        // iOS版本从2.0开始，当前大约17-18
        if let majorVersion = systemVersion.split(separator: ".").first,
           let version = Int(majorVersion) {
            #expect(version >= 2)
            #expect(version <= 30) // Allow for future versions
        }
    }

    // MARK: - Device Model Tests

    /// Test device model is not empty
    /// 测试设备型号不为空
    @MainActor
    @Test("Device model should not be empty")
    func deviceModelNotEmpty() async throws {
        let deviceModel = DeviceSystem.deviceModel
        #expect(!deviceModel.isEmpty)
    }

    /// Test device model contains expected value on iOS
    /// 测试iOS上设备型号包含预期值
    @MainActor
    @Test("Device model should be valid on iOS")
    func deviceModelValid() async throws {
        #if os(iOS)
        let deviceModel = DeviceSystem.deviceModel
        let expectedModels = ["iPhone", "iPad", "iPod touch"]
        #expect(expectedModels.contains(deviceModel))
        #endif
    }

    // MARK: - Integration Tests

    /// Test system info is stable across calls
    /// 测试系统信息在多次调用间保持稳定
    @MainActor
    @Test("System info should be stable across calls")
    func systemInfoStability() async throws {
        let systemName1 = DeviceSystem.systemName
        let systemName2 = DeviceSystem.systemName

        let systemVersion1 = DeviceSystem.systemVersion
        let systemVersion2 = DeviceSystem.systemVersion

        let bootTime1 = DeviceSystem.bootTime
        let bootTime2 = DeviceSystem.bootTime

        #expect(systemName1 == systemName2)
        #expect(systemVersion1 == systemVersion2)
        #expect(bootTime1 == bootTime2)
    }

    /// Test uptime and boot time consistency
    /// 测试运行时间和启动时间的一致性
    @Test("Uptime and boot time should be consistent")
    func uptimeBootTimeConsistency() async throws {
        guard let bootTime = DeviceSystem.bootTime,
              let uptime = DeviceSystem.uptime else {
            return
        }

        let now = Date()
        let calculatedUptime = now.timeIntervalSince(bootTime)

        // Uptime should be approximately equal to (now - bootTime)
        // 运行时间应该约等于（现在 - 启动时间）
        let difference = abs(calculatedUptime - uptime)
        let tolerance: TimeInterval = 1.0 // 1 second tolerance

        #expect(difference < tolerance)
    }

    /// Test concurrent access to system info
    /// 测试并发访问系统信息
    @Test("Should handle concurrent access safely")
    func concurrentAccess() async throws {
        async let bootTime: Date? = DeviceSystem.bootTime
        async let uptime: TimeInterval? = DeviceSystem.uptime
        async let systemName: String = DeviceSystem.systemName

        let results = await (bootTime, uptime, systemName)

        #expect(results.0 != nil)
        #expect(results.1 != nil)
        #expect(!results.2.isEmpty)
    }

    // MARK: - Edge Cases Tests

    /// Test all system info returns non-unknown values
    /// 测试所有系统信息返回非Unknown值
    @MainActor
    @Test("System info should not return Unknown")
    func systemInfoNoUnknown() async throws {
        let systemName = DeviceSystem.systemName
        let systemVersion = DeviceSystem.systemVersion
        let deviceModel = DeviceSystem.deviceModel
        let localizedModel = DeviceSystem.localizedModel

        // On iOS/macOS, these should not be "Unknown"
        // On other platforms, they might be
        #if os(iOS) || os(macOS)
        #expect(systemName != "Unknown")
        #expect(systemVersion != "Unknown")
        #expect(deviceModel != "Unknown")
        #expect(localizedModel != "Unknown")
        #endif
    }
}
