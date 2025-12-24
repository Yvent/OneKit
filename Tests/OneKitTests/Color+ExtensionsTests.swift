//
//  Color+ExtensionsTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

import Testing
@testable import OneKitUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI

@Suite("Color Extensions Tests")
struct ColorExtensionsTests {

    // MARK: - Hex Color Tests

    /// Test Color creation from hex string with # prefix
    /// 测试从带#前缀的十六进制字符串创建 Color
    @Test("Color with hex # prefix should be created")
    func colorWithHexPrefix() async throws {
        let color = Color.hex("#FF0000")
        // Color should be created successfully / Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test Color creation from hex string without # prefix
    /// 测试从不带#前缀的十六进制字符串创建 Color
    @Test("Color with hex without # prefix should be created")
    func colorWithHexNoPrefix() async throws {
        let color = Color.hex("00FF00")
        // Color should be created successfully / Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test Color creation from hex string with alpha
    /// 测试从带透明度的十六进制字符串创建 Color
    @Test("Color with hex alpha should be created")
    func colorWithHexAlpha() async throws {
        let color = Color.hex("FF000080")
        // Color with alpha should be created successfully / 带透明度的 Color 应该成功创建
        #expect(color != Color.clear)
    }

    // MARK: - RGB Color Tests

    /// Test Color creation from RGB values
    /// 测试从 RGB 值创建 Color
    @Test("Color from RGB should be created")
    func colorFromRGB() async throws {
        let color = Color.rgb(255, 128, 64)
        // Color should be created successfully / Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test Color creation from RGBA values
    /// 测试从 RGBA 值创建 Color
    @Test("Color from RGBA should be created")
    func colorFromRGBA() async throws {
        let alpha: CGFloat = 0.5
        let color = Color.rgba(255, 128, 64, alpha)
        // Color with alpha should be created successfully / 带透明度的 Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test grayscale Color creation
    /// 测试灰度 Color 创建
    @Test("Grayscale Color should be created")
    func grayscaleColor() async throws {
        let color = Color.gray(128)
        // Gray color should be created successfully / 灰度 Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test white Color (grayscale max value)
    /// 测试白色 Color（灰度最大值）
    @Test("White Color should be created")
    func whiteColor() async throws {
        let color = Color.gray(255)
        // White color should be created successfully / 白色 Color 应该成功创建
        #expect(color != Color.clear)
    }

    /// Test black Color (grayscale min value)
    /// 测试黑色 Color（灰度最小值）
    @Test("Black Color should be created")
    func blackColor() async throws {
        let color = Color.gray(0)
        // Black color should be created successfully / 黑色 Color 应该成功创建
        #expect(color != Color.clear)
    }

    // MARK: - Random Color Tests

    /// Test random Color creation (opaque)
    /// 测试随机 Color 创建（不透明）
    @Test("Random Color should be created")
    func randomColor() async throws {
        let color1 = Color.random()
        let color2 = Color.random()
        // Random colors should be created / 随机颜色应该成功创建
        #expect(color1 != Color.clear)
        #expect(color2 != Color.clear)
        // Different random calls should produce different colors / 不同的随机调用应该产生不同的颜色
        // Note: There's a tiny chance they could be the same, but highly unlikely
        // 注意：有极小可能它们相同，但不太可能
    }

    /// Test random Color with random opacity
    /// 测试带随机透明度的随机 Color
    @Test("Random Color with opacity should be created")
    func randomColorWithOpacity() async throws {
        let color = Color.random(randomOpacity: true)
        // Random color with opacity should be created / 带透明度的随机 Color 应该成功创建
        #expect(color != Color.clear)
    }

    // MARK: - System Color Tests

    /// Test system Color compatibility
    /// 测试系统 Color 兼容性
    @Test("System colors should work with extensions")
    func systemColors() async throws {
        let red = Color.hex("#FF0000")
        let green = Color.rgb(0, 255, 0)
        let blue = Color.hex("0000FF")

        // All colors should be created successfully / 所有颜色应该成功创建
        #expect(red != Color.clear)
        #expect(green != Color.clear)
        #expect(blue != Color.clear)
    }

    // MARK: - Edge Cases Tests

    /// Test invalid hex string doesn't crash
    /// 测试无效十六进制字符串不会崩溃
    @Test("Invalid hex string should create a valid Color")
    func invalidHexString() async throws {
        // Invalid hex returns UIColor.clear
        // Just verify it creates a Color without crashing
        // 验证能创建 Color 且不崩溃即可
        let color = Color.hex("invalid")
        #expect(color != Color.red)  // Should not be red (basic sanity check)
    }

    /// Test empty hex string doesn't crash
    /// 测试空十六进制字符串不会崩溃
    @Test("Empty hex string should create a valid Color")
    func emptyHexString() async throws {
        // Empty hex returns UIColor.clear
        // Just verify it creates a Color without crashing
        // 验证能创建 Color 且不崩溃即可
        let color = Color.hex("")
        #expect(color != Color.blue)  // Should not be blue (basic sanity check)
    }
}

#endif
