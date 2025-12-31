//
//  ImageSaver.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import Foundation
import Photos

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

/// Errors that can occur when saving images
/// 保存图片时可能出现的错误
public enum ImageSaverError: LocalizedError {
    /// Permission denied to access photo library
    /// 相册访问权限被拒绝
    case permissionDenied

    /// Invalid image data
    /// 无效的图片数据
    case invalidImageData

    /// Save operation failed
    /// 保存操作失败
    case saveFailed(Error?)

    /// Custom error message
    /// 自定义错误信息
    case custom(String)

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission to access photo library was denied. / 相册访问权限被拒绝。"
        case .invalidImageData:
            return "Invalid image data. / 无效的图片数据。"
        case .saveFailed(let error):
            if let error = error {
                return "Failed to save image: \(error.localizedDescription)"
            }
            return "Failed to save image. / 保存图片失败。"
        case .custom(let message):
            return message
        }
    }
}

/// Image saver for saving images to photo library
/// 图片保存器，用于保存图片到相册
public actor ImageSaver {

    // MARK: - Check Authorization

    /// Check authorization status for photo library
    /// 检查相册访问权限状态
    public func checkAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }

    /// Request authorization for photo library
    /// 请求相册访问权限
    public func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }

    // MARK: - Save UIImage (Callback)

    /// Save UIImage to photo library (callback version)
    /// 保存 UIImage 到相册（回调版本）
    ///
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - albumName: Optional album name to save to
    ///   - completion: Result callback with PHAsset or error
    public func save(
        _ image: UIImage,
        toAlbum albumName: String? = nil,
        completion: @escaping @Sendable @MainActor (Result<PHAsset, ImageSaverError>) -> Void
    ) {
        Task {
            // Check authorization
            let status = checkAuthorizationStatus()
            guard status == .authorized || status == .limited else {
                await MainActor.run {
                    completion(.failure(.permissionDenied))
                }
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                await MainActor.run {
                    completion(.failure(.invalidImageData))
                }
                return
            }

            // Perform save
            await performSave(imageData: imageData, toAlbum: albumName, completion: completion)
        }
    }

    // MARK: - Save CIImage (Callback)

    /// Save CIImage to photo library (callback version)
    /// 保存 CIImage 到相册（回调版本）
    ///
    /// - Parameters:
    ///   - image: The CIImage to save
    ///   - albumName: Optional album name to save to
    ///   - completion: Result callback with PHAsset or error
    public func save(
        _ image: CIImage,
        toAlbum albumName: String? = nil,
        completion: @escaping @Sendable @MainActor (Result<PHAsset, ImageSaverError>) -> Void
    ) {
        // Convert CIImage to UIImage
        let uiImage = UIImage(ciImage: image)
        save(uiImage, toAlbum: albumName, completion: completion)
    }

    // MARK: - Save Image Data (Callback)

    /// Save image data to photo library (callback version)
    /// 保存图片数据到相册（回调版本）
    ///
    /// - Parameters:
    ///   - imageData: The image data to save
    ///   - albumName: Optional album name to save to
    ///   - completion: Result callback with PHAsset or error
    public func save(
        _ imageData: Data,
        toAlbum albumName: String? = nil,
        completion: @escaping @Sendable @MainActor (Result<PHAsset, ImageSaverError>) -> Void
    ) {
        Task {
            // Check authorization
            let status = checkAuthorizationStatus()
            guard status == .authorized || status == .limited else {
                await MainActor.run {
                    completion(.failure(.permissionDenied))
                }
                return
            }

            // Perform save
            await performSave(imageData: imageData, toAlbum: albumName, completion: completion)
        }
    }

    // MARK: - Save UIImage (Async/Await)

    /// Save UIImage to photo library (async version)
    /// 保存 UIImage 到相册（异步版本）
    ///
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - albumName: Optional album name to save to
    /// - Returns: PHAsset of saved image
    /// - Throws: ImageSaverError if save fails
    @discardableResult
    public func save(_ image: UIImage, toAlbum albumName: String? = nil) async throws -> PHAsset {
        // Check authorization
        let status = checkAuthorizationStatus()
        guard status == .authorized || status == .limited else {
            throw ImageSaverError.permissionDenied
        }

        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw ImageSaverError.invalidImageData
        }

        return try await performSave(imageData: imageData, toAlbum: albumName)
    }

    // MARK: - Save CIImage (Async/Await)

    /// Save CIImage to photo library (async version)
    /// 保存 CIImage 到相册（异步版本）
    ///
    /// - Parameters:
    ///   - image: The CIImage to save
    ///   - albumName: Optional album name to save to
    /// - Returns: PHAsset of saved image
    /// - Throws: ImageSaverError if save fails
    @discardableResult
    public func save(_ image: CIImage, toAlbum albumName: String? = nil) async throws -> PHAsset {
        // Convert CIImage to UIImage
        let uiImage = UIImage(ciImage: image)
        return try await save(uiImage, toAlbum: albumName)
    }

    // MARK: - Private Helper Methods

    private func performSave(
        imageData: Data,
        toAlbum albumName: String?,
        completion: @escaping @Sendable @MainActor (Result<PHAsset, ImageSaverError>) -> Void
    ) async {
        do {
            let asset = try await performSave(imageData: imageData, toAlbum: albumName)
            await MainActor.run {
                completion(.success(asset))
            }
        } catch {
            await MainActor.run {
                if let error = error as? ImageSaverError {
                    completion(.failure(error))
                } else {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }

    private func performSave(imageData: Data, toAlbum albumName: String?) async throws -> PHAsset {
        // Convert Data to UIImage
        guard let image = UIImage(data: imageData) else {
            throw ImageSaverError.invalidImageData
        }

        return try await performSave(image: image, toAlbum: albumName)
    }

    private func performSave(image: UIImage, toAlbum albumName: String?) async throws -> PHAsset {
        if let albumName = albumName {
            // Save to specific album
            return try await saveToAlbum(image: image, albumName: albumName)
        } else {
            // Save to camera roll
            return try await saveToCameraRoll(image: image)
        }
    }

    private func saveToCameraRoll(image: UIImage) async throws -> PHAsset {
        try await withCheckedThrowingContinuation { continuation in
            var savedAsset: PHAsset?

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAsset = request.placeholderForCreatedAsset
            } completionHandler: { success, error in
                if success, let asset = savedAsset?.placeholderForCreatedAsset {
                    continuation.resume(returning: asset)
                } else {
                    continuation.resume(throwing: ImageSaverError.saveFailed(error))
                }
            }
        }
    }

    private func saveToAlbum(image: UIImage, albumName: String) async throws -> PHAsset {
        // First, try to find the album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHCollectionList.fetchTopLevelUserCollections(with: fetchOptions)

        if let album = collections.firstObject as? PHAssetCollection {
            // Album exists, add to it
            return try await addImageToAlbum(image: image, album: album)
        } else {
            // Album doesn't exist, create it first
            return try await createAlbumAndAddImage(image: image, albumName: albumName)
        }
    }

    private func addImageToAlbum(image: UIImage, album: PHAssetCollection) async throws -> PHAsset {
        try await withCheckedThrowingContinuation { continuation in
            var savedAsset: PHAsset?

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                request.addAssetsToCollection(album)
                savedAsset = request.placeholderForCreatedAsset
            } completionHandler: { success, error in
                if success, let asset = savedAsset?.placeholderForCreatedAsset {
                    continuation.resume(returning: asset)
                } else {
                    continuation.resume(throwing: ImageSaverError.saveFailed(error))
                }
            }
        }
    }

    private func createAlbumAndAddImage(image: UIImage, albumName: String) async throws -> PHAsset {
        // First, create the album
        let album = try await createAlbum(albumName: albumName)

        // Then, add image to the newly created album
        return try await addImageToAlbum(image: image, album: album)
    }

    private func createAlbum(albumName: String) async throws -> PHAssetCollection {
        var placeholder: PHObjectPlaceholder?

        // Step 1: Create the album
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let albumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                placeholder = albumRequest.placeholderForCreatedAssetCollection
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ImageSaverError.saveFailed(error))
                }
            }
        }

        // Step 2: Fetch the created album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHCollectionList.fetchTopLevelUserCollections(with: fetchOptions)

        guard let album = collections.firstObject as? PHAssetCollection else {
            throw ImageSaverError.custom("Failed to fetch created album")
        }

        return album
    }
}

#endif
