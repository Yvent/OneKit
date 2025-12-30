//
//  ImageHasher.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/30.
//

import UIKit
import Accelerate

/// 图片指纹/哈希计算器
struct ImageHasher {

    enum HashType {
        case dHash // 差异哈希 (Difference Hash)
        case aHash // 平均哈希 (Average Hash)
        case pHash // 感知哈希 (Perceptual Hash，使用 DCT 变换)
    }

    /// 计算图片的 Hash 字符串
    /// - Parameters:
    ///   - image: 输入图片
    ///   - type: 算法类型 (默认 dHash)
    ///   - precision: 精度，决定 hash 的位数为 precision × precision
    static func computeHash(for image: UIImage, type: HashType = .dHash, precision: Int) -> String? {
        switch type {
        case .dHash:
            // dHash: 缩放到 (precision+1) × precision，比较后得到 precision × precision 位
            guard let processedImage = image.preprocessForHashing(width: precision + 1, height: precision) else {
                return nil
            }
            return computeDHash(image: processedImage, precision: precision)

        case .aHash:
            // aHash: 缩放到 precision × precision
            guard let processedImage = image.preprocessForHashing(width: precision, height: precision) else {
                return nil
            }
            return computeAHash(image: processedImage)

        case .pHash:
            // pHash: 使用 DCT 变换，固定缩放到 32×32，取 precision×precision 低频
            guard let processedImage = image.preprocessForHashing(width: 32, height: 32) else {
                return nil
            }
            return computePHash(image: processedImage, precision: precision)
        }
    }
    
    // MARK: - 私有算法实现

    /// dHash: 比较每行相邻像素的灰度差异
    /// 图片尺寸应为 (precision+1) × precision，生成 precision × precision 位 hash
    private static func computeDHash(image: UIImage, precision: Int) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let width = imageRef.width   // 应该是 precision + 1
        let height = imageRef.height // 应该是 precision

        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var hashString = String()
        hashString.reserveCapacity(precision * precision)

        // 遍历每行，比较相邻像素
        for row in 0..<height {
            for col in 0..<(width - 1) {
                let currentIndex = row * width + col
                let nextIndex = currentIndex + 1
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

    /// aHash (Average Hash): 比较每个像素与平均灰度
    private static func computeAHash(image: UIImage) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let width = imageRef.width
        let height = imageRef.height
        let pixelCount = width * height

        guard pixelCount > 0 else { return nil }
        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // 1. 计算所有像素的平均灰度
        var sum: Int = 0
        for i in 0..<pixelCount {
            sum += Int(data[i])
        }
        let average = sum / pixelCount

        // 2. 每个像素与平均值比较
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

    /// pHash (Perceptual Hash): 使用 DCT 变换提取低频特征
    /// 图片应为 32×32 灰度图，生成 precision×precision 位 hash
    private static func computePHash(image: UIImage, precision: Int) -> String? {
        guard let imageRef = image.cgImage else { return nil }
        let size = imageRef.width // 应该是 32

        guard let pixelData = imageRef.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // 1. 将像素数据转为 Float 数组
        var floatPixels = [Float](repeating: 0, count: size * size)
        for i in 0..<(size * size) {
            floatPixels[i] = Float(data[i])
        }

        // 2. 进行 2D DCT 变换
        guard let dctResult = perform2DDCT(input: floatPixels, size: size) else {
            return nil
        }

        // 3. 取左上角 precision×precision 的低频部分（排除 DC 分量 [0][0]）
        let hashSize = min(precision, size)
        var lowFreq = [Float]()
        lowFreq.reserveCapacity(hashSize * hashSize - 1)

        for row in 0..<hashSize {
            for col in 0..<hashSize {
                if row == 0 && col == 0 { continue } // 跳过 DC 分量
                lowFreq.append(dctResult[row * size + col])
            }
        }

        // 4. 计算平均值
        let sum = lowFreq.reduce(0, +)
        let average = sum / Float(lowFreq.count)

        // 5. 与平均值比较生成 hash
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

    /// 2D DCT 变换（使用 Accelerate 框架优化）
    private static func perform2DDCT(input: [Float], size: Int) -> [Float]? {
        var result = [Float](repeating: 0, count: size * size)

        // 创建 DCT 设置
        guard let setup = vDSP_DCT_CreateSetup(nil, vDSP_Length(size), .II) else {
            return nil
        }
        defer { vDSP_DFT_DestroySetup(setup) }

        var tempRow = [Float](repeating: 0, count: size)
        var tempMatrix = [Float](repeating: 0, count: size * size)

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
    
    // MARK: - 工具方法
    
    /// 计算两个 Hash 字符串的汉明距离 (差异位数)
    static func hammingDistance(between hash1: String, and hash2: String) -> Int {
        let s1 = Array(hash1)
        let s2 = Array(hash2)
        
        guard s1.count == s2.count else {
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
}
