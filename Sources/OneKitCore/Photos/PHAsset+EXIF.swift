//
//  PHAsset+EXIF.swift
//  OneKit
//
//  Created by zyw on 2025/12/30.
//

import Photos
import ImageIO

import Foundation

/// Errors that can occur when reading EXIF metadata
/// 读取 EXIF 元数据过程中可能出现的错误
public enum ExifError: Error {

    /// Original image URL not found
    /// 无法获取原始图片文件 URL
    case noImageURL

    /// Failed to read metadata from image source
    /// 无法从图片中读取元数据
    case metadataUnavailable
}

public extension PHAsset {

    // MARK: - Completion API (Source of Truth)

    /// Fetch full EXIF metadata from original image file
    /// 从原始图片文件读取完整 EXIF（回调版本，主实现）
    func fetchFullExif(
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {

        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true

        requestContentEditingInput(with: options) { input, _ in

            guard let url = input?.fullSizeImageURL else {
                completion(.failure(ExifError.noImageURL))
                return
            }

            guard
                let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
            else {
                completion(.failure(ExifError.metadataUnavailable))
                return
            }

            completion(.success(properties))
        }
    }

    // MARK: - Async/Await API

    /// Fetch full EXIF metadata from original image file
    /// 从原始图片文件读取完整 EXIF（异步版本）
    @available(iOS 15.0, macOS 12.0, *)
    func fetchFullExif() async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true

            requestContentEditingInput(with: options) { input, _ in
                guard let url = input?.fullSizeImageURL else {
                    continuation.resume(throwing: ExifError.noImageURL)
                    return
                }

                guard
                    let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
                else {
                    continuation.resume(throwing: ExifError.metadataUnavailable)
                    return
                }

                continuation.resume(returning: properties)
            }
        }
    }
}
