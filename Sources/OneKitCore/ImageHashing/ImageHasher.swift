//
//  ImageHasher.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/30.
//

#if canImport(UIKit)
import UIKit
import Accelerate

/// Image fingerprint/hash calculator
/// 图片指纹/哈希计算器
///
/// Provides three common perceptual hashing algorithms for image similarity detection:
/// - **dHash**: Difference Hash - Compares adjacent pixels (fastest)
/// - **aHash**: Average Hash - Compares each pixel to average
/// - **pHash**: Perceptual Hash - Uses DCT transform (most accurate)
///
/// 提供三种常用的感知哈希算法用于图片相似度检测：
/// - **dHash**: 差异哈希 - 比较相邻像素（最快）
/// - **aHash**: 平均哈希 - 比较每个像素与平均值
/// - **pHash**: 感知哈希 - 使用 DCT 变换（最准确）
struct ImageHasher {

    // MARK: - Types

    /// Hash algorithm type
    /// 哈希算法类型
    enum HashType {
        /// Difference Hash - Compare adjacent pixels
        /// 差异哈希 - 比较相邻像素
        case dHash

        /// Average Hash - Compare to average
        /// 平均哈希 - 与平均值比较
        case aHash

        /// Perceptual Hash - Using DCT transform
        /// 感知哈希 - 使用 DCT 变换
        case pHash
    }

    // MARK: - Public API

    /// Computes hash string for an image
    /// 计算图片的哈希字符串
    ///
    /// - Parameters:
    ///   - image: Input image / 输入图片
    ///   - type: Algorithm type (default: dHash) / 算法类型
    ///   - precision: Hash precision, determines bits = precision × precision / 精度，决定哈希位数
    ///
    /// - Returns: Binary hash string, or nil if processing fails / 二进制哈希字符串，失败返回 nil
    static func computeHash(for image: UIImage, type: HashType = .dHash, precision: Int) -> String? {
        switch type {
        case .dHash:
            // dHash: Scale to (precision+1) × precision, compare adjacent pixels
            // dHash: 缩放到 (precision+1) × precision，比较相邻像素
            guard let processedImage = image.preprocessForHashing(width: precision + 1, height: precision) else {
                return nil
            }
            return computeDHash(image: processedImage, precision: precision)

        case .aHash:
            // aHash: Scale to precision × precision, compare to average
            // aHash: 缩放到 precision × precision，与平均值比较
            guard let processedImage = image.preprocessForHashing(width: precision, height: precision) else {
                return nil
            }
            return computeAHash(image: processedImage)

        case .pHash:
            // pHash: Use DCT transform, scale to 32×32, extract precision×precision low-frequency
            // pHash: 使用 DCT 变换，缩放到 32×32，提取 precision×precision 低频部分
            guard let processedImage = image.preprocessForHashing(width: 32, height: 32) else {
                return nil
            }
            return computePHash(image: processedImage, precision: precision)
        }
    }

    // MARK: - Utility Methods

    /// Calculates Hamming distance between two hash strings
    /// 计算两个哈希字符串的汉明距离（差异位数）
    ///
    /// Hamming distance is the number of positions at which the corresponding bits are different
    /// 汉明距离是相应位不同的位置数量
    ///
    /// - Parameters:
    ///   - hash1: First hash string / 第一个哈希字符串
    ///   - hash2: Second hash string / 第二个哈希字符串
    ///
    /// - Returns: Number of differing bits, or max count if lengths differ / 差异位数，长度不同返回最大值
    static func hammingDistance(between hash1: String, and hash2: String) -> Int {
        let s1 = Array(hash1)
        let s2 = Array(hash2)

        guard s1.count == s2.count else {
            // Lengths differ, unable to compare directly, return max difference
            // 长度不同，无法直接比较汉明距离，返回最大差异
            return max(s1.count, s2.count)
        }

        var diff: Int = 0
        for i in 0..<s1.count {
            if s1[i] != s2[i] {
                diff += 1
            }
        }
        return diff
    }

    // MARK: - Private Algorithm Implementations

    /// dHash: Compares grayscale difference between adjacent pixels
    /// dHash: 比较相邻像素的灰度差异
    ///
    /// Image size should be (precision+1) × precision, generates precision × precision bits
    /// 图片尺寸应为 (precision+1) × precision，生成 precision × precision 位哈希
    ///
    /// - Parameters:
    ///   - image: Grayscale image / 灰度图
    ///   - precision: Hash precision / 哈希精度
    ///
    /// - Returns: Binary hash string / 二进制哈希字符串
    private static func computeDHash(image: UIImage, precision: Int) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let width = imageRef.width   // Should be precision + 1
        let height = imageRef.height // Should be precision

        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var hashString = String()
        hashString.reserveCapacity(precision * precision)

        // Traverse each row, compare adjacent pixels
        // 遍历每行，比较相邻像素
        for row in 0..<height {
            for col in 0..<(width - 1) {
                let currentIndex = row * width + col
                let nextIndex = currentIndex + 1

                // Current pixel >= right neighbor = 1, else = 0
                // 当前像素 >= 右侧像素 = 1，否则 = 0
                if data[currentIndex] >= data[nextIndex] {
                    hashString.append("1")
                } else {
                    hashString.append("0")
                }
            }
        }

        return hashString
    }

    /// aHash (Average Hash): Compares each pixel to average grayscale
    /// aHash (平均哈希): 比较每个像素与平均灰度
    ///
    /// - Parameter image: Grayscale image / 灰度图
    /// - Returns: Binary hash string / 二进制哈希字符串
    private static func computeAHash(image: UIImage) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let width = imageRef.width
        let height = imageRef.height
        let pixelCount = width * height

        guard pixelCount > 0 else { return nil }
        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // Calculate average grayscale
        // 计算所有像素的平均灰度
        var sum: Int = 0
        for i in 0..<pixelCount {
            sum += Int(data[i])
        }
        let average = sum / pixelCount

        // Compare each pixel to average
        // 每个像素与平均值比较
        var hashString = String()
        hashString.reserveCapacity(pixelCount)

        for i in 0..<pixelCount {
            if Int(data[i]) > average {
                hashString.append("1")
            } else {
                hashString.append("0")
            }
        }

        return hashString
    }

    /// pHash (Perceptual Hash): Extracts low-frequency features using DCT transform
    /// pHash (感知哈希): 使用 DCT 变换提取低频特征
    ///
    /// Image should be 32×32 grayscale, generates precision×precision bits
    /// 图片应为 32×32 灰度图，生成 precision×precision 位哈希
    ///
    /// - Parameters:
    ///   - image: Grayscale image (should be 32×32) / 灰度图（应为 32×32）
    ///   - precision: Hash precision / 哈希精度
    ///
    /// - Returns: Binary hash string / 二进制哈希字符串
    private static func computePHash(image: UIImage, precision: Int) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let size = imageRef.width // Should be 32

        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // Convert pixel data to Float array
        // 将像素数据转为 Float 数组
        var floatPixels = [Float](repeating: 0, count: size * size)
        for i in 0..<(size * size) {
            floatPixels[i] = Float(data[i])
        }

        // Perform 2D DCT transform
        // 进行 2D DCT 变换
        guard let dctResult = perform2DDCT(input: floatPixels, size: size) else {
            return nil
        }

        // Extract precision×precision low-frequency part (excluding DC component [0][0])
        // 取左上角 precision×precision 的低频部分（排除 DC 分量 [0][0]）
        let hashSize = min(precision, size)
        var lowFreq = [Float]()
        lowFreq.reserveCapacity(hashSize * hashSize - 1)

        for row in 0..<hashSize {
            for col in 0..<hashSize {
                if row == 0 && col == 0 { continue } // Skip DC component / 跳过 DC 分量
                lowFreq.append(dctResult[row * size + col])
            }
        }

        // Calculate average
        // 计算平均值
        let sum = lowFreq.reduce(0, +)
        let average = sum / Float(lowFreq.count)

        // Compare to average and generate hash
        // 与平均值比较生成 hash
        var hashString = String()
        hashString.reserveCapacity(hashSize * hashSize)

        for row in 0..<hashSize {
            for col in 0..<hashSize {
                let value = dctResult[row * size + col]
                if value > average {
                    hashString.append("1")
                } else {
                    hashString.append("0")
                }
            }
        }

        return hashString
    }

    /// Performs 2D DCT transform using Accelerate framework
    /// 使用 Accelerate 框架执行 2D DCT 变换（优化）
    ///
    /// - Parameters:
    ///   - input: Input pixel array / 输入像素数组
    ///   - size: Matrix size (must be square) / 矩阵大小（必须是方形）
    ///
    /// - Returns: DCT result array / DCT 结果数组
    private static func perform2DDCT(input: [Float], size: Int) -> [Float]? {
        var result = [Float](repeating: 0, count: size * size)

        // Create DCT setup
        // 创建 DCT 设置
        guard let setup = vDSP_DCT_CreateSetup(nil, vDSP_Length(size), .II) else {
            return nil
        }
        defer { vDSP_DFT_DestroySetup(setup) }

        var tempRow = [Float](repeating: 0, count: size)
        var tempMatrix = [Float](repeating: 0, count: size * size)

        // Perform 1D DCT on each row
        // 对每一行进行 1D DCT
        for row in 0..<size {
            let rowStart = row * size
            for col in 0..<size {
                tempRow[col] = input[rowStart + col]
            }
            vDSP_DCT_Execute(setup, tempRow, &tempRow)
            for col in 0..<size {
                tempMatrix[rowStart + col] = tempRow[col]
            }
        }

        // Perform 1D DCT on each column
        // 对每一列进行 1D DCT
        for col in 0..<size {
            for row in 0..<size {
                tempRow[row] = tempMatrix[row * size + col]
            }
            vDSP_DCT_Execute(setup, tempRow, &tempRow)
            for row in 0..<size {
                result[row * size + col] = tempRow[row]
            }
        }

        return result
    }
}

#endif
