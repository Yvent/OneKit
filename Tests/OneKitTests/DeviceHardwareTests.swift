//
//  DeviceHardwareTests.swift
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

@Suite("Device Hardware Tests")
struct DeviceHardwareTests {

    // MARK: - CPU Count Tests

    /// Test CPU count is positive
    /// 测试CPU核数为正数
    @Test("CPU count should be positive")
    func cpuCountPositive() async throws {
        let cpuCount = DeviceHardware.cpuCount
        #expect(cpuCount > 0)
    }

    /// Test CPU count is reasonable (1-16 cores typical)
    /// 测试CPU核数合理（通常1-16核）
    @Test("CPU count should be within reasonable range")
    func cpuCountReasonable() async throws {
        let cpuCount = DeviceHardware.cpuCount
        // Most modern devices have 1-16 cores
        // 大多数现代设备有1-16核
        #expect(cpuCount >= 1)
        #expect(cpuCount <= 16)
    }

    /// Test CPU count is stable
    /// 测试CPU核数稳定
    @Test("CPU count should be consistent across calls")
    func cpuCountStable() async throws {
        let cpuCount1 = DeviceHardware.cpuCount
        let cpuCount2 = DeviceHardware.cpuCount

        #expect(cpuCount1 == cpuCount2)
    }

    // MARK: - CPU Type Tests

    /// Test CPU type is not empty
    /// 测试CPU类型不为空
    @Test("CPU type should not be empty")
    func cpuTypeNotEmpty() async throws {
        let cpuType = DeviceHardware.cpuType
        #expect(!cpuType.isEmpty)
        #expect(cpuType != "Unknown")
    }

    /// Test CPU type matches expected format
    /// 测试CPU类型匹配预期格式
    @Test("CPU type should match expected format")
    func cpuTypeFormat() async throws {
        let cpuType = DeviceHardware.cpuType
        // Should start with CPU_TYPE_
        // 应该以 CPU_TYPE_ 开头
        #expect(cpuType.hasPrefix("CPU_TYPE_"))
    }

    /// Test CPU type is valid ARM type on iOS
    /// 测试iOS上CPU类型是有效的ARM类型
    @Test("CPU type should be ARM on iOS")
    @available(macOS 11.0, *)
    func cpuTypeValidARM() async throws {
        #if os(iOS)
        let cpuType = DeviceHardware.cpuType
        let armTypes = ["CPU_TYPE_ARM", "CPU_TYPE_ARM64", "CPU_TYPE_ARM64_32"]
        #expect(armTypes.contains(cpuType))
        #endif
    }

    /// Test CPU type is consistent
    /// 测试CPU类型一致
    @Test("CPU type should be consistent across calls")
    func cpuTypeConsistent() async throws {
        let cpuType1 = DeviceHardware.cpuType
        let cpuType2 = DeviceHardware.cpuType

        #expect(cpuType1 == cpuType2)
    }

    // MARK: - Device Name Tests

    /// Test device name is accessible
    /// 测试设备名称可访问
    @MainActor
    @Test("Device name should be accessible")
    func deviceNameAccessible() async throws {
        let deviceName = DeviceHardware.deviceName
        #expect(!deviceName.isEmpty)
    }

    /// Test device name contains reasonable characters
    /// 测试设备名称包含合理字符
    @MainActor
    @Test("Device name should contain reasonable characters")
    func deviceNameCharacters() async throws {
        let deviceName = DeviceHardware.deviceName
        // Should not contain control characters or unusual symbols
        // 不应包含控制字符或不寻常的符号
        #expect(deviceName.allSatisfy { $0.isASCII || $0.isLetter || $0.isNumber || $0 == " " })
    }

    // MARK: - Extended Device Model Name Tests

    /// Test extended device model name is not empty
    /// 测试扩展设备型号名称不为空
    @Test("Extended device model name should not be empty")
    func extendedDeviceModelNameNotEmpty() async throws {
        let modelName = DeviceHardware.extendedDeviceModelName
        #expect(!modelName.isEmpty)
    }

    /// Test extended device model name returns readable string
    /// 测试扩展设备型号名称返回可读字符串
    @Test("Extended device model name should be readable")
    func extendedDeviceModelNameReadable() async throws {
        let modelName = DeviceHardware.extendedDeviceModelName
        // Should not be a raw machine identifier (e.g., "iPhone14,2")
        // 不应该是原始机器标识符（如 "iPhone14,2"）
        let hasCommaNumber = modelName.range(of: #"[A-Za-z]+\d+,\d+"#, options: .regularExpression) != nil
        #expect(!hasCommaNumber)
    }

    /// Test extended device model name contains device type
    /// 测试扩展设备型号名称包含设备类型
    @Test("Extended device model name should contain device type")
    func extendedDeviceModelNameContainsType() async throws {
        let modelName = DeviceHardware.extendedDeviceModelName
        let deviceTypes = ["iPhone", "iPad", "iPod", "Simulator", "Watch", "TV", "AirPods"]

        let containsDeviceType = deviceTypes.contains { modelName.contains($0) }
        #expect(containsDeviceType)
    }

    // MARK: - Integration Tests

    /// Test hardware info is stable
    /// 测试硬件信息稳定
    @Test("Hardware info should be stable across calls")
    func hardwareInfoStability() async throws {
        let cpuCount1 = DeviceHardware.cpuCount
        let cpuCount2 = DeviceHardware.cpuCount

        let cpuType1 = DeviceHardware.cpuType
        let cpuType2 = DeviceHardware.cpuType

        let modelName1 = DeviceHardware.extendedDeviceModelName
        let modelName2 = DeviceHardware.extendedDeviceModelName

        #expect(cpuCount1 == cpuCount2)
        #expect(cpuType1 == cpuType2)
        #expect(modelName1 == modelName2)
    }

    /// Test concurrent access to hardware info
    /// 测试并发访问硬件信息
    @Test("Should handle concurrent access safely")
    func concurrentAccess() async throws {
        async let cpuCount: Int = DeviceHardware.cpuCount
        async let cpuType: String = DeviceHardware.cpuType
        async let modelName: String = DeviceHardware.extendedDeviceModelName

        let results = await (cpuCount, cpuType, modelName)

        #expect(results.0 > 0)
        #expect(!results.1.isEmpty)
        #expect(!results.2.isEmpty)
    }

    // MARK: - Device Type Detection Tests

    /// Test can identify iOS devices
    /// 测试可以识别iOS设备
    @Test("Should identify iOS devices correctly")
    func identifyIOSDevices() async throws {
        let modelName = DeviceHardware.extendedDeviceModelName

        #if os(iOS)
        if !modelName.contains("Simulator") {
            let isIOSDevice = modelName.contains("iPhone") ||
                              modelName.contains("iPad") ||
                              modelName.contains("iPod")
            #expect(isIOSDevice)
        }
        #endif
    }

    /// Test simulator detection
    /// 测试模拟器检测
    @Test("Should detect simulator when running on simulator")
    func simulatorDetection() async throws {
        let modelName = DeviceHardware.extendedDeviceModelName

        #if targetEnvironment(simulator)
        #expect(modelName.contains("Simulator"))
        #endif
    }

    // MARK: - Edge Cases Tests

    /// Test all CPU types return valid format
    /// 测试所有CPU类型返回有效格式
    @Test("All CPU types should have prefix")
    func cpuTypePrefix() async throws {
        let cpuType = DeviceHardware.cpuType
        let validPrefixes = ["CPU_TYPE_", "Unknown"]

        let hasValidPrefix = validPrefixes.contains { cpuType.hasPrefix($0) }
        #expect(hasValidPrefix)
    }
}
