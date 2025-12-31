//
//  CachedImageManager.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import Photos
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

public actor CachedImageManager {

    private let imageManager = PHCachingImageManager()

    public var imageContentMode = PHImageContentMode.aspectFit

    public enum CachedImageManagerError: LocalizedError {
        case error(Error)
        case cancelled
        case failed
    }

    private var cachedAssetIdentifiers = [String : Bool]()

    public lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        return options
    }()

    public init() {
        imageManager.allowsCachingHighQualityImages = false
    }

    public var cachedImageCount: Int {
        cachedAssetIdentifiers.keys.count
    }

    public func startCaching(for assets: [PHAsset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0 }
        phAssets.forEach {
            cachedAssetIdentifiers[$0.localIdentifier] = true
        }
        imageManager.startCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }

    public func stopCaching(for assets: [PHAsset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0 }
        phAssets.forEach {
            cachedAssetIdentifiers.removeValue(forKey: $0.localIdentifier)
        }
        imageManager.stopCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }

    public func stopCaching() {
        imageManager.stopCachingImagesForAllAssets()
    }

    @discardableResult
    public func requestImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping @Sendable ((image: Image?, isLowerQuality: Bool)?) -> Void) -> PHImageRequestID? {
        let phAsset = asset

        let requestID = imageManager.requestImage(for: phAsset, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions) { image, info in
            if let error = info?[PHImageErrorKey] as? Error {
                completion(nil)
            } else if let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue, cancelled {
                completion(nil)
            } else if let image = image {
                let isLowerQualityImage = (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
                let result = (image: Image(uiImage: image), isLowerQuality: isLowerQualityImage)
                completion(result)
            } else {
                completion(nil)
            }
        }
        return requestID
    }

    public func cancelImageRequest(for requestID: PHImageRequestID) {
        imageManager.cancelImageRequest(requestID)
    }
}

#endif
