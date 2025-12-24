//
//  String+Extensions.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension String {

    // MARK: - Date Conversion

    /// Convert string to Date using "yyyy-MM-dd HH:mm:ss" format
    /// 使用 "yyyy-MM-dd HH:mm:ss" 格式将字符串转换为日期
    ///
    /// Example:
    /// ```swift
    /// "2025-12-24 15:30:00".toDate()
    /// ```
    /// - Returns: Date or nil if parsing fails
    public func toDate() -> Date? {
        return DateFormatter.dateFormatter.date(from: self)
    }

    /// Convert string to timestamp in milliseconds (since 1970)
    /// 将字符串转换为时间戳（毫秒，从1970年起）
    ///
    /// Example:
    /// ```swift
    /// "2025-12-24 15:30:00".toTimestamp() // 1735030200000
    /// ```
    /// - Returns: Timestamp in milliseconds or nil
    public func toTimestamp() -> Int? {
        guard let date = toDate() else { return nil }
        return Int(date.timeIntervalSince1970 * 1000)
    }

    // MARK: - String Measurement (iOS only)

    #if canImport(UIKit)

    /// Calculate string bounding size for given font and constraints
    /// 计算字符串在指定字体和约束下的尺寸
    ///
    /// Example:
    /// ```swift
    /// "Hello".size(for: .systemFont(ofSize: 16), constrainedTo: CGSize(width: 100, height: 50))
    /// ```
    /// - Parameters:
    ///   - font: The font to use for measurement
    ///   - constrainedSize: Maximum size for the text
    /// - Returns: The calculated size
    @available(iOS 13.0, *)
    public func size(for font: UIFont, constrainedTo constrainedSize: CGSize) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect = self.boundingRect(
            with: constrainedSize,
            options: options,
            attributes: attributes,
            context: nil
        )
        return rect.size
    }

    #endif

    // MARK: - String Search

    /// Check if string contains another string (case-insensitive)
    /// 检查字符串是否包含另一个字符串（不区分大小写）
    ///
    /// Example:
    /// ```swift
    /// "Hello World".containsIgnoringCase("hello") // true
    /// ```
    /// - Parameter string: String to search for
    /// - Returns: True if found, false otherwise
    public func containsIgnoringCase(_ string: String) -> Bool {
        return self.range(of: string, options: .caseInsensitive) != nil
    }

    /// Check if string contains another string with options
    /// 检查字符串是否包含另一个字符串（可指定选项）
    ///
    /// Example:
    /// ```swift
    /// "Hello World".contains("Hello", options: .caseInsensitive)
    /// ```
    /// - Parameters:
    ///   - string: String to search for
    ///   - options: String comparison options
    /// - Returns: True if found, false otherwise
    public func contains(_ string: String, options: String.CompareOptions) -> Bool {
        return self.range(of: string, options: options) != nil
    }
}

// MARK: - DateFormatter Cache

private extension DateFormatter {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
