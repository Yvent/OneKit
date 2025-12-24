//
//  View+Gradient.swift
//  OneKitUI
//
//  Created by zyw on 2025/12/24.
//

#if canImport(SwiftUI)
import SwiftUI

public extension View {

    // MARK: - Linear Gradient

    /// Add a linear gradient background
    ///
    /// 添加线性渐变背景
    ///
    /// Example:
    /// ```swift
    /// // Vertical gradient (top to bottom)
    /// Text("Hello")
    ///     .gradientBackground(.blue, .purple, direction: .vertical)
    ///
    /// // Horizontal gradient (left to right)
    /// Text("Hello")
    ///     .gradientBackground(.blue, .purple, direction: .horizontal)
    ///
    /// // Custom angle (diagonal)
    /// Text("Hello")
    ///     .gradientBackground(.blue, .purple, angle: 45)
    /// ```
    ///
    /// - Parameters:
    ///   - startColor: Gradient start color / 渐变起始颜色
    ///   - endColor: Gradient end color / 渐变结束颜色
    ///   - direction: Gradient direction (default: .vertical) / 渐变方向（默认垂直）
    ///   - startPoint: Custom start point (optional) / 自定义起点（可选）
    ///   - endPoint: Custom end point (optional) / 自定义终点（可选）
    /// - Returns: View with gradient background / 应用了渐变背景的视图
    func gradientBackground(
        _ startColor: Color,
        _ endColor: Color,
        direction: GradientDirection = .vertical,
        startPoint: UnitPoint? = nil,
        endPoint: UnitPoint? = nil
    ) -> some View {
        self.background {
            Group {
                if let startPoint = startPoint, let endPoint = endPoint {
                    // Use custom start and end points
                    LinearGradient(
                        colors: [startColor, endColor],
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                } else {
                    // Use preset direction
                    LinearGradient(
                        colors: [startColor, endColor],
                        startPoint: direction.startPoint,
                        endPoint: direction.endPoint
                    )
                }
            }
            .ignoresSafeArea()
        }
    }

    /// Add a multi-stop gradient background
    ///
    /// 添加多点渐变背景
    ///
    /// Example:
    /// ```swift
    /// Text("Rainbow")
    ///     .gradientBackground(stops: [
    ///         .init(color: .red, location: 0.0),
    ///         .init(color: .yellow, location: 0.5),
    ///         .init(color: .blue, location: 1.0)
    ///     ])
    /// ```
    ///
    /// - Parameters:
    ///   - stops: Array of gradient stops / 渐变颜色点数组
    ///   - startPoint: Gradient start point / 渐变起点
    ///   - endPoint: Gradient end point / 渐变终点
    /// - Returns: View with gradient background / 应用了渐变背景的视图
    func gradientBackground(
        stops: [Gradient.Stop],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> some View {
        self.background {
            LinearGradient(
                stops: stops,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Angular Gradient

    /// Add an angular (conic) gradient background
    ///
    /// 添加角向（锥形）渐变背景
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .angularGradientBackground(.blue, .purple)
    /// ```
    ///
    /// - Parameters:
    ///   - startColor: Gradient start color / 渐变起始颜色
    ///   - endColor: Gradient end color / 渐变结束颜色
    ///   - center: Gradient center point / 渐变中心点
    ///   - angle: Rotation angle in degrees / 旋转角度
    /// - Returns: View with angular gradient background / 应用了角向渐变背景的视图
    func angularGradientBackground(
        _ startColor: Color,
        _ endColor: Color,
        center: UnitPoint = .center,
        angle: Angle = .zero
    ) -> some View {
        self.background {
            AngularGradient(
                colors: [startColor, endColor],
                center: center,
                angle: angle
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Radial Gradient

    /// Add a radial gradient background
    ///
    /// 添加径向渐变背景
    ///
    /// Example:
    /// ```swift
    /// Circle()
    ///     .radialGradientBackground(.blue, .purple)
    /// ```
    ///
    /// - Parameters:
    ///   - startColor: Gradient start color / 渐变起始颜色
    ///   - endColor: Gradient end color / 渐变结束颜色
    ///   - center: Gradient center point / 渐变中心点
    ///   - startRadius: Inner radius / 内圆半径
    ///   - endRadius: Outer radius / 外圆半径
    /// - Returns: View with radial gradient background / 应用了径向渐变背景的视图
    func radialGradientBackground(
        _ startColor: Color,
        _ endColor: Color,
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) -> some View {
        self.background {
            RadialGradient(
                colors: [startColor, endColor],
                center: center,
                startRadius: startRadius,
                endRadius: endRadius
            )
            .ignoresSafeArea()
        }
    }
}

/// Gradient direction presets
///
/// 渐变方向预设
public enum GradientDirection {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
    case vertical
    case horizontal

    /// Gradient start point
    ///
    /// 渐变起点
    public var startPoint: UnitPoint {
        switch self {
        case .topToBottom, .vertical:
            return .top
        case .bottomToTop:
            return .bottom
        case .leftToRight, .horizontal:
            return .leading
        case .rightToLeft:
            return .trailing
        }
    }

    /// Gradient end point
    ///
    /// 渐变终点
    public var endPoint: UnitPoint {
        switch self {
        case .topToBottom, .vertical:
            return .bottom
        case .bottomToTop:
            return .top
        case .leftToRight, .horizontal:
            return .trailing
        case .rightToLeft:
            return .leading
        }
    }
}

// MARK: - Convenience Extensions

public extension View {

    /// Add a vertical gradient background (top to bottom)
    ///
    /// 添加垂直渐变背景（从上到下）
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .verticalGradientBackground(.blue, .purple)
    /// ```
    func verticalGradientBackground(
        _ startColor: Color,
        _ endColor: Color
    ) -> some View {
        gradientBackground(startColor, endColor, direction: .vertical)
    }

    /// Add a horizontal gradient background (left to right)
    ///
    /// 添加水平渐变背景（从左到右）
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .horizontalGradientBackground(.blue, .purple)
    /// ```
    func horizontalGradientBackground(
        _ startColor: Color,
        _ endColor: Color
    ) -> some View {
        gradientBackground(startColor, endColor, direction: .horizontal)
    }

    /// Add a diagonal gradient background (top-left to bottom-right)
    ///
    /// 添加对角线渐变背景（左上到右下）
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .diagonalGradientBackground(.blue, .purple)
    /// ```
    func diagonalGradientBackground(
        _ startColor: Color,
        _ endColor: Color
    ) -> some View {
        gradientBackground(
            startColor,
            endColor,
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 1, y: 1)
        )
    }
}
#endif
