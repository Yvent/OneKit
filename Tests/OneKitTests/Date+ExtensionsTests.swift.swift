//
//  Date+ExtensionsTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/23.
//

import Testing
@testable import OneKitCore
import Foundation

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    // MARK: - Static Properties Tests

    /// Test GMT string format validation
    /// 测试 GMT 字符串格式验证
    @Test("GMT string format should be valid")
    func gmtStringFormat() async throws {
        let gmt = Date.gmtString
        // Verify it contains "GMT" suffix / 验证包含 "GMT" 后缀
        #expect(gmt.contains("GMT"))
    }

    /// Test ISO8601 string format validation
    /// 测试 ISO8601 字符串格式验证
    @Test("ISO8601 string format should be valid")
    func iso8601StringFormat() async throws {
        let iso = Date.iso8601String
        // Verify format: "2025-12-23T12:34:56"
        // 验证格式: "2025-12-23T12:34:56"
        // Use NSRegularExpression for iOS 15 compatibility
        // 使用 NSRegularExpression 兼容 iOS 15
        let pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(iso.startIndex..., in: iso)
        #expect(regex.firstMatch(in: iso, range: range) != nil)
    }

    // MARK: - Instance Properties Tests

    /// Test instance date to ISO8601 conversion
    /// 测试实例日期转换为 ISO8601 格式
    @Test("Instance should convert to ISO8601 correctly")
    func instanceISO8601Conversion() async throws {
        // Use timestamp for UTC time 2024-12-23 12:00:00
        // 使用 UTC 时间 2024-12-23 12:00:00 的时间戳
        let date = Date(timeIntervalSince1970: 1734952800)
        let iso = date.iso8601String
        // Verify format is correct (contains date, time, and T separator)
        // 验证格式正确（包含日期、时间和T分隔符）
        #expect(iso.contains("T"))
        #expect(iso.hasPrefix("2024-12-23"))
    }

    // MARK: - Date Parsing Tests

    /// Test ISO8601 string parsing
    /// 测试 ISO8601 字符串解析
    @Test("Should parse ISO8601 string correctly")
    func iso8601Parsing() async throws {
        let dateString = "2025-12-23T12:34:56.123Z"
        let date = Date.from(iso8601String: dateString)
        #expect(date != nil)
    }

    /// Test custom format string parsing
    /// 测试自定义格式字符串解析
    @Test("Should parse custom format correctly")
    func customFormatParsing() async throws {
        let date = Date.from(string: "2025/12/23", format: "yyyy/MM/dd")
        #expect(date != nil)
    }

    // MARK: - Edge Cases Tests

    /// Test leap year date handling
    /// 测试闰年日期处理
    @Test("Should handle leap year date")
    func leapYearDate() async throws {
        let date = Date.from(string: "2024-02-29", format: "yyyy-MM-dd")
        #expect(date != nil)
    }

    /// Test invalid date handling
    /// 测试无效日期处理
    @Test("Should handle invalid date")
    func invalidDate() async throws {
        let date = Date.from(string: "2024-02-30", format: "yyyy-MM-dd") // Feb 30th doesn't exist / 2月没有30号
        #expect(date == nil)
    }

    // MARK: - Localization Tests

    /// Test localized string is not empty
    /// 测试本地化字符串不为空
    @Test("Localized string should not be empty")
    func localizedStringNotEmpty() async throws {
        let date = Date()
        let localized = date.localizedString
        #expect(!localized.isEmpty)
    }
}
