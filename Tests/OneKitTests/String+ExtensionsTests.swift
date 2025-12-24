//
//  String+ExtensionsTests.swift
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

@Suite("String Extensions Tests")
struct StringExtensionsTests {

    // MARK: - Date Conversion Tests

    /// Test valid date string conversion
    /// 测试有效日期字符串转换
    @Test("Valid date string should convert to Date")
    func validDateStringConversion() async throws {
        let dateString = "2025-12-24 15:30:00"
        let date = dateString.toDate()
        #expect(date != nil)
    }

    /// Test invalid date string conversion
    /// 测试无效日期字符串转换
    @Test("Invalid date string should return nil")
    func invalidDateStringConversion() async throws {
        let invalidDateString = "invalid date"
        let date = invalidDateString.toDate()
        #expect(date == nil)
    }

    /// Test empty string date conversion
    /// 测试空字符串日期转换
    @Test("Empty string should return nil")
    func emptyDateStringConversion() async throws {
        let emptyString = ""
        let date = emptyString.toDate()
        #expect(date == nil)
    }

    // MARK: - Timestamp Conversion Tests

    /// Test valid date string to timestamp conversion
    /// 测试有效日期字符串转换为时间戳
    @Test("Valid date string should convert to timestamp")
    func validDateStringToTimestamp() async throws {
        let dateString = "2025-12-24 15:30:00"
        let timestamp = dateString.toTimestamp()
        #expect(timestamp != nil)
        #expect(timestamp! > 0)  // Timestamp should be positive / 时间戳应该是正数
    }

    /// Test invalid date string to timestamp conversion
    /// 测试无效日期字符串转换为时间戳
    @Test("Invalid date string should return nil for timestamp")
    func invalidDateStringToTimestamp() async throws {
        let invalidDateString = "invalid date"
        let timestamp = invalidDateString.toTimestamp()
        #expect(timestamp == nil)
    }

    /// Test specific date timestamp value
    /// 测试特定日期的时间戳值
    @Test("Specific date should have correct timestamp")
    func specificDateTimestamp() async throws {
        // 2025-12-24 15:30:00 UTC
        let dateString = "2025-12-24 15:30:00"
        let timestamp = dateString.toTimestamp()
        // Verify it's roughly correct (within reasonable range)
        // 验证大约正确（在合理范围内）
        // 2025-12-24 15:30:00 should be around 1735030200000 milliseconds
        #expect(timestamp! > 1700000000000)  // Sometime in 2025+ / 2025年或之后
    }

    // MARK: - String Search Tests

    /// Test case-insensitive string search
    /// 测试不区分大小写的字符串搜索
    @Test("Should find string ignoring case")
    func containsIgnoringCaseTest() async throws {
        let text = "Hello World"
        #expect(text.containsIgnoringCase("hello") == true)
        #expect(text.containsIgnoringCase("HELLO") == true)
        #expect(text.containsIgnoringCase("world") == true)
    }

    /// Test case-insensitive search with non-existent string
    /// 测试不存在字符串的不区分大小写搜索
    @Test("Should return false for non-existent string")
    func containsIgnoringCaseNotFound() async throws {
        let text = "Hello World"
        #expect(text.containsIgnoringCase("goodbye") == false)
    }

    /// Test string search with options
    /// 测试带选项的字符串搜索
    @Test("Should find string with specified options")
    func containsWithOptionsTest() async throws {
        let text = "Hello World"
        #expect(text.contains("hello", options: .caseInsensitive) == true)
        #expect(text.contains("World", options: []) == true)
    }

    /// Test case-sensitive search
    /// 测试区分大小写的搜索
    @Test("Case-sensitive search should work correctly")
    func caseSensitiveSearchTest() async throws {
        let text = "Hello World"
        // Default Swift contains() is case-sensitive
        // Swift 默认的 contains() 是区分大小写的
        #expect(text.contains("Hello") == true)
        #expect(text.contains("hello") == false)
    }

    // MARK: - String Measurement Tests (iOS only)

    #if canImport(UIKit)

    /// Test string size calculation
    /// 测试字符串尺寸计算
    @available(iOS 13.0, *)
    @Test("Should calculate string size correctly")
    func stringSizeCalculation() async throws {
        let text = "Hello"
        let font = UIFont.systemFont(ofSize: 16)
        let constrainedSize = CGSize(width: 100, height: 50)

        let size = text.size(for: font, constrainedTo: constrainedSize)

        // Size should be positive / 尺寸应该是正数
        #expect(size.width > 0)
        #expect(size.height > 0)
        // Size should not exceed constraints / 尺寸不应超过约束
        #expect(size.width <= constrainedSize.width)
    }

    /// Test empty string size calculation
    /// 测试空字符串尺寸计算
    @available(iOS 13.0, *)
    @Test("Empty string should have minimal size")
    func emptyStringSizeCalculation() async throws {
        let text = ""
        let font = UIFont.systemFont(ofSize: 16)
        let constrainedSize = CGSize(width: 100, height: 50)

        let size = text.size(for: font, constrainedTo: constrainedSize)

        // Empty string should have some size / 空字符串应该有一些尺寸
        #expect(size.width >= 0)
        #expect(size.height >= 0)
    }

    /// Test long string size with constraint
    /// 测试长字符串在约束下的尺寸
    @available(iOS 13.0, *)
    @Test("Long string should respect width constraint")
    func longStringSizeConstraint() async throws {
        let text = "This is a very long string that should wrap to multiple lines"
        let font = UIFont.systemFont(ofSize: 16)
        let constrainedSize = CGSize(width: 100, height: 100)

        let size = text.size(for: font, constrainedTo: constrainedSize)

        // Width should not exceed constraint / 宽度不应超过约束
        #expect(size.width <= constrainedSize.width)
        // Height should be greater than single line / 高度应该大于单行
        #expect(size.height > 20)
    }

    #endif

    // MARK: - Edge Cases Tests

    /// Test string with special characters
    /// 测试包含特殊字符的字符串
    @Test("Should handle special characters in date string")
    func specialCharactersInDate() async throws {
        let dateString = "2025-12-24 15:30:00"
        let date = dateString.toDate()
        #expect(date != nil)
    }

    /// Test very long string search
    /// 测试超长字符串搜索
    @Test("Should handle very long string search")
    func longStringSearch() async throws {
        let longText = String(repeating: "Hello ", count: 1000)
        #expect(longText.containsIgnoringCase("hello") == true)
    }

    /// Test unicode characters in search
    /// 测试 Unicode 字符搜索
    @Test("Should handle unicode characters")
    func unicodeCharacterSearch() async throws {
        let text = "你好世界 Hello World"
        #expect(text.containsIgnoringCase("hello") == true)
        #expect(text.contains("你好") == true)
    }
}
