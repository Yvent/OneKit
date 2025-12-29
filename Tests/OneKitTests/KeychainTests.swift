//
//  KeychainTests.swift
//  OneKitTests
//
//  Created by OneKit
//

import XCTest
@testable import OneKitCore

#if os(iOS) || os(macOS)
/// Keychain tests
///
/// Keychain 测试
final class KeychainTests: XCTestCase {

    // MARK: - Test Keys
    // MARK: - 测试键

    enum TestKeys {
        static let stringKey = "test_string"
        static let dataKey = "test_data"
        static let optionalStringKey = "test_optional_string"
        static let optionalDataKey = "test_optional_data"
        static let accessControlKey = "test_access_control"
        static let synchronizableKey = "test_synchronizable"
    }

    // MARK: - Setup & Teardown
    // MARK: - 设置与清理

    override func setUp() {
        super.setUp()
        // Clear all test keys before each test
        // 在每个测试前清除所有测试键
        clearAllTestKeys()
    }

    override func tearDown() {
        // Clean up after each test
        // 在每个测试后清理
        clearAllTestKeys()
        super.tearDown()
    }

    private func clearAllTestKeys() {
        // Clear all synchronizable items from default service
        // 清除默认服务的所有同步项目
        let keys = [
            TestKeys.stringKey,
            TestKeys.dataKey,
            TestKeys.optionalStringKey,
            TestKeys.optionalDataKey,
            TestKeys.accessControlKey,
            TestKeys.synchronizableKey
        ]

        // Delete both synchronizable and non-synchronizable versions
        // 删除同步和非同步版本
        keys.forEach { key in
            KeychainManager.delete(key: key, synchronizable: false)
            KeychainManager.delete(key: key, synchronizable: true)
        }

        // Also clear custom services used in tests
        // 同时清除测试中使用的自定义服务
        KeychainManager.clear(service: "com.onekit.tests")
        KeychainManager.clear(service: "com.onekit.test.clear")
    }

    // MARK: - String Storage Tests
    // MARK: - 字符串存储测试

    func testStringStorage() {
        // Given
        // Given - 给定
        @KeychainStored(TestKeys.stringKey)
        var testString: String

        // When - not set, should return default
        // When - 未设置时，应返回默认值
        XCTAssertEqual(testString, "")

        // When - set value
        // When - 设置值
        testString = "Hello, Keychain!"

        // Then - should retrieve stored value
        // Then - 应该检索存储的值
        XCTAssertEqual(testString, "Hello, Keychain!")

        // When - create new wrapper
        // When - 创建新的包装器
        @KeychainStored(TestKeys.stringKey)
        var newString: String

        // Then - should get previously stored value
        // Then - 应该获得先前存储的值
        XCTAssertEqual(newString, "Hello, Keychain!")
    }

    func testLongStringStorage() {
        // Given
        let longString = String(repeating: "A", count: 10000)

        @KeychainStored(TestKeys.stringKey)
        var testString: String

        // When
        testString = longString

        // Then
        XCTAssertEqual(testString, longString)
        XCTAssertEqual(testString.count, 10000)
    }

    func testStringWithSpecialCharacters() {
        // Given
        let specialString = "密码!@#$%^&*()_+-=[]{}|;':\",./<>?`~中文emoji😀"

        @KeychainStored(TestKeys.stringKey)
        var testString: String

        // When
        testString = specialString

        // Then
        XCTAssertEqual(testString, specialString)
    }

    // MARK: - Data Storage Tests
    // MARK: - 数据存储测试

    func testDataStorage() {
        // Given
        @KeychainStored(TestKeys.dataKey)
        var testData: Data

        // When - not set, should return default
        XCTAssertEqual(testData, Data())

        // When - set value
        let inputData = "Test data".data(using: .utf8)!
        testData = inputData

        // Then
        XCTAssertEqual(testData, inputData)
        XCTAssertEqual(testData, "Test data".data(using: .utf8))
    }

    func testLargeDataStorage() {
        // Given
        @KeychainStored(TestKeys.dataKey)
        var testData: Data

        // When
        let largeData = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB
        testData = largeData

        // Then
        XCTAssertEqual(testData, largeData)
        XCTAssertEqual(testData.count, 1024 * 1024)
    }

    // MARK: - Optional Types Tests
    // MARK: - 可选类型测试

    func testOptionalStringStorage() {
        // Given
        @KeychainStored(TestKeys.optionalStringKey)
        var optionalString: String?

        // When - not set
        // When - 未设置
        XCTAssertNil(optionalString)

        // When - set value
        // When - 设置值
        optionalString = "Optional Value"

        // Then
        // Then - 然后
        XCTAssertEqual(optionalString, "Optional Value")

        // When - set to nil
        // When - 设置为 nil
        optionalString = nil

        // Then - should be nil
        // Then - 应该为 nil
        XCTAssertNil(optionalString)

        // When - check exists
        // When - 检查是否存在
        @KeychainStored(TestKeys.optionalStringKey)
        var checkString: String?

        // Then - should still be nil
        // Then - 应该仍然为 nil
        XCTAssertNil(checkString)
    }

    func testOptionalDataStorage() {
        // Given
        @KeychainStored(TestKeys.optionalDataKey)
        var optionalData: Data?

        // When
        XCTAssertNil(optionalData)

        optionalData = Data([0x01, 0x02, 0x03])
        XCTAssertEqual(optionalData, Data([0x01, 0x02, 0x03]))

        optionalData = nil
        XCTAssertNil(optionalData)
    }

    // MARK: - Projected Value Tests
    // MARK: - 投影值测试

    func testProjectedValueRemove() {
        // Given
        @KeychainStored(TestKeys.stringKey)
        var testString: String

        testString = "Temporary Value"
        XCTAssertEqual(testString, "Temporary Value")

        // When - remove
        // When - 移除
        KeychainManager.delete(key: TestKeys.stringKey)

        // Then - should return default value
        // Then - 应该返回默认值
        XCTAssertEqual(testString, "")
    }

    func testProjectedValueExists() {
        // Given
        @KeychainStored(TestKeys.stringKey)
        var testString: String

        // When - not set
        // When - 未设置
        XCTAssertFalse(KeychainManager.read(key: TestKeys.stringKey) != nil)

        // When - set value
        // When - 设置值
        testString = "Test Value"

        // Then - should exist
        // Then - 应该存在
        XCTAssertTrue(KeychainManager.read(key: TestKeys.stringKey) != nil)

        // When - remove
        // When - 移除
        KeychainManager.delete(key: TestKeys.stringKey)

        // Then - should not exist
        // Then - 应该不存在
        XCTAssertFalse(KeychainManager.read(key: TestKeys.stringKey) != nil)
    }

    // MARK: - Access Control Tests
    // MARK: - 访问控制测试

    func testAccessControlAfterFirstUnlock() {
        // Given
        @KeychainStored(TestKeys.accessControlKey, access: .afterFirstUnlock)
        var testString: String

        // When
        testString = "Access Test"

        // Then
        XCTAssertEqual(testString, "Access Test")
    }

    func testAccessControlWhenUnlocked() {
        // Given
        @KeychainStored(TestKeys.accessControlKey, access: .whenUnlocked)
        var testString: String

        // When
        testString = "Unlocked Test"

        // Then
        XCTAssertEqual(testString, "Unlocked Test")
    }

    // MARK: - Synchronizable Tests
    // MARK: - 同步测试

    func testSynchronizable() {
        // Given
        @KeychainStored(TestKeys.synchronizableKey, synchronizable: true)
        var testString: String

        // When
        testString = "Sync Test"

        // Then
        XCTAssertEqual(testString, "Sync Test")

        // Create new wrapper to verify persistence
        @KeychainStored(TestKeys.synchronizableKey, synchronizable: true)
        var newString: String

        XCTAssertEqual(newString, "Sync Test")
    }

    // MARK: - Update Tests
    // MARK: - 更新测试

    func testUpdateExistingValue() {
        // Given
        @KeychainStored(TestKeys.stringKey)
        var testString: String

        testString = "First Value"
        XCTAssertEqual(testString, "First Value")

        // When - update
        // When - 更新
        testString = "Updated Value"

        // Then
        // Then - 然后
        XCTAssertEqual(testString, "Updated Value")

        // Verify with new wrapper
        // 使用新的包装器验证
        @KeychainStored(TestKeys.stringKey)
        var newString: String

        XCTAssertEqual(newString, "Updated Value")
    }

    func testMultipleUpdates() {
        // Given
        @KeychainStored(TestKeys.stringKey)
        var testString: String

        // When - multiple updates
        // When - 多次更新
        for i in 1...10 {
            testString = "Value \(i)"
            XCTAssertEqual(testString, "Value \(i)")
        }

        // Then - final value should be last update
        // Then - 最终值应该是最后一次更新
        XCTAssertEqual(testString, "Value 10")
    }

    // MARK: - Custom Service Tests
    // MARK: - 自定义服务测试

    func testCustomService() {
        // Given
        let customService = "com.onekit.tests"

        @KeychainStored("custom_test", service: customService)
        var testString: String

        // When
        // When - 当
        testString = "Custom Service Test"

        // Then
        // Then - 然后
        XCTAssertEqual(testString, "Custom Service Test")

        // Verify it's stored in custom service
        // 验证它存储在自定义服务中
        let data = KeychainManager.read(key: "custom_test", service: customService)
        XCTAssertNotNil(data)

        let defaultData = KeychainManager.read(key: "custom_test", service: KeychainManager.defaultService)
        XCTAssertNil(defaultData)
    }

    // MARK: - Clear Tests
    // MARK: - 清除测试

    func testClearService() {
        // Given
        let service = "com.onekit.test.clear"

        @KeychainStored("key1", service: service)
        var value1: String
        value1 = "Value 1"

        @KeychainStored("key2", service: service)
        var value2: String
        value2 = "Value 2"

        // When
        // When - 当
        let cleared = KeychainManager.clear(service: service)

        // Then
        // Then - 然后
        XCTAssertTrue(cleared)

        @KeychainStored("key1", service: service)
        var read1: String
        @KeychainStored("key2", service: service)
        var read2: String

        XCTAssertEqual(read1, "")
        XCTAssertEqual(read2, "")
    }

    // MARK: - Performance Tests
    // MARK: - 性能测试

    func testPerformanceOfStringRead() {
        @KeychainStored("perf_test")
        var testString: String

        testString = "Performance test value"

        measure {
            for _ in 0..<100 {
                _ = testString
            }
        }
    }

    func testPerformanceOfStringWrite() {
        measure {
            for i in 0..<100 {
                @KeychainStored("perf_write_\(i)")
                var testString: String
                testString = "Value \(i)"
            }
        }
    }
}
#endif
