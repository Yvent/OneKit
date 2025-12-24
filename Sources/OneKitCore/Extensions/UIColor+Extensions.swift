//
//  UIColor+Extensions.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

#if canImport(UIKit)
import UIKit

extension UIColor {

    // MARK: - RGB Creation

    /// Create color from RGB values (0-255)
    /// 从 RGB 值创建颜色（0-255）
    ///
    /// Example:
    /// ```swift
    /// let color = UIColor.rgb(255, 128, 64)
    /// ```
    /// - Parameters:
    ///   - red: Red component (0-255) / 红色分量（0-255）
    ///   - green: Green component (0-255) / 绿色分量（0-255）
    ///   - blue: Blue component (0-255) / 蓝色分量（0-255）
    /// - Returns: UIColor instance
    public static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: 1.0
        )
    }

    /// Create color from RGBA values (0-255)
    /// 从 RGBA 值创建颜色（0-255）
    ///
    /// Example:
    /// ```swift
    /// let color = UIColor.rgba(255, 128, 64, 0.8)
    /// ```
    /// - Parameters:
    ///   - red: Red component (0-255) / 红色分量（0-255）
    ///   - green: Green component (0-255) / 绿色分量（0-255）
    ///   - blue: Blue component (0-255) / 蓝色分量（0-255）
    ///   - alpha: Alpha component (0-1) / 透明度（0-1）
    /// - Returns: UIColor instance
    public static func rgba(
        _ red: CGFloat,
        _ green: CGFloat,
        _ blue: CGFloat,
        _ alpha: CGFloat
    ) -> UIColor {
        return UIColor(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: alpha
        )
    }

    /// Create grayscale color from single value (0-255)
    /// 从单个值创建灰度颜色（0-255）
    ///
    /// Example:
    /// ```swift
    /// let gray = UIColor.gray(128) // Medium gray
    /// ```
    /// - Parameter value: Grayscale value (0-255) / 灰度值（0-255）
    /// - Returns: UIColor instance
    public static func gray(_ value: CGFloat) -> UIColor {
        return rgb(value, value, value)
    }

    /// Create color from hex string
    /// 从十六进制字符串创建颜色
    ///
    /// Example:
    /// ```swift
    /// let red = UIColor(hex: "#FF0000")
    /// let blue = UIColor(hex: "0000FF")
    /// ```
    /// - Parameter hex: Hex string (with or without #) / 十六进制字符串（带或不带#）
    /// - Returns: UIColor instance
    public static func hex(_ hexString: String) -> UIColor {
        let hex = hexString.replacingOccurrences(of: "#", with: "")

        // Validate hex string / 验证十六进制字符串
        guard hex.count == 6 || hex.count == 8 else {
            return UIColor.clear
        }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgbValue) else {
            return UIColor.clear
        }

        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0
        var a: UInt64 = 0xFF

        if hex.count == 8 {
            // 8-digit hex format: RRGGBBAA
            // 8位hex格式：RRGGBBAA
            r = (rgbValue & 0xFF000000) >> 24
            g = (rgbValue & 0x00FF0000) >> 16
            b = (rgbValue & 0x0000FF00) >> 8
            a = rgbValue & 0x000000FF
        } else {
            // 6-digit hex format: RRGGBB
            // 6位hex格式：RRGGBB
            r = (rgbValue & 0xFF0000) >> 16
            g = (rgbValue & 0x00FF00) >> 8
            b = rgbValue & 0x0000FF
            a = 0xFF
        }

        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    // MARK: - Hex String Conversion

    /// Convert color to hex string (without # prefix)
    /// 将颜色转换为十六进制字符串（不带#前缀）
    ///
    /// Example:
    /// ```swift
    /// UIColor.red.toHexString // "FF0000"
    /// ```
    /// - Returns: Hex string or empty string if conversion fails
    public var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }

    /// Convert color to hex string with # prefix
    /// 将颜色转换为带#前缀的十六进制字符串
    ///
    /// Example:
    /// ```swift
    /// UIColor.red.toHexHashString // "#FF0000"
    /// ```
    /// - Returns: Hex string with # prefix
    public var toHexHashString: String {
        let hex = toHexString
        return hex.isEmpty ? "" : "#\(hex)"
    }

    // MARK: - Color Components

    /// Get red component (0-1)
    /// 获取红色分量（0-1）
    public var redComponent: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }

    /// Get green component (0-1)
    /// 获取绿色分量（0-1）
    public var greenComponent: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }

    /// Get blue component (0-1)
    /// 获取蓝色分量（0-1）
    public var blueComponent: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }

    /// Get alpha component (0-1)
    /// 获取透明度分量（0-1）
    public var alphaComponent: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
}

#endif
