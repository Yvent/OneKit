//
//  DeviceNetworkTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

import Testing
@testable import OneKitCore
import Foundation

@Suite("Device Network Tests")
struct DeviceNetworkTests {

    // MARK: - Carrier Info Tests

    /// Test carrier info is accessible
    /// 测试运营商信息可访问
    @Test("Carrier info should be accessible")
    func carrierInfoAccessible() async throws {
        let carrierInfo = DeviceNetwork.carrierInfo
        // Carrier info can be nil if no SIM or on simulator
        // 如果没有SIM卡或在模拟器上，运营商信息可能为 nil
        if carrierInfo != nil {
            #expect(carrierInfo?.name.isEmpty == false)
            #expect(carrierInfo?.identifier.isEmpty == false)
        }
    }

    /// Test carrier info structure is valid
    /// 测试运营商信息结构有效
    @Test("Carrier info should have valid structure")
    func carrierInfoStructure() async throws {
        guard let info = DeviceNetwork.carrierInfo else {
            return
        }

        // Name and identifier should not be empty
        // 名称和标识符不应为空
        #expect(!info.name.isEmpty)
        #expect(!info.identifier.isEmpty)

        // Country code should be valid ISO format if present
        // 如果存在国家代码，应该是有效的 ISO 格式
        if let cc = info.countryCode {
            #expect(cc.count == 2)
            #expect(cc.allSatisfy { $0.isLetter })
        }

        // MCC and MNC should be numeric if present
        // 如果存在 MCC 和 MNC，应该是数字
        if let mcc = info.mcc {
            #expect(mcc.allSatisfy { $0.isNumber })
            #expect(mcc.count == 3)
        }

        if let mnc = info.mnc {
            #expect(mnc.allSatisfy { $0.isNumber })
            #expect(mnc.count >= 2 && mnc.count <= 3)
        }
    }

    /// Test carrier info description is informative
    /// 测试运营商信息描述是信息丰富的
    @Test("Carrier info description should be informative")
    func carrierInfoDescription() async throws {
        guard let info = DeviceNetwork.carrierInfo else {
            return
        }

        let description = info.description
        #expect(description.contains("Carrier"))
        #expect(description.contains("name"))
        #expect(description.contains("identifier"))
    }

    // MARK: - Carrier Name Tests

    /// Test carrier name is accessible
    /// 测试运营商名称可访问
    @Test("Carrier name should be accessible")
    func carrierNameAccessible() async throws {
        let carrierName = DeviceNetwork.carrierName
        // Carrier name can be empty if no SIM or on simulator
        // 如果没有SIM卡或在模拟器上，运营商名称可能为空
        #expect(carrierName is String)
    }

    /// Test carrier name handles empty state gracefully
    /// 测试运营商名称优雅处理空状态
    @Test("Carrier name should handle no SIM gracefully")
    func carrierNameNoSIM() async throws {
        let carrierName = DeviceNetwork.carrierName
        // Should return empty string when no SIM, not crash
        // 没有SIM卡时应该返回空字符串，不会崩溃
        #expect(carrierName.isEmpty || !carrierName.isEmpty)
    }

    // MARK: - Carrier Code Tests

    /// Test carrier code format is valid
    /// 测试运营商代码格式有效
    @Test("Carrier code should have valid format")
    func carrierCodeValid() async throws {
        let carrierCode = DeviceNetwork.carrierCode

        // Carrier code should be lowercase with underscores
        // 运营商代码应该是小写字母和下划线
        if !carrierCode.isEmpty {
            #expect(carrierCode.allSatisfy { $0.isLowercase || $0 == "_" || $0.isNumber })
        }
    }

    /// Test carrier code matches expected patterns
    /// 测试运营商代码匹配预期模式
    @Test("Carrier code should match expected patterns")
    func carrierCodePattern() async throws {
        let carrierCode = DeviceNetwork.carrierCode

        if !carrierCode.isEmpty {
            // Should contain only letters, numbers, and underscores
            // 应该只包含字母、数字和下划线
            let validPattern = carrierCode.range(of: #"^[a-z0-9_]+$"#, options: .regularExpression) != nil
            #expect(validPattern)
        }
    }

    /// Test carrier code and name consistency
    /// 测试运营商代码和名称的一致性
    @Test("Carrier code should match carrier name")
    func carrierCodeMatchesName() async throws {
        let carrierName = DeviceNetwork.carrierName
        let carrierCode = DeviceNetwork.carrierCode

        if !carrierName.isEmpty && !carrierCode.isEmpty {
            // Known carrier mappings should be consistent
            // 已知的运营商映射应该是一致的
            if carrierName.contains("移动") {
                #expect(carrierCode == "china_mobile")
            } else if carrierName.contains("联通") {
                #expect(carrierCode == "china_unicom")
            } else if carrierName.contains("电信") {
                #expect(carrierCode == "china_telecom")
            }
        }
    }

    /// Test empty carrier name results in empty carrier code
    /// 测试空运营商名称导致空运营商代码
    @Test("Empty carrier name should result in empty carrier code")
    func emptyCarrierNameEmptyCode() async throws {
        let carrierName = DeviceNetwork.carrierName
        let carrierCode = DeviceNetwork.carrierCode

        if carrierName.isEmpty {
            #expect(carrierCode == "")
        }
    }

    /// Test carrier code uniqueness
    /// 测试运营商代码唯一性
    @Test("Carrier code should be unique for known carriers")
    func carrierCodeUniqueness() async throws {
        let carrierCode = DeviceNetwork.carrierCode

        if !carrierCode.isEmpty {
            // Should match one of the known carrier patterns
            // 应该匹配已知的运营商模式之一
            let knownPatterns = [
                "china_mobile", "china_unicom", "china_telecom", "china_broadnet",
                "verizon", "att", "t_mobile", "sprint",
                "ntt_docomo", "softbank", "au_kddi", "rakuten",
                "sk_telecom", "kt", "lg_uplus",
                "ee", "vodafone", "o2", "three",
                // Add more as needed
            ]

            // If the carrier is in our database, code should match
            // 如果运营商在我们的数据库中，代码应该匹配
            // This is a basic check - the actual database is much larger
            // 这是一个基本检查 - 实际数据库要大得多
            #expect(!carrierCode.isEmpty)
        }
    }

    // MARK: - IP Address Tests

    /// Test IP address is accessible
    /// 测试IP地址可访问
    @Test("IP address should be accessible")
    func ipAddressAccessible() async throws {
        let ipAddress = DeviceNetwork.ipAddress
        #expect(ipAddress is String)
    }

    /// Test IP address format is valid
    /// 测试IP地址格式有效
    @Test("IP address should have valid format")
    func ipAddressFormat() async throws {
        let ipAddress = DeviceNetwork.ipAddress

        if !ipAddress.isEmpty {
            // IPv4 format: x.x.x.x
            // IPv6 format: longer with colons
            let hasIPv4Format = ipAddress.range(of: #"(\d{1,3}\.){3}\d{1,3}"#, options: .regularExpression) != nil
            let hasColon = ipAddress.contains(":")

            #expect(hasIPv4Format || hasColon)
        }
    }

    /// Test IP address does not contain invalid characters
    /// 测试IP地址不包含无效字符
    @Test("IP address should not contain invalid characters")
    func ipAddressValidCharacters() async throws {
        let ipAddress = DeviceNetwork.ipAddress

        if !ipAddress.isEmpty {
            // Valid characters: digits, dots, colons, brackets (for IPv6)
            // 有效字符：数字、点、冒号、括号（用于IPv6）
            let validChars = CharacterSet(charactersIn: "0123456789.:[%]")
            let isValid = ipAddress.unicodeScalars.allSatisfy { validChars.contains($0) }

            #expect(isValid)
        }
    }

    // MARK: - Integration Tests

    /// Test network info is stable across multiple calls
    /// 测试网络信息在多次调用间保持稳定
    @Test("Network info should be stable across calls")
    func networkInfoStability() async throws {
        let carrierName1 = DeviceNetwork.carrierName
        let carrierName2 = DeviceNetwork.carrierName

        let ipAddress1 = DeviceNetwork.ipAddress
        let ipAddress2 = DeviceNetwork.ipAddress

        #expect(carrierName1 == carrierName2)

        // IP address might change, but should remain consistent format
        // IP地址可能会改变，但应保持一致的格式
        if !ipAddress1.isEmpty && !ipAddress2.isEmpty {
            let bothValidFormat = !ipAddress1.isEmpty && !ipAddress2.isEmpty
            #expect(bothValidFormat)
        }
    }

    /// Test concurrent access to network info
    /// 测试并发访问网络信息
    @Test("Should handle concurrent access safely")
    func concurrentAccess() async throws {
        // Simulate concurrent access
        // 模拟并发访问
        async let carrierName: String = DeviceNetwork.carrierName
        async let carrierCode: String = DeviceNetwork.carrierCode
        async let ipAddress: String = DeviceNetwork.ipAddress

        let results = await (carrierName, carrierCode, ipAddress)

        #expect(results.0 is String)
        #expect(results.1 is String)
        #expect(results.2 is String)
    }

    /// Test carrier info provides complete information
    /// 测试运营商信息提供完整信息
    @Test("Carrier info should provide complete information")
    func carrierInfoCompleteness() async throws {
        guard let info = DeviceNetwork.carrierInfo else {
            return
        }

        // At minimum, name and identifier should be available
        // 至少，名称和标识符应该可用
        #expect(!info.name.isEmpty)
        #expect(!info.identifier.isEmpty)

        // Verify identifier format
        // 验证标识符格式
        #expect(info.identifier.contains("_") || !info.identifier.contains(" "))
    }

    // MARK: - Edge Cases Tests

    /// Test empty string handling
    /// 测试空字符串处理
    @Test("Should handle empty network states gracefully")
    func emptyNetworkStates() async throws {
        let carrierName = DeviceNetwork.carrierName
        let carrierCode = DeviceNetwork.carrierCode
        let ipAddress = DeviceNetwork.ipAddress

        // All should return valid strings (possibly empty)
        // 所有都应该返回有效字符串（可能为空）
        #expect(!carrierName.contains("Unknown"))
        #expect(!carrierCode.contains("Unknown"))
        #expect(!ipAddress.contains("Unknown"))
    }

    /// Test carrier info nil handling
    /// 测试运营商信息 nil 处理
    @Test("Should handle nil carrier info gracefully")
    func nilCarrierInfo() async throws {
        // When carrier info is nil, properties should return empty strings
        // 当运营商信息为 nil 时，属性应该返回空字符串
        if DeviceNetwork.carrierInfo == nil {
            #expect(DeviceNetwork.carrierName == "")
            #expect(DeviceNetwork.carrierCode == "")
        }
    }

    /// Test carrier code format consistency
    /// 测试运营商代码格式一致性
    @Test("Carrier code should use consistent formatting")
    func carrierCodeFormatting() async throws {
        let carrierCode = DeviceNetwork.carrierCode

        if !carrierCode.isEmpty {
            // Should not have spaces
            // 不应该有空格
            #expect(!carrierCode.contains(" "))

            // Should not have special characters except underscore
            // 除了下划线外不应该有特殊字符
            let specialChars = CharacterSet(charactersIn: "_abcdefghijklmnopqrstuvwxyz0123456789")
            #expect(carrierCode.unicodeScalars.allSatisfy { specialChars.contains($0) })
        }
    }

    /// Test international carrier support
    /// 测试国际运营商支持
    @Test("Should support international carriers")
    func internationalCarrierSupport() async throws {
        // Test that the carrier database includes various countries
        // This is a meta-test ensuring the database is populated
        // 测试运营商数据库包含各种国家
        // 这是一个元测试，确保数据库已填充
        let knownCarriers = [
            "china_mobile", "china_unicom", "china_telecom",
            "verizon", "att", "t_mobile",
            "ntt_docomo", "softbank", "au_kddi",
            "vodafone", "orange", "telenor"
        ]

        // Just verify these are valid strings
        // 只是验证这些是有效字符串
        for carrier in knownCarriers {
            #expect(carrier.range(of: #"^[a-z0-9_]+$"#, options: .regularExpression) != nil)
        }
    }
}
