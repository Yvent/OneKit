//
//  Keychain.swift
//  OneKitCore
//
//  Created by OneKit
//

#if os(iOS) || os(macOS)
import Foundation
import Security

// MARK: - Keychain Value Protocol

/// Protocol for types that can be stored in Keychain
///
/// 可以存储在 Keychain 中的类型的协议
public protocol KeychainValue {
    /// Default value when key doesn't exist
    ///
    /// 键不存在时的默认值
    static var defaultValue: Self { get }

    /// Convert from Data to Swift type
    ///
    /// 从 Data 转换为 Swift 类型
    static func from(data: Data) -> Self?

    /// Convert from Swift type to Data
    ///
    /// 从 Swift 类型转换为 Data
    static func to(data: Self) -> Data?
}

// MARK: - Type Conformance

extension String: KeychainValue {
    public static var defaultValue: String { "" }

    public static func from(data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }

    public static func to(data: String) -> Data? {
        data.data(using: .utf8)
    }
}

extension Data: KeychainValue {
    public static var defaultValue: Data { Data() }

    public static func from(data: Data) -> Data? {
        data
    }

    public static func to(data: Data) -> Data? {
        data
    }
}

// MARK: - Optional Support

extension Optional: KeychainValue where Wrapped: KeychainValue {
    public static var defaultValue: Wrapped? { nil }

    public static func from(data: Data) -> Wrapped?? {
        Wrapped.from(data: data)
    }

    public static func to(data: Wrapped?) -> Data? {
        switch data {
        case .none:
            return nil
        case .some(let wrapped):
            return Wrapped.to(data: wrapped)
        }
    }
}

// MARK: - Keychain Access Control

/// Access control levels for Keychain items
///
/// Keychain 项目的访问控制级别
public enum KeychainAccess {
    /// Item can be accessed only after the device has been unlocked once
    ///
    /// 设备首次解锁后可访问
    case afterFirstUnlock

    /// Item can be accessed only while the device is unlocked
    ///
    /// 设备解锁时可访问
    case whenUnlocked

    /// Item can be accessed only after the device has been unlocked once (this session only)
    ///
    /// 仅当前会话首次解锁后可访问
    case afterFirstUnlockThisDeviceOnly

    /// Item can be accessed only while the device is unlocked (this device only)
    ///
    /// 仅当前设备解锁时可访问
    case whenUnlockedThisDeviceOnly

    /// Convert to CFString attribute
    ///
    /// 转换为 CFString 属性
    var cfAttribute: CFString {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}

// MARK: - Keychain Attribute Wrapper

/// A property wrapper that provides type-safe access to Keychain
///
/// 提供类型安全的 Keychain 访问的属性包装器
///
/// **Basic Usage:**
/// ```swift
/// enum SecureStorage {
///     @KeychainStored("accessToken")
///     static var accessToken: String
///
///     @KeychainStored("refreshToken", default: nil)
///     static var refreshToken: String?
///
///     @KeychainStored("privateKey")
///     static var privateKey: Data
/// }
///
/// // Save
/// SecureStorage.accessToken = "my_token"
///
/// // Read
/// let token = SecureStorage.accessToken
///
/// // Delete
/// $SecureStorage.accessToken.remove()
/// ```
///
/// **Security:**
/// - Data is stored encrypted in Keychain
/// - Automatically locked when device is locked
/// - Persists across app reinstalls (unless app is deleted)
/// - Secure storage for sensitive data (passwords, tokens, keys)
@propertyWrapper
public struct KeychainStored<T: KeychainValue> {

    /// The key in Keychain
    ///
    /// Keychain 中的键
    let key: String

    /// The access control for this item
    ///
    /// 访问控制
    let access: KeychainAccess

    /// The service identifier (default: bundle ID)
    ///
    /// 服务标识符（默认：bundle ID）
    let service: String

    /// The synchronizable flag
    ///
    /// 是否支持 iCloud 同步
    let synchronizable: Bool

    /// Initialize a Keychain property wrapper
    ///
    /// - Parameters:
    ///   - key: The key in Keychain / Keychain 中的键
    ///   - access: The access control / 访问控制
    ///   - service: The service identifier / 服务标识符
    ///   - synchronizable: Whether to sync with iCloud / 是否 iCloud 同步
    public init(
        _ key: String,
        access: KeychainAccess = .afterFirstUnlock,
        service: String = KeychainManager.defaultService,
        synchronizable: Bool = false
    ) {
        self.key = key
        self.access = access
        self.service = service
        self.synchronizable = synchronizable
    }

    /// The wrapped value
    ///
    /// 包装的值
    public var wrappedValue: T {
        get {
            guard let data = KeychainManager.read(key: key, service: service, synchronizable: synchronizable) else {
                return T.defaultValue
            }
            return T.from(data: data) ?? T.defaultValue
        }
        set {
            if let data = T.to(data: newValue) {
                KeychainManager.save(key: key, data: data, access: access, service: service, synchronizable: synchronizable)
            } else {
                KeychainManager.delete(key: key, service: service, synchronizable: synchronizable)
            }
        }
    }

    /// The projected value provides additional methods
    ///
    /// 投影值提供额外的方法
    public var projectedValue: KeychainWrapper<T> {
        KeychainWrapper(wrapper: self)
    }
}

// MARK: - Keychain Wrapper

/// Wrapper that provides additional methods for Keychain properties
///
/// 为 Keychain 属性提供额外方法的包装器
public struct KeychainWrapper<T: KeychainValue> {
    let wrapper: KeychainStored<T>

    /// Remove the item from Keychain
    ///
    /// 从 Keychain 移除项目
    public func remove() {
        KeychainManager.delete(key: wrapper.key, service: wrapper.service, synchronizable: wrapper.synchronizable)
    }

    /// Check if the item exists in Keychain
    ///
    /// 检查项目是否存在于 Keychain
    public func exists() -> Bool {
        KeychainManager.read(key: wrapper.key, service: wrapper.service, synchronizable: wrapper.synchronizable) != nil
    }
}

// MARK: - Keychain Errors

/// Keychain errors
///
/// Keychain 错误
public enum KeychainError: Error, LocalizedError {
    case readFailed(status: OSStatus)
    case saveFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case invalidData
    case conversionFailed

    public var errorDescription: String? {
        switch self {
        case .readFailed(let status):
            return "Failed to read from Keychain: \(status)"
        case .saveFailed(let status):
            return "Failed to save to Keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain: \(status)"
        case .invalidData:
            return "Invalid data format"
        case .conversionFailed:
            return "Failed to convert data"
        }
    }
}

// MARK: - Keychain Manager

/// Keychain operations
///
/// Keychain 操作
public enum KeychainManager {

    /// Default service identifier (bundle ID)
    ///
    /// 默认服务标识符（bundle ID）
    public static var defaultService: String {
        Bundle.main.bundleIdentifier ?? "com.onekit.default"
    }

    /// Read data from Keychain
    ///
    /// 从 Keychain 读取数据
    ///
    /// - Parameters:
    ///   - key: The key to read / 要读取的键
    ///   - service: The service identifier / 服务标识符
    ///   - synchronizable: Whether to read synchronizable items / 是否读取同步项目
    /// - Returns: The data if found, nil otherwise / 找到的数据，否则为 nil
    public static func read(key: String, service: String = defaultService, synchronizable: Bool? = nil) -> Data? {
        var query = baseQuery(key: key, service: service)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        // If synchronizable is specified, add it to query
        if let sync = synchronizable {
            query[kSecAttrSynchronizable as String] = sync ? kCFBooleanTrue : kCFBooleanFalse
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data {
            return data
        }

        return nil
    }

    /// Save data to Keychain
    ///
    /// 保存数据到 Keychain
    ///
    /// - Parameters:
    ///   - key: The key to save / 要保存的键
    ///   - data: The data to save / 要保存的数据
    ///   - access: The access control / 访问控制
    ///   - service: The service identifier / 服务标识符
    ///   - synchronizable: Whether to sync with iCloud / 是否 iCloud 同步
    /// - Returns: Success or failure / 成功或失败
    @discardableResult
    public static func save(
        key: String,
        data: Data,
        access: KeychainAccess = .afterFirstUnlock,
        service: String = defaultService,
        synchronizable: Bool = false
    ) -> Bool {
        var query = baseQuery(key: key, service: service)

        // Attributes to update
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]

        // Try to update first (if item exists)
        var status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

        // If item doesn't exist, add it
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = access.cfAttribute
            query[kSecAttrSynchronizable as String] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
            status = SecItemAdd(query as CFDictionary, nil)
        }

        return status == errSecSuccess
    }

    /// Delete data from Keychain
    ///
    /// 从 Keychain 删除数据
    ///
    /// - Parameters:
    ///   - key: The key to delete / 要删除的键
    ///   - service: The service identifier / 服务标识符
    ///   - synchronizable: Whether to delete synchronizable items / 是否删除同步项目
    /// - Returns: Success or failure / 成功或失败
    @discardableResult
    public static func delete(key: String, service: String = defaultService, synchronizable: Bool? = nil) -> Bool {
        var query = baseQuery(key: key, service: service)

        // If synchronizable is specified, add it to query
        if let sync = synchronizable {
            query[kSecAttrSynchronizable as String] = sync ? kCFBooleanTrue : kCFBooleanFalse
        }

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    /// Clear all items from Keychain for the current service
    ///
    /// 清除当前服务的所有 Keychain 项目
    ///
    /// - Parameter service: The service identifier / 服务标识符
    /// - Returns: Success or failure / 成功或失败
    @discardableResult
    public static func clear(service: String = defaultService) -> Bool {
        // Delete non-synchronizable items
        let queryNonSync: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: kCFBooleanFalse
        ]

        var status = SecItemDelete(queryNonSync as CFDictionary)

        // Delete synchronizable items
        let querySync: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: kCFBooleanTrue
        ]

        let syncStatus = SecItemDelete(querySync as CFDictionary)

        // Return success if at least one delete succeeded or both were not found
        return status == errSecSuccess || syncStatus == errSecSuccess ||
               status == errSecItemNotFound || syncStatus == errSecItemNotFound
    }

    /// Base query for Keychain operations
    ///
    /// Keychain 操作的基础查询
    ///
    /// - Parameters:
    ///   - key: The key / 键
    ///   - service: The service identifier / 服务标识符
    /// - Returns: Query dictionary / 查询字典
    private static func baseQuery(key: String, service: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
    }
}

#endif
