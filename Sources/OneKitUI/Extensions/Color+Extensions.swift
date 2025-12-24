//
//  Color+Extensions.swift
//  OneKitUI
//
//  Created by zyw on 2025/12/24.
//

#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit
import OneKitCore

extension Color {

    // MARK: - Initialization from UIColor

    /// Create a SwiftUI Color from a hex string
    /// 从十六进制字符串创建 SwiftUI 颜色
    ///
    /// Example:
    /// ```swift
    /// Color.hex("#FF0000")
    /// Color.hex("FF0000")
    /// ```
    /// - Parameter hex: Hex string (with or without #) / 十六进制字符串（带或不带#）
    /// - Returns: SwiftUI Color instance
    public static func hex(_ hex: String) -> Color {
        Color(uiColor: UIColor.hex(hex))
    }

    /// Create a SwiftUI Color from RGB values (0-255)
    /// 从 RGB 值创建 SwiftUI 颜色（0-255）
    ///
    /// Example:
    /// ```swift
    /// Color.rgb(255, 128, 64)
    /// ```
    /// - Parameters:
    ///   - red: Red component (0-255) / 红色分量（0-255）
    ///   - green: Green component (0-255) / 绿色分量（0-255）
    ///   - blue: Blue component (0-255) / 蓝色分量（0-255）
    /// - Returns: SwiftUI Color instance
    public static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> Color {
        Color(uiColor: UIColor.rgb(red, green, blue))
    }

    /// Create a SwiftUI Color from RGBA values (0-255 for RGB, 0-1 for alpha)
    /// 从 RGBA 值创建 SwiftUI 颜色（RGB 0-255，alpha 0-1）
    ///
    /// Example:
    /// ```swift
    /// Color.rgba(255, 128, 64, 0.8)
    /// ```
    /// - Parameters:
    ///   - red: Red component (0-255) / 红色分量（0-255）
    ///   - green: Green component (0-255) / 绿色分量（0-255）
    ///   - blue: Blue component (0-255) / 蓝色分量（0-255）
    ///   - alpha: Alpha component (0-1) / 透明度（0-1）
    /// - Returns: SwiftUI Color instance
    public static func rgba(
        _ red: CGFloat,
        _ green: CGFloat,
        _ blue: CGFloat,
        _ alpha: CGFloat
    ) -> Color {
        Color(uiColor: UIColor.rgba(red, green, blue, alpha))
    }

    /// Create a grayscale SwiftUI Color from single value (0-255)
    /// 从单个值创建灰度 SwiftUI 颜色（0-255）
    ///
    /// Example:
    /// ```swift
    /// Color.gray(128) // Medium gray
    /// ```
    /// - Parameter value: Grayscale value (0-255) / 灰度值（0-255）
    /// - Returns: SwiftUI Color instance
    public static func gray(_ value: CGFloat) -> Color {
        Color(uiColor: UIColor.gray(value))
    }

    /// Create a random SwiftUI Color
    /// 创建随机 SwiftUI 颜色
    ///
    /// Example:
    /// ```swift
    /// Color.random()                      // Opaque random color
    /// Color.random(randomOpacity: true)  // Random with transparency
    /// ```
    /// - Parameter randomOpacity: Whether to randomize opacity (default: false)
    /// - Returns: SwiftUI Color instance
    public static func random(randomOpacity: Bool = false) -> Color {
        Color(uiColor: UIColor.random(randomOpacity: randomOpacity))
    }
}

#endif
#endif
