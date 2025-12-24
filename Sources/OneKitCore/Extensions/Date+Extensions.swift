//
//  Date+Extensions.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/23.
//

import Foundation

extension Date {

    // MARK: - Static Properties (Current Time)

    /// Current date in GMT format (RFC 1123)
    /// 格林威治标准时间格式（用于 HTTP 头等）
    ///
    /// Example:
    /// ```swift
    /// let gmt = Date.gmtString
    /// // Output: "Mon, 23 Dec 2025 12:34:56 GMT"
    /// ```
    public static var gmtString: String {
        DateFormatter.gmtFormatter.string(from: Date())
    }

    /// Current date in ISO 8601 format (UTC)
    /// ISO 8601 标准格式（UTC 时区）
    ///
    /// Example:
    /// ```swift
    /// let iso = Date.iso8601String
    /// // Output: "2025-12-23T12:34:56"
    /// ```
    public static var iso8601String: String {
        DateFormatter.iso8601Formatter.string(from: Date())
    }

    /// Current date only (no time)
    /// 当前日期（不含时间）
    ///
    /// Example:
    /// ```swift
    /// let date = Date.dateString
    /// // Output: "2025-12-23"
    /// ```
    public static var dateString: String {
        DateFormatter.dateFormatter.string(from: Date())
    }

    /// Current date with milliseconds (ISO 8601)
    /// 带毫秒的 ISO 8601 格式
    ///
    /// Example:
    /// ```swift
    /// let isoMs = Date.iso8601WithMilliseconds
    /// // Output: "2025-12-23T12:34:56.123"
    /// ```
    public static var iso8601WithMilliseconds: String {
        DateFormatter.iso8601MillisecondsFormatter.string(from: Date())
    }

    /// Current year and month
    /// 当前年月
    ///
    /// Example:
    /// ```swift
    /// let ym = Date.yearMonthString
    /// // Output: "2025/12"
    /// ```
    public static var yearMonthString: String {
        DateFormatter.yearMonthFormatter.string(from: Date())
    }

    /// Current month and day
    /// 当前月日
    ///
    /// Example:
    /// ```swift
    /// let md = Date.monthDayString
    /// // Output: "12/23"
    /// ```
    public static var monthDayString: String {
        DateFormatter.monthDayFormatter.string(from: Date())
    }

    // MARK: - Instance Properties

    /// Convert this date to ISO 8601 string
    /// 转换为 ISO 8601 格式字符串（不含时区信息）
    ///
    /// Example:
    /// ```swift
    /// let date = Date()
    /// let iso = date.iso8601String
    /// // Output: "2025-12-23T12:34:56"
    /// ```
    public var iso8601String: String {
        DateFormatter.iso8601Formatter.string(from: self)
    }

    /// Convert this date to date string (no time)
    /// 转换为日期字符串（不含时间）
    ///
    /// Example:
    /// ```swift
    /// let date = Date()
    /// let str = date.dateString
    /// // Output: "2025-12-23"
    /// ```
    public var dateString: String {
        DateFormatter.dateFormatter.string(from: self)
    }

    /// Convert this date to year/month string
    /// 转换为年月字符串（固定格式）
    ///
    /// Example:
    /// ```swift
    /// let date = Date()
    /// let ym = date.yearMonthString
    /// // Output: "2025/12"（固定格式，不受系统语言影响）
    /// ```
    public var yearMonthString: String {
        DateFormatter.yearMonthFormatter.string(from: self)
    }

    /// Convert this date to localized date and time string
    /// 转换为本地化的日期时间字符串（根据系统语言自动调整格式）
    ///
    /// Difference from `yearMonthString`:
    /// - `localizedString`: 根据用户系统语言显示（中文：2025年12月23日，英文：Dec 23, 2025）
    /// - `yearMonthString`: 固定格式（2025/12），不受语言影响
    ///
    /// Example:
    /// ```swift
    /// let date = Date()
    /// let localized = date.localizedString
    ///
    /// // 中文系统: "2025年12月23日 下午12:34:56"
    /// // 英文系统: "Dec 23, 2025, 12:34:56 PM"
    /// ```
    public var localizedString: String {
        DateFormatter.localizedFormatter.string(from: self)
    }

    // MARK: - Initialization

    /// Create Date from ISO 8601 string
    /// 从 ISO 8601 字符串创建日期
    ///
    /// Example:
    /// ```swift
    /// let date = Date.from(iso8601String: "2025-12-23T12:34:56.123Z")
    /// ```
    /// - Parameter utcString: ISO 8601 format string
    /// - Returns: Date or nil if parsing fails
    public static func from(iso8601String utcString: String) -> Date? {
        DateFormatter.iso8601Parser.date(from: utcString)
    }

    /// Create Date from custom format string
    /// 从自定义格式的字符串创建日期
    ///
    /// Example:
    /// ```swift
    /// let date = Date.from(string: "2025/12/23", format: "yyyy/MM/dd")
    /// ```
    /// - Parameters:
    ///   - string: Date string
    ///   - format: Date format (e.g., "yyyy-MM-dd", "yyyy/MM/dd")
    /// - Returns: Date or nil if parsing fails
    public static func from(string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

// MARK: - DateFormatter Cache

/// Cached DateFormatters for better performance
/// DateFormatter 创建开销较大，使用缓存提升性能
private extension DateFormatter {

    static let gmtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()

    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    static let iso8601MillisecondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()

    static let iso8601Parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let yearMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        return formatter
    }()

    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()

    static let localizedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}
