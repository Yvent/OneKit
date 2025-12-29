//
//  UserDefault.swift
//  OneKitCore
//
//  Created by OneKit
//

import Foundation

/// A property wrapper that provides type-safe access to UserDefaults
///
/// 提供类型安全的 UserDefaults 访问的属性包装器
///
/// **Basic Usage:**
/// ```swift
/// @UserDefault("username", default: "")
/// static var username: String
///
/// @UserDefault("hasOnboarded", default: false)
/// static var hasOnboarded: Bool
/// ```
///
/// **Codable Support:**
/// ```swift
/// struct UserProfile: Codable {
///     let name: String
///     let age: Int
/// }
///
/// @UserDefault("profile", default: nil)
/// static var profile: UserProfile?
/// ```
///
/// **Usage:**
/// ```swift
/// // Set value
/// username = "John"
///
/// // Get value
/// let name = username
///
/// // Reset to default
/// $username.reset()
/// ```
@propertyWrapper
public struct UserDefault<T: UserDefaultsSerializable> {

    /// The key in UserDefaults
    ///
    /// UserDefaults 中的键
    let key: String

    /// The default value to use if key doesn't exist
    ///
    /// 如果键不存在时使用的默认值
    let defaultValue: T

    /// The UserDefaults suite to use
    ///
    /// 使用的 UserDefaults 实例
    let suite: UserDefaults

    /// Initialize a UserDefault property wrapper
    ///
    /// - Parameters:
    ///   - key: The key in UserDefaults
    ///   - default: The default value
    ///   - suite: The UserDefaults instance (default: .standard)
    public init(
        _ key: String,
        default defaultValue: T,
        suite: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.suite = suite
    }

    /// The wrapped value
    ///
    /// 包装的值
    public var wrappedValue: T {
        get {
            guard let value = suite.object(forKey: key) else {
                return defaultValue
            }
            return T.fromStored(value) ?? defaultValue
        }
        set {
            T.toStored(newValue).flatMap { suite.set($0, forKey: key) } ?? suite.removeObject(forKey: key)
        }
    }

    /// The projected value provides additional methods
    ///
    /// 投影值提供额外的方法
    public var projectedValue: UserDefaultWrapper<T> {
        UserDefaultWrapper(wrapper: self)
    }
}

/// A wrapper that provides additional methods for UserDefault
///
/// 为 UserDefault 提供额外方法的包装器
public struct UserDefaultWrapper<T: UserDefaultsSerializable> {
    let wrapper: UserDefault<T>

    /// Reset the value to default
    ///
    /// 重置为默认值
    public func reset() {
        wrapper.suite.removeObject(forKey: wrapper.key)
    }

    /// Check if the key exists in UserDefaults
    ///
    /// 检查键是否存在于 UserDefaults
    public func exists() -> Bool {
        wrapper.suite.object(forKey: wrapper.key) != nil
    }
}

// MARK: - UserDefaultsSerializable Protocol

/// Protocol for types that can be stored in UserDefaults
///
/// 可以存储在 UserDefaults 中的类型的协议
public protocol UserDefaultsSerializable {
    /// Convert from stored value to Swift type
    ///
    /// 从存储的值转换为 Swift 类型
    static func fromStored(_ value: Any) -> Self?

    /// Convert from Swift type to stored value
    ///
    /// 从 Swift 类型转换为存储的值
    static func toStored(_ value: Self) -> Any?
}

// MARK: - Basic Type Conformance

extension Bool: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Bool? {
        (value as? NSNumber)?.boolValue
    }

    public static func toStored(_ value: Bool) -> Any? {
        NSNumber(value: value)
    }
}

extension Int: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Int? {
        (value as? NSNumber)?.intValue
    }

    public static func toStored(_ value: Int) -> Any? {
        NSNumber(value: value)
    }
}

extension Double: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Double? {
        (value as? NSNumber)?.doubleValue
    }

    public static func toStored(_ value: Double) -> Any? {
        NSNumber(value: value)
    }
}

extension Float: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Float? {
        (value as? NSNumber)?.floatValue
    }

    public static func toStored(_ value: Float) -> Any? {
        NSNumber(value: value)
    }
}

extension String: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> String? {
        value as? String
    }

    public static func toStored(_ value: String) -> Any? {
        value
    }
}

extension URL: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> URL? {
        (value as? String).flatMap { URL(string: $0) }
    }

    public static func toStored(_ value: URL) -> Any? {
        value.absoluteString
    }
}

extension Data: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Data? {
        value as? Data
    }

    public static func toStored(_ value: Data) -> Any? {
        value
    }
}

// MARK: - Optional Support

extension Optional: UserDefaultsSerializable where Wrapped: UserDefaultsSerializable {
    public static func fromStored(_ value: Any) -> Self? {
        guard let stored = Wrapped.fromStored(value) else {
            return .none
        }
        return .some(stored)
    }

    public static func toStored(_ value: Self) -> Any? {
        switch value {
        case .none:
            return nil
        case .some(let wrapped):
            return Wrapped.toStored(wrapped)
        }
    }
}

// MARK: - RawRepresentable Support

extension UserDefaultsSerializable where Self: RawRepresentable {
    public static func fromStored(_ value: Any) -> Self? {
        (value as? Self.RawValue).flatMap { Self(rawValue: $0) }
    }

    public static func toStored(_ value: Self) -> Any? {
        value.rawValue
    }
}

// MARK: - Codable Support

/// Helper extension for Codable types to conform to UserDefaultsSerializable
///
/// 为 Codable 类型提供 UserDefaultsSerializable 一致性的辅助扩展
public struct CodableStorage<T: Codable>: UserDefaultsSerializable {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }

    public static func fromStored(_ value: Any) -> CodableStorage<T>? {
        guard let data = value as? Data,
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return CodableStorage(decoded)
    }

    public static func toStored(_ value: CodableStorage<T>) -> Any? {
        try? JSONEncoder().encode(value.value)
    }
}

// Example of how to use CodableStorage with @UserDefault:
// @UserDefault("profile", default: nil)
// static var profile: CodableStorage<UserProfile>?

