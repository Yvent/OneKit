//
//  PHAssetView.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import Foundation
import SwiftUI
import Photos
import OneKitCore

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

public struct PHAssetView: View {
    public var asset: PHAsset
    public var cache: CachedImageManager?
    public var imageSize: CGSize

    @State private var image: Image?
    @State private var imageRequestID: PHImageRequestID?

    public init(asset: PHAsset, cache: CachedImageManager? = nil, imageSize: CGSize) {
        self.asset = asset
        self.cache = cache
        self.imageSize = imageSize
    }

    public var body: some View {

        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .task {
            guard image == nil, let cache = cache else { return }
            imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                Task {
                    if let result = result {
                        self.image = result.image
                    }
                }
            }
        }
    }
}

#endif