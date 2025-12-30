//
//  ImageHasherTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/30.
//

import Testing
@testable import OneKitCore
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

enum TestError: Error {
    case imageCreationFailed
}

@Suite("ImageHasher Tests")
struct ImageHasherTests {

    // MARK: - Test Image Helpers

    /// Creates a solid color test image
    /// 创建纯色测试图片
    ///
    /// - Parameters:
    ///   - color: Fill color / 填充颜色
    ///   - size: Image size / 图片尺寸
    /// - Returns: Test image / 测试图片
    private func createTestImage(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        UIRectFill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// Creates a gradient test image (white to black)
    /// 创建渐变测试图片（白色到黑色）
    ///
    /// - Parameter size: Image size / 图片尺寸
    /// - Returns: Gradient image / 渐变图片
    private func createGradientImage(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0]) else {
            return UIImage()
        }

        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// Creates a half-black half-white test image
    /// 创建半黑半白的测试图片
    ///
    /// - Parameter size: Image size / 图片尺寸
    /// - Returns: Pattern image / 图案图片
    private func createHalfPatternImage(inverted: Bool = false, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)

        if inverted {
            UIColor.black.setFill()
            UIRectFill(rect)
            UIColor.white.setFill()
            UIRectFill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
        } else {
            UIColor.white.setFill()
            UIRectFill(rect)
            UIColor.black.setFill()
            UIRectFill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
        }

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    // MARK: - dHash Tests

    /// Test dHash algorithm produces consistent results for identical images
    /// 测试 dHash 算法对相同图片产生一致的结果
    @Test("dHash should produce identical hashes for identical images")
    func dHashConsistencyTest() async throws {
        let image = createTestImage(color: .red)

        let hash1 = ImageHasher.computeHash(for: image, type: .dHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image, type: .dHash, precision: 8)

        #expect(hash1 != nil, "Hash should not be nil")
        #expect(hash1 == hash2, "Identical images should produce identical hashes")
    }

    /// Test dHash hash length matches expected precision
    /// 测试 dHash 哈希长度符合预期精度
    @Test("dHash hash length should match precision squared")
    func dHashLengthTest() async throws {
        let image = createTestImage(color: .blue)
        let precision = 8

        let hash = ImageHasher.computeHash(for: image, type: .dHash, precision: precision)

        #expect(hash != nil, "Hash should not be nil")
        #expect(hash?.count == precision * precision, "Hash length should be precision × precision")
    }

    /// Test dHash different images produce different hashes
    /// 测试 dHash 不同图片产生不同的哈希
    @Test("dHash should produce different hashes for different images")
    func dHashDifferentImagesTest() async throws {
        let image1 = createHalfPatternImage(inverted: false)
        let image2 = createHalfPatternImage(inverted: true)

        let hash1 = ImageHasher.computeHash(for: image1, type: .dHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image2, type: .dHash, precision: 8)

        #expect(hash1 != nil, "Hash1 should not be nil")
        #expect(hash2 != nil, "Hash2 should not be nil")
        #expect(hash1 != hash2, "Different images should produce different hashes")
    }

    // MARK: - aHash Tests

    /// Test aHash algorithm produces consistent results for identical images
    /// 测试 aHash 算法对相同图片产生一致的结果
    @Test("aHash should produce identical hashes for identical images")
    func aHashConsistencyTest() async throws {
        let image = createTestImage(color: .green)

        let hash1 = ImageHasher.computeHash(for: image, type: .aHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image, type: .aHash, precision: 8)

        #expect(hash1 != nil, "Hash should not be nil")
        #expect(hash1 == hash2, "Identical images should produce identical hashes")
    }

    /// Test aHash hash length matches expected precision
    /// 测试 aHash 哈希长度符合预期精度
    @Test("aHash hash length should match precision squared")
    func aHashLengthTest() async throws {
        let image = createTestImage(color: .yellow)
        let precision = 8

        let hash = ImageHasher.computeHash(for: image, type: .aHash, precision: precision)

        #expect(hash != nil, "Hash should not be nil")
        #expect(hash?.count == precision * precision, "Hash length should be precision × precision")
    }

    /// Test aHash different images produce different hashes
    /// 测试 aHash 不同图片产生不同的哈希
    @Test("aHash should produce different hashes for different images")
    func aHashDifferentImagesTest() async throws {
        let whiteImage = createTestImage(color: .white)
        let blackImage = createTestImage(color: .black)

        let whiteHash = ImageHasher.computeHash(for: whiteImage, type: .aHash, precision: 8)
        let blackHash = ImageHasher.computeHash(for: blackImage, type: .aHash, precision: 8)

        #expect(whiteHash != nil, "White hash should not be nil")
        #expect(blackHash != nil, "Black hash should not be nil")
        #expect(whiteHash != blackHash, "Different images should produce different hashes")
    }

    // MARK: - pHash Tests

    /// Test pHash algorithm produces consistent results for identical images
    /// 测试 pHash 算法对相同图片产生一致的结果
    @Test("pHash should produce identical hashes for identical images")
    func pHashConsistencyTest() async throws {
        let image = createGradientImage()

        let hash1 = ImageHasher.computeHash(for: image, type: .pHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image, type: .pHash, precision: 8)

        #expect(hash1 != nil, "Hash should not be nil")
        #expect(hash1 == hash2, "Identical images should produce identical hashes")
    }

    /// Test pHash hash length matches expected precision
    /// 测试 pHash 哈希长度符合预期精度
    @Test("pHash hash length should match precision squared")
    func pHashLengthTest() async throws {
        let image = createGradientImage()
        let precision = 8

        let hash = ImageHasher.computeHash(for: image, type: .pHash, precision: precision)

        #expect(hash != nil, "Hash should not be nil")
        #expect(hash?.count == precision * precision, "Hash length should be precision × precision")
    }

    /// Test pHash different images produce different hashes
    /// 测试 pHash 不同图片产生不同的哈希
    @Test("pHash should produce different hashes for different images")
    func pHashDifferentImagesTest() async throws {
        let image1 = createGradientImage()
        let image2 = createHalfPatternImage(inverted: false)

        let hash1 = ImageHasher.computeHash(for: image1, type: .pHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image2, type: .pHash, precision: 8)

        #expect(hash1 != nil, "Hash1 should not be nil")
        #expect(hash2 != nil, "Hash2 should not be nil")
        #expect(hash1 != hash2, "Different images should produce different hashes")
    }

    // MARK: - Hamming Distance Tests

    /// Test Hamming distance for identical hashes
    /// 测试相同哈希的汉明距离
    @Test("Hamming distance should be zero for identical hashes")
    func hammingDistanceIdenticalTest() async throws {
        let hash = "1100101010110011"
        let distance = ImageHasher.hammingDistance(between: hash, and: hash)

        #expect(distance == 0, "Identical hashes should have zero distance")
    }

    /// Test Hamming distance for completely different hashes
    /// 测试完全不同哈希的汉明距离
    @Test("Hamming distance should equal length for completely different hashes")
    func hammingDistanceCompletelyDifferentTest() async throws {
        let hash1 = "00000000"
        let hash2 = "11111111"
        let distance = ImageHasher.hammingDistance(between: hash1, and: hash2)

        #expect(distance == 8, "Completely different hashes should have max distance")
    }

    /// Test Hamming distance for partially different hashes
    /// 测试部分不同哈希的汉明距离
    @Test("Hamming distance should count differing bits correctly")
    func hammingDistancePartialDifferenceTest() async throws {
        let hash1 = "11110000"
        let hash2 = "11001100"
        let distance = ImageHasher.hammingDistance(between: hash1, and: hash2)

        // Positions 2,3,6,7 are different (4 positions)
        // 位置 2,3,6,7 不同（共 4 个位置）
        #expect(distance == 4, "Should count 4 differing bits")
    }

    /// Test Hamming distance for different length hashes
    /// 测试不同长度哈希的汉明距离
    @Test("Hamming distance should handle different length hashes")
    func hammingDistanceDifferentLengthsTest() async throws {
        let hash1 = "11110000"
        let hash2 = "1111000000"
        let distance = ImageHasher.hammingDistance(between: hash1, and: hash2)

        // Should return max length when lengths differ
        // 长度不同时应返回最大长度
        #expect(distance == max(hash1.count, hash2.count), "Should return max length for different lengths")
    }

    /// Test Hamming distance for similar images
    /// 测试相似图片的汉明距离
    @Test("Similar images should have small Hamming distance")
    func hammingDistanceSimilarImagesTest() async throws {
        // Use gradient images - one normal, one slightly shifted
        // 使用渐变图片 - 一个正常，一个稍微偏移
        let image1 = createGradientImage()

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 1.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            throw TestError.imageCreationFailed
        }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0]) else {
            throw TestError.imageCreationFailed
        }

        let size = CGSize(width: 100, height: 100)
        // Slightly different gradient direction
        // 稍微不同的渐变方向
        context.drawLinearGradient(gradient, start: CGPoint(x: 10, y: 0), end: CGPoint(x: size.width - 10, y: size.height), options: [])

        guard let image2 = UIGraphicsGetImageFromCurrentImageContext() else {
            throw TestError.imageCreationFailed
        }

        let hash1 = ImageHasher.computeHash(for: image1, type: .aHash, precision: 8)
        let hash2 = ImageHasher.computeHash(for: image2, type: .aHash, precision: 8)

        #expect(hash1 != nil, "Hash1 should not be nil")
        #expect(hash2 != nil, "Hash2 should not be nil")

        let distance = ImageHasher.hammingDistance(between: hash1!, and: hash2!)

        // Similar gradients should have small distance (less than 30% different)
        // 相似的渐变应该有较小的距离（差异小于 30%）
        let maxDistance = Int(Double(8 * 8) * 0.3)
        #expect(distance < maxDistance, "Similar images should have small Hamming distance")
    }

    // MARK: - Cross-Algorithm Tests

    /// Test different algorithms produce different hashes for same image
    /// 测试不同算法对同一图片产生不同的哈希
    @Test("Different algorithms should produce different hashes for same image")
    func crossAlgorithmTest() async throws {
        let image = createGradientImage()

        let dHash = ImageHasher.computeHash(for: image, type: .dHash, precision: 8)
        let aHash = ImageHasher.computeHash(for: image, type: .aHash, precision: 8)
        let pHash = ImageHasher.computeHash(for: image, type: .pHash, precision: 8)

        #expect(dHash != nil, "dHash should not be nil")
        #expect(aHash != nil, "aHash should not be nil")
        #expect(pHash != nil, "pHash should not be nil")

        // Each algorithm should produce different hash
        // 每个算法应该产生不同的哈希
        #expect(dHash != aHash, "dHash and aHash should be different")
        #expect(aHash != pHash, "aHash and pHash should be different")
        #expect(dHash != pHash, "dHash and pHash should be different")
    }

    // MARK: - Precision Tests

    /// Test different precision levels produce correct hash lengths
    /// 测试不同精度级别产生正确的哈希长度
    @Test("Hash length should scale with precision")
    func precisionScalingTest() async throws {
        let image = createTestImage(color: .purple)

        for precision in [4, 8, 16, 32] {
            let hash = ImageHasher.computeHash(for: image, type: .dHash, precision: precision)

            #expect(hash != nil, "Hash should not be nil for precision \(precision)")
            #expect(hash?.count == precision * precision, "Hash length should match precision squared for precision \(precision)")
        }
    }

    // MARK: - Edge Cases Tests

    /// Test hash contains only binary characters
    /// 测试哈希只包含二进制字符
    @Test("Hash should contain only 0 and 1 characters")
    func hashBinaryCharactersTest() async throws {
        let image = createTestImage(color: .cyan)
        let hash = ImageHasher.computeHash(for: image, type: .aHash, precision: 8)

        #expect(hash != nil, "Hash should not be nil")

        let validChars = Set("01")
        let isValid = hash!.allSatisfy { validChars.contains($0) }

        #expect(isValid, "Hash should contain only 0 and 1 characters")
    }

    /// Test all three algorithms on same image produce valid hashes
    /// 测试所有三种算法在同一图片上产生有效哈希
    @Test("All algorithms should produce valid hashes for any image")
    func allAlgorithmsValidityTest() async throws {
        let image = createGradientImage()

        let dHash = ImageHasher.computeHash(for: image, type: .dHash, precision: 8)
        let aHash = ImageHasher.computeHash(for: image, type: .aHash, precision: 8)
        let pHash = ImageHasher.computeHash(for: image, type: .pHash, precision: 8)

        #expect(dHash != nil, "dHash should succeed")
        #expect(aHash != nil, "aHash should succeed")
        #expect(pHash != nil, "pHash should succeed")

        // All should be 64 characters for precision 8
        // 精度 8 时都应该是 64 个字符
        #expect(dHash?.count == 64, "dHash should be 64 characters")
        #expect(aHash?.count == 64, "aHash should be 64 characters")
        #expect(pHash?.count == 64, "pHash should be 64 characters")
    }
}

#endif
