//
//  View+GradientTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

#if canImport(SwiftUI)
import SwiftUI
import Testing
@testable import OneKitUI

@Suite("View Gradient Extensions Tests")
@MainActor
struct ViewGradientTests {

    // MARK: - Linear Gradient Tests

    /// Test vertical gradient background
    /// 测试垂直渐变背景
    @Test("Vertical gradient should compile")
    func verticalGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .vertical)

        _ = AnyView(view)
    }

    /// Test horizontal gradient background
    /// 测试水平渐变背景
    @Test("Horizontal gradient should compile")
    func horizontalGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .horizontal)

        _ = AnyView(view)
    }

    /// Test top to bottom gradient
    /// 测试从上到下的渐变
    @Test("Top to bottom gradient should compile")
    func topToBottomGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .topToBottom)

        _ = AnyView(view)
    }

    /// Test bottom to top gradient
    /// 测试从下到上的渐变
    @Test("Bottom to top gradient should compile")
    func bottomToTopGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .bottomToTop)

        _ = AnyView(view)
    }

    /// Test left to right gradient
    /// 测试从左到右的渐变
    @Test("Left to right gradient should compile")
    func leftToRightGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .leftToRight)

        _ = AnyView(view)
    }

    /// Test right to left gradient
    /// 测试从右到左的渐变
    @Test("Right to left gradient should compile")
    func rightToLeftGradient() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple, direction: .rightToLeft)

        _ = AnyView(view)
    }

    /// Test custom start and end points
    /// 测试自定义起点和终点
    @Test("Custom points gradient should compile")
    func customPointsGradient() async throws {
        let view = Text("Test")
            .gradientBackground(
                .blue,
                .purple,
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )

        _ = AnyView(view)
    }

    // MARK: - Multi-Stop Gradient Tests

    /// Test multi-stop gradient
    /// 测试多点渐变
    @Test("Multi-stop gradient should compile")
    func multiStopGradient() async throws {
        let view = Text("Test")
            .gradientBackground(stops: [
                .init(color: .red, location: 0.0),
                .init(color: .yellow, location: 0.5),
                .init(color: .blue, location: 1.0)
            ])

        _ = AnyView(view)
    }

    /// Test multi-stop gradient with custom points
    /// 测试自定义点的多点渐变
    @Test("Multi-stop gradient with custom points should compile")
    func multiStopGradientWithPoints() async throws {
        let view = Text("Test")
            .gradientBackground(
                stops: [
                    .init(color: .blue, location: 0.0),
                    .init(color: .purple, location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

        _ = AnyView(view)
    }

    // MARK: - Radial Gradient Tests

    /// Test radial gradient background
    /// 测试径向渐变背景
    @Test("Radial gradient should compile")
    func radialGradient() async throws {
        let view = Text("Test")
            .radialGradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    /// Test radial gradient with custom parameters
    /// 测试自定义参数的径向渐变
    @Test("Radial gradient with custom parameters should compile")
    func radialGradientCustom() async throws {
        let view = Text("Test")
            .radialGradientBackground(
                .blue,
                .purple,
                center: .topLeading,
                startRadius: 10,
                endRadius: 100
            )

        _ = AnyView(view)
    }

    // MARK: - Angular Gradient Tests

    /// Test angular gradient background
    /// 测试角向渐变背景
    @Test("Angular gradient should compile")
    func angularGradient() async throws {
        let view = Text("Test")
            .angularGradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    /// Test angular gradient with custom angle
    /// 测试自定义角度的角向渐变
    @Test("Angular gradient with angle should compile")
    func angularGradientWithAngle() async throws {
        let view = Text("Test")
            .angularGradientBackground(
                .blue,
                .purple,
                angle: .degrees(45)
            )

        _ = AnyView(view)
    }

    // MARK: - Convenience Methods Tests

    /// Test convenience vertical gradient method
    /// 测试便捷垂直渐变方法
    @Test("Convenience vertical gradient should compile")
    func convenienceVerticalGradient() async throws {
        let view = Text("Test")
            .verticalGradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    /// Test convenience horizontal gradient method
    /// 测试便捷水平渐变方法
    @Test("Convenience horizontal gradient should compile")
    func convenienceHorizontalGradient() async throws {
        let view = Text("Test")
            .horizontalGradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    /// Test convenience diagonal gradient method
    /// 测试便捷对角渐变方法
    @Test("Convenience diagonal gradient should compile")
    func convenienceDiagonalGradient() async throws {
        let view = Text("Test")
            .diagonalGradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    // MARK: - Integration Tests

    /// Test combining gradient with other modifiers
    /// 测试渐变与其他修饰符的组合
    @Test("Should combine with other modifiers")
    func combineWithModifiers() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .purple)
            .font(.title)
            .foregroundColor(.white)
            .padding()

        _ = AnyView(view)
    }

    /// Test gradient on different view types
    /// 测试不同视图类型的渐变
    @Test("Should work with different view types")
    func differentViewTypes() async throws {
        let views: [any View] = [
            Text("Text").gradientBackground(.blue, .purple),
            Image(systemName: "star").gradientBackground(.red, .orange),
            Rectangle().gradientBackground(.green, .blue),
            Circle().gradientBackground(.purple, .pink),
            VStack { Text("Content") }.gradientBackground(.blue, .purple)
        ]

        for view in views {
            _ = AnyView(view)
        }
    }

    /// Test multiple gradients can be chained
    /// 测试多个渐变可以链接
    @Test("Should support gradient chaining")
    func gradientChaining() async throws {
        let view = Rectangle()
            .gradientBackground(.blue, .purple, direction: .vertical)
            .overlay(
                Text("Overlay")
                    .gradientBackground(.white, .white.opacity(0.5))
            )

        _ = AnyView(view)
    }

    /// Test gradient direction enum values
    /// 测试渐变方向枚举值
    @Test("Gradient direction should have correct points")
    func gradientDirectionPoints() async throws {
        // Vertical
        #expect(GradientDirection.vertical.startPoint == .top)
        #expect(GradientDirection.vertical.endPoint == .bottom)

        // Horizontal
        #expect(GradientDirection.horizontal.startPoint == .leading)
        #expect(GradientDirection.horizontal.endPoint == .trailing)

        // Top to bottom
        #expect(GradientDirection.topToBottom.startPoint == .top)
        #expect(GradientDirection.topToBottom.endPoint == .bottom)

        // Bottom to top
        #expect(GradientDirection.bottomToTop.startPoint == .bottom)
        #expect(GradientDirection.bottomToTop.endPoint == .top)

        // Left to right
        #expect(GradientDirection.leftToRight.startPoint == .leading)
        #expect(GradientDirection.leftToRight.endPoint == .trailing)

        // Right to left
        #expect(GradientDirection.rightToLeft.startPoint == .trailing)
        #expect(GradientDirection.rightToLeft.endPoint == .leading)
    }

    // MARK: - Edge Cases Tests

    /// Test gradient with same colors
    /// 测试相同颜色的渐变
    @Test("Should handle same colors")
    func sameColors() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .blue)

        _ = AnyView(view)
    }

    /// Test gradient with opacity
    /// 测试带透明度的渐变
    @Test("Should handle opacity colors")
    func opacityColors() async throws {
        let view = Text("Test")
            .gradientBackground(.blue.opacity(0.5), .purple.opacity(0.8))

        _ = AnyView(view)
    }

    /// Test gradient with system colors
    /// 测试系统颜色的渐变
    @Test("Should work with system colors")
    func systemColors() async throws {
        let view = Text("Test")
            .gradientBackground(.blue, .indigo)

        _ = AnyView(view)
    }

    /// Test multiple stops gradient
    /// 测试多色渐变
    @Test("Should support multiple color stops")
    func multipleColorStops() async throws {
        let view = Text("Rainbow")
            .gradientBackground(stops: [
                .init(color: .red, location: 0.0),
                .init(color: .orange, location: 0.2),
                .init(color: .yellow, location: 0.4),
                .init(color: .green, location: 0.6),
                .init(color: .blue, location: 0.8),
                .init(color: .purple, location: 1.0)
            ])

        _ = AnyView(view)
    }

    /// Test gradient with complex view hierarchy
    /// 测试复杂视图层级的渐变
    @Test("Should work with complex view hierarchy")
    func complexHierarchy() async throws {
        let view = VStack {
            HStack {
                Text("Left")
                    .verticalGradientBackground(.blue, .purple)
                Text("Right")
                    .horizontalGradientBackground(.red, .orange)
            }
            Text("Bottom")
                .diagonalGradientBackground(.green, .blue)
        }

        _ = AnyView(view)
    }

    /// Test radial gradient on different shapes
    /// 测试不同形状的径向渐变
    @Test("Radial gradient should work with shapes")
    func radialGradientWithShapes() async throws {
        let shapes: [any View] = [
            Circle().radialGradientBackground(.blue, .purple),
            Rectangle().radialGradientBackground(.red, .orange),
            Ellipse().radialGradientBackground(.green, .blue),
            Capsule().radialGradientBackground(.purple, .pink)
        ]

        for shape in shapes {
            _ = AnyView(shape)
        }
    }

    /// Test angular gradient on various views
    /// 测试各种视图的角向渐变
    @Test("Angular gradient should work with views")
    func angularGradientWithViews() async throws {
        let views: [any View] = [
            Circle().angularGradientBackground(.blue, .purple),
            Rectangle().angularGradientBackground(.red, .orange),
            Text("Text").angularGradientBackground(.green, .blue, angle: .degrees(90))
        ]

        for view in views {
            _ = AnyView(view)
        }
    }

    /// Test gradient background ignores safe area
    /// 测试渐变背景忽略安全区域
    @Test("Gradient background should ignore safe area")
    func ignoreSafeArea() async throws {
        let view = Text("Test")
            .padding()
            .gradientBackground(.blue, .purple)

        _ = AnyView(view)
    }

    /// Test combining different gradient types
    /// 测试组合不同类型的渐变
    @Test("Should combine different gradient types")
    func combineGradientTypes() async throws {
        let baseView = Rectangle()
            .gradientBackground(.blue, .purple, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                Circle()
                    .radialGradientBackground(.white.opacity(0.3), .clear)
                    .frame(width: 100, height: 100)
            )

        _ = AnyView(baseView)
    }

    /// Test default parameters
    /// 测试默认参数
    @Test("Should use default parameters correctly")
    func defaultParameters() async throws {
        // Test default direction
        let vertical = Text("Test")
            .gradientBackground(.blue, .purple)
        _ = AnyView(vertical)

        // Test default radial gradient center
        let radial = Text("Test")
            .radialGradientBackground(.blue, .purple)
        _ = AnyView(radial)

        // Test default angular gradient
        let angular = Text("Test")
            .angularGradientBackground(.blue, .purple)
        _ = AnyView(angular)
    }
}

// MARK: - Helper for linear gradient with custom points
private extension View {
    func linearGradientBackground(
        _ colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> some View {
        background {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .ignoresSafeArea()
        }
    }
}
#endif
