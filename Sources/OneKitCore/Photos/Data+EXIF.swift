//
//  Data+EXIF.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import Foundation
import CoreImage
import ImageIO

/// Errors that can occur when reading EXIF metadata from Data
/// 从 Data 读取 EXIF 元数据过程中可能出现的错误
public enum DataExifError: Error {

    /// Failed to create image source from data
    /// 无法从数据创建图片源
    case invalidImageData

    /// Failed to read metadata from image source
    /// 无法从图片源读取元数据
    case metadataUnavailable
}

extension Data {

    // MARK: - Fetch Full EXIF (Source of Truth)

    /// Fetch full EXIF metadata from image data (callback version)
    /// 从图片数据中获取完整 EXIF 元数据（回调版本）
    ///
    /// Example:
    /// ```swift
    /// imageData.fetchFullExif { result in
    ///     switch result {
    ///     case .success(let properties):
    ///         print("EXIF: \(properties)")
    ///     case .failure(let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    /// - Parameter completion: Result callback with full metadata dictionary or error
    public func fetchFullExif(
        completion: @escaping @Sendable (Result<[String: Any], Error>) -> Void
    ) {
        // Execute on background queue for large images
        DispatchQueue.global(qos: .userInitiated).async {
            guard
                let source = CGImageSourceCreateWithData(self as CFData, nil),
                let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
            else {
                DispatchQueue.main.async {
                    completion(.failure(DataExifError.invalidImageData))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(properties))
            }
        }
    }

    // MARK: - Async/Await API

    /// Fetch full EXIF metadata from image data (async version)
    /// 从图片数据中获取完整 EXIF 元数据（异步版本）
    ///
    /// Example:
    /// ```swift
    /// let properties = try await imageData.fetchFullExif()
    /// print("EXIF: \(properties)")
    /// ```
    /// - Returns: Full metadata dictionary containing EXIF, GPS, TIFF, etc.
    /// - Throws: DataExifError if image data is invalid or metadata unavailable
    @available(iOS 13.0, macOS 10.15, *)
    public func fetchFullExif() async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            // Execute on background queue for large images
            DispatchQueue.global(qos: .userInitiated).async {
                guard
                    let source = CGImageSourceCreateWithData(self as CFData, nil),
                    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
                else {
                    continuation.resume(throwing: DataExifError.invalidImageData)
                    return
                }

                continuation.resume(returning: properties)
            }
        }
    }
}
