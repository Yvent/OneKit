//
//  UserDefaultTests.swift
//  OneKitTests
//
//  Created by OneKit
//

import XCTest
@testable import OneKitCore

final class UserDefaultTests: XCTestCase {

    // MARK: - Test Settings

    enum TestKeys {
        static let stringKey = "test_string"
        static let intKey = "test_int"
        static let doubleKey = "test_double"
        static let floatKey = "test_float"
        static let boolKey = "test_bool"
        static let urlKey = "test_url"
        static let dataKey = "test_data"
        static let optionalStringKey = "test_optional_string"
        static let optionalIntKey = "test_optional_int"
        static let codableKey = "test_codable"
        static let rawRepresentableKey = "test_raw_representable"
    }

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Clear all test keys before each test
        clearAllTestKeys()
    }

    override func tearDown() {
        // Clean up after each test
        clearAllTestKeys()
        super.tearDown()
    }

    private func clearAllTestKeys() {
        let keys = [
            TestKeys.stringKey,
            TestKeys.intKey,
            TestKeys.doubleKey,
            TestKeys.floatKey,
            TestKeys.boolKey,
            TestKeys.urlKey,
            TestKeys.dataKey,
            TestKeys.optionalStringKey,
            TestKeys.optionalIntKey,
            TestKeys.codableKey,
            TestKeys.rawRepresentableKey
        ]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    // MARK: - String Tests

    func testStringStorage() {
        // Given
        @UserDefault(TestKeys.stringKey, default: "default")
        var testString: String

        // When - not set, should return default
        XCTAssertEqual(testString, "default")

        // When - set value
        testString = "Hello, OneKit!"

        // Then - should retrieve stored value
        XCTAssertEqual(testString, "Hello, OneKit!")

        // When - create new wrapper
        @UserDefault(TestKeys.stringKey, default: "default")
        var newString: String

        // Then - should get previously stored value
        XCTAssertEqual(newString, "Hello, OneKit!")
    }

    // MARK: - Int Tests

    func testIntStorage() {
        // Given
        @UserDefault(TestKeys.intKey, default: 0)
        var testInt: Int

        // When - not set, should return default
        XCTAssertEqual(testInt, 0)

        // When - set value
        testInt = 42

        // Then - should retrieve stored value
        XCTAssertEqual(testInt, 42)

        // When - create new wrapper
        @UserDefault(TestKeys.intKey, default: 0)
        var newInt: Int

        // Then - should get previously stored value
        XCTAssertEqual(newInt, 42)
    }

    // MARK: - Double Tests

    func testDoubleStorage() {
        // Given
        @UserDefault(TestKeys.doubleKey, default: 0.0)
        var testDouble: Double

        // When
        testDouble = 3.14159

        // Then
        XCTAssertEqual(testDouble, 3.14159, accuracy: 0.00001)
    }

    // MARK: - Float Tests

    func testFloatStorage() {
        // Given
        @UserDefault(TestKeys.floatKey, default: 0.0)
        var testFloat: Float

        // When
        testFloat = 2.71828

        // Then
        XCTAssertEqual(testFloat, 2.71828, accuracy: 0.00001)
    }

    // MARK: - Bool Tests

    func testBoolStorage() {
        // Given
        @UserDefault(TestKeys.boolKey, default: false)
        var testBool: Bool

        // When - not set, should return default
        XCTAssertEqual(testBool, false)

        // When - set to true
        testBool = true
        XCTAssertEqual(testBool, true)

        // When - set to false
        testBool = false
        XCTAssertEqual(testBool, false)

        // When - set to true again
        testBool = true

        // When - create new wrapper
        @UserDefault(TestKeys.boolKey, default: false)
        var newBool: Bool

        // Then - should get previously stored value
        XCTAssertEqual(newBool, true)
    }

    // MARK: - URL Tests

    func testURLStorage() {
        // Given
        @UserDefault(TestKeys.urlKey, default: nil)
        var testURL: URL?

        // When - not set, should be nil
        XCTAssertNil(testURL)

        // When - set URL
        let urlString = "https://github.com/Yvent/OneKit"
        testURL = URL(string: urlString)

        // Then - should retrieve stored URL
        XCTAssertNotNil(testURL)
        XCTAssertEqual(testURL?.absoluteString, urlString)
    }

    // MARK: - Data Tests

    func testDataStorage() {
        // Given
        @UserDefault(TestKeys.dataKey, default: Data())
        var testData: Data

        // When
        let inputString = "Test data"
        testData = inputString.data(using: .utf8)!

        // Then
        XCTAssertFalse(testData.isEmpty)
        XCTAssertEqual(testData, inputString.data(using: .utf8))
    }

    // MARK: - Optional Types Tests

    func testOptionalStringStorage() {
        // Given
        @UserDefault(TestKeys.optionalStringKey, default: nil)
        var optionalString: String?

        // When - not set
        XCTAssertNil(optionalString)

        // When - set value
        optionalString = "Optional Value"

        // Then
        XCTAssertEqual(optionalString, "Optional Value")

        // When - set to nil
        optionalString = nil

        // Then - should be nil
        XCTAssertNil(optionalString)
    }

    func testOptionalIntStorage() {
        // Given
        @UserDefault(TestKeys.optionalIntKey, default: nil)
        var optionalInt: Int?

        // When
        XCTAssertNil(optionalInt)

        optionalInt = 100
        XCTAssertEqual(optionalInt, 100)

        optionalInt = nil
        XCTAssertNil(optionalInt)
    }

    // MARK: - Codable Tests

    func testCodableStorage() {
        // Given
        struct TestProfile: Codable {
            let name: String
            let age: Int
            let email: String
        }

        @UserDefault(TestKeys.codableKey, default: nil)
        var profile: CodableStorage<TestProfile>?

        // When - not set
        XCTAssertNil(profile)

        // When - set profile
        let testProfile = TestProfile(name: "John Doe", age: 30, email: "john@example.com")
        profile = CodableStorage(testProfile)

        // Then - should retrieve stored profile
        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.value.name, "John Doe")
        XCTAssertEqual(profile?.value.age, 30)
        XCTAssertEqual(profile?.value.email, "john@example.com")

        // When - create new wrapper
        @UserDefault(TestKeys.codableKey, default: nil)
        var newProfile: CodableStorage<TestProfile>?

        // Then - should get previously stored profile
        XCTAssertNotNil(newProfile)
        XCTAssertEqual(newProfile?.value.name, "John Doe")
        XCTAssertEqual(newProfile?.value.age, 30)
        XCTAssertEqual(newProfile?.value.email, "john@example.com")
    }

    // MARK: - RawRepresentable Tests

    func testRawRepresentableStorage() {
        // Given
        enum TestSettings: String, UserDefaultsSerializable {
            case light
            case dark
            case auto
        }

        @UserDefault(TestKeys.rawRepresentableKey, default: .auto)
        var settings: TestSettings

        // When - not set, should return default
        XCTAssertEqual(settings, .auto)

        // When - set value
        settings = .dark
        XCTAssertEqual(settings, .dark)

        // When - create new wrapper
        @UserDefault(TestKeys.rawRepresentableKey, default: .auto)
        var newSettings: TestSettings

        // Then - should get previously stored value
        XCTAssertEqual(newSettings, .dark)
    }

    // MARK: - Projected Value Tests

    func testProjectedValueReset() {
        // Given
        @UserDefault(TestKeys.stringKey, default: "default")
        var testString: String

        testString = "Temporary Value"
        XCTAssertEqual(testString, "Temporary Value")

        // When - reset to default
        $testString.reset()

        // Then - should return default value
        XCTAssertEqual(testString, "default")
    }

    func testProjectedValueExists() {
        // Given
        @UserDefault(TestKeys.intKey, default: 0)
        var testInt: Int

        // When - not set
        XCTAssertFalse($testInt.exists())

        // When - set value
        testInt = 123

        // Then - should exist
        XCTAssertTrue($testInt.exists())

        // When - reset
        $testInt.reset()

        // Then - should not exist
        XCTAssertFalse($testInt.exists())
    }

    // MARK: - Custom Suite Tests

    func testCustomSuite() {
        // Given
        let customSuite = UserDefaults(suiteName: "com.onekit.tests")!
        @UserDefault("test_custom", default: "custom_default", suite: customSuite)
        var testValue: String

        // When
        testValue = "custom_value"

        // Then
        XCTAssertEqual(testValue, "custom_value")

        // Verify it's stored in custom suite, not standard
        XCTAssertNil(UserDefaults.standard.string(forKey: "test_custom"))
        XCTAssertEqual(customSuite.string(forKey: "test_custom"), "custom_value")
    }

    // MARK: - Performance Tests

    func testPerformanceOfStringRead() {
        @UserDefault("perf_test", default: "default")
        var testString: String

        testString = "Performance test value"

        measure {
            for _ in 0..<1000 {
                _ = testString
            }
        }
    }

    func testPerformanceOfStringWrite() {
        measure {
            for i in 0..<1000 {
                @UserDefault("perf_write_test", default: "default")
                var testString: String
                testString = "Value \(i)"
            }
        }
    }
}
