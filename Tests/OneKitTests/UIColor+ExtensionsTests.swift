//
//  UIColor+ExtensionsTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/24.
//

import Testing
@testable import OneKitCore
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

@Suite("UIColor Extensions Tests")
struct UIColorExtensionsTests {

    // MARK: - RGB Creation Tests

    /// Test RGB color creation
    /// 测试 RGB 颜色创建
    @Test("RGB color creation should work correctly")
    func rgbColorCreation() async throws {
        let color = UIColor.rgb(255, 128, 64)
        let red = color.redComponent
        let green = color.greenComponent
        let blue = color.blueComponent

        // Check RGB values / 检查 RGB 值
        #expect(red == 1.0)
        #expect(green == 128.0 / 255.0)
        #expect(blue == 64.0 / 255.0)
    }

    /// Test RGBA color creation with alpha
    /// 测试带透明度的 RGBA 颜色创建
    @Test("RGBA color creation should respect alpha")
    func rgbaColorCreation() async throws {
        let alpha: CGFloat = 0.5
        let color = UIColor.rgba(255, 128, 64, alpha)
        let colorAlpha = color.alphaComponent

        #expect(colorAlpha == alpha)
    }

    /// Test grayscale color creation
    /// 测试灰度颜色创建
    @Test("Grayscale color should have equal RGB components")
    func grayscaleColorCreation() async throws {
        let color = UIColor.gray(128)
        let red = color.redComponent
        let green = color.greenComponent
        let blue = color.blueComponent

        #expect(red == green)
        #expect(green == blue)
        #expect(red == 128.0 / 255.0)
    }

    // MARK: - Hex String Tests

    /// Test hex color creation with # prefix
    /// 测试带#前缀的十六进制颜色创建
    @Test("Hex color with # prefix should create correct color")
    func hexColorWithHashPrefix() async throws {
        let color = UIColor.hex("#FF0000")
        let red = color.redComponent

        #expect(red == 1.0)
        #expect(color.greenComponent == 0)
        #expect(color.blueComponent == 0)
    }

    /// Test hex color creation without # prefix
    /// 测试不带#前缀的十六进制颜色创建
    @Test("Hex color without # prefix should create correct color")
    func hexColorWithoutHashPrefix() async throws {
        let color = UIColor.hex("00FF00")
        let green = color.greenComponent

        #expect(color.redComponent == 0)
        #expect(green == 1.0)
        #expect(color.blueComponent == 0)
    }

    /// Test 8-digit hex color with alpha channel (RRGGBBAA format)
    /// 测试8位十六进制颜色带透明度通道（RRGGBBAA格式）
    ///
    /// Input format: "FF000080" = Red(FF) + Green(00) + Blue(00) + Alpha(80)
    /// - FF (255) → Red = 1.0
    /// - 00 (0) → Green = 0.0
    /// - 00 (0) → Blue = 0.0
    /// - 80 (128) → Alpha = 128/255 ≈ 0.502 (50% transparency)
    @Test("8-digit hex string should parse RGBA correctly")
    func hexColorWithAlpha() async throws {
        let color = UIColor.hex("FF000080")

        // Verify color components / 验证颜色分量
        #expect(color.redComponent == 1.0, "Red should be max (FF)")
        #expect(color.greenComponent == 0.0, "Green should be zero (00)")
        #expect(color.blueComponent == 0.0, "Blue should be zero (00)")
        #expect(color.alphaComponent == 128.0 / 255.0, "Alpha should be 50% (80)")
    }

    /// Test invalid hex string returns clear color
    /// 测试无效十六进制字符串返回透明色
    @Test("Invalid hex string should return clear color")
    func invalidHexString() async throws {
        let invalidColor = UIColor.hex("invalid")
        #expect(invalidColor.alphaComponent == 0)
    }

    /// Test short hex string returns clear color
    /// 测试过短的十六进制字符串返回透明色
    @Test("Short hex string should return clear color")
    func shortHexString() async throws {
        let shortColor = UIColor.hex("FFF")
        #expect(shortColor.alphaComponent == 0)
    }

    // MARK: - Hex String Conversion Tests

    /// Test convert color to hex string
    /// 测试颜色转换为十六进制字符串
    @Test("Color should convert to hex string correctly")
    func toHexStringTest() async throws {
        let color = UIColor.rgb(255, 0, 0) // Red
        let hex = color.toHexString

        #expect(hex == "FF0000")
    }

    /// Test convert color to hex string with # prefix
    /// 测试颜色转换为带#前缀的十六进制字符串
    @Test("Color should convert to hex hash string correctly")
    func toHexHashStringTest() async throws {
        let color = UIColor.rgb(0, 255, 0) // Green
        let hex = color.toHexHashString

        #expect(hex == "#00FF00")
    }

    /// Test blue color conversion
    /// 测试蓝色颜色转换
    @Test("Blue color should convert to correct hex string")
    func blueColorToHexTest() async throws {
        let color = UIColor.rgb(0, 0, 255) // Blue
        let hex = color.toHexString

        #expect(hex == "0000FF")
    }

    // MARK: - Color Component Tests

    /// Test get red component
    /// 测试获取红色分量
    @Test("Red color should have max red component")
    func redComponentTest() async throws {
        let red = UIColor.rgb(255, 0, 0)
        #expect(red.redComponent == 1.0)
        #expect(red.greenComponent == 0)
        #expect(red.blueComponent == 0)
    }

    /// Test get green component
    /// 测试获取绿色分量
    @Test("Green color should have max green component")
    func greenComponentTest() async throws {
        let green = UIColor.rgb(0, 255, 0)
        #expect(green.redComponent == 0)
        #expect(green.greenComponent == 1.0)
        #expect(green.blueComponent == 0)
    }

    /// Test get blue component
    /// 测试获取蓝色分量
    @Test("Blue color should have max blue component")
    func blueComponentTest() async throws {
        let blue = UIColor.rgb(0, 0, 255)
        #expect(blue.redComponent == 0)
        #expect(blue.greenComponent == 0)
        #expect(blue.blueComponent == 1.0)
    }

    /// Test get alpha component
    /// 测试获取透明度分量
    @Test("Color alpha component should be correct")
    func alphaComponentTest() async throws {
        let alphaValue: CGFloat = 0.7
        let color = UIColor.rgba(100, 100, 100, alphaValue)
        #expect(color.alphaComponent == alphaValue)
    }

    // MARK: - Edge Cases Tests

    /// Test black color
    /// 测试黑色
    @Test("Black color should have zero components")
    func blackColorTest() async throws {
        let black = UIColor.rgb(0, 0, 0)
        #expect(black.redComponent == 0)
        #expect(black.greenComponent == 0)
        #expect(black.blueComponent == 0)
    }

    /// Test white color
    /// 测试白色
    @Test("White color should have max components")
    func whiteColorTest() async throws {
        let white = UIColor.rgb(255, 255, 255)
        #expect(white.redComponent == 1.0)
        #expect(white.greenComponent == 1.0)
        #expect(white.blueComponent == 1.0)
    }

    /// Test system colors conversion
    /// 测试系统颜色转换
    @Test("System colors should convert to hex string")
    func systemColorConversion() async throws {
        let systemRed = UIColor.red
        let hex = systemRed.toHexString

        // System red should convert to non-empty hex string
        // 系统红色应该转换为非空的十六进制字符串
        #expect(!hex.isEmpty)
        #expect(hex.count == 6)
    }

    /// Test mixed color values
    /// 测试混合颜色值
    @Test("Mixed RGB values should create correct color")
    func mixedColorValuesTest() async throws {
        let color = UIColor.rgb(123, 234, 56)
        #expect(color.redComponent == 123.0 / 255.0)
        #expect(color.greenComponent == 234.0 / 255.0)
        #expect(color.blueComponent == 56.0 / 255.0)
    }
}

#endif
