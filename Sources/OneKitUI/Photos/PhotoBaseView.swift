//
//  PhotoBaseView.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import SwiftUI
import Photos
import OneKitCore

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

/// Photo grid item view with selection support
/// 带选择支持的照片网格项视图
public struct PhotoBaseView: View {
    public let cache: CachedImageManager
    public let item: PHAsset
    public let isSelected: Bool
    public let toggleSelection: () -> Void

    // Configuration / 配置
    public var size: CGSize
    public var cornerRadius: CGFloat
    public var overlayColor: Color
    public var checkmarkSize: CGFloat
    public var checkmarkPadding: CGFloat

    public init(
        cache: CachedImageManager,
        item: PHAsset,
        size: CGSize = CGSize(width: 100, height: 100),
        isSelected: Bool = false,
        toggleSelection: @escaping () -> Void,
        cornerRadius: CGFloat = 8,
        overlayColor: Color = Color.blue.opacity(0.3),
        checkmarkSize: CGFloat = 24,
        checkmarkPadding: CGFloat = 8
    ) {
        self.cache = cache
        self.item = item
        self.size = size
        self.isSelected = isSelected
        self.toggleSelection = toggleSelection
        self.cornerRadius = cornerRadius
        self.overlayColor = overlayColor
        self.checkmarkSize = checkmarkSize
        self.checkmarkPadding = checkmarkPadding
    }

    public var body: some View {
        ZStack {
            // Image view
            PHAssetView(
                asset: item,
                cache: cache,
                imageSize: size
            )
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .cornerRadius(cornerRadius)
            .clipped()
            .onAppear {
                Task {
                    await cache.startCaching(for: [item], targetSize: size)
                }
            }
            .onDisappear {
                Task {
                    await cache.stopCaching(for: [item], targetSize: size)
                }
            }

            // Selection overlay
            if isSelected {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(overlayColor)
                    .frame(width: size.width, height: size.height)
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: toggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: checkmarkSize, height: checkmarkSize)
                            .foregroundColor(isSelected ? overlayColor : .white)
                            .background(
                                Circle()
                                    .fill(isSelected ? .white : Color.black.opacity(0.3))
                                    .frame(width: checkmarkSize + 2, height: checkmarkSize + 2)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(checkmarkPadding)
                }
                Spacer()
            }
        }
    }
}

#endif

#if canImport(UIKit)

#Preview("PhotoBaseView") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            // Not selected
            PhotoBaseView(
                cache: CachedImageManager(),
                item: PHAsset(), // Preview placeholder
                size: CGSize(width: 100, height: 100),
                isSelected: false,
                toggleSelection: {}
            )

            // Selected
            PhotoBaseView(
                cache: CachedImageManager(),
                item: PHAsset(),
                size: CGSize(width: 100, height: 100),
                isSelected: true,
                toggleSelection: {}
            )
        }

        // Customized
        PhotoBaseView(
            cache: CachedImageManager(),
            item: PHAsset(),
            size: CGSize(width: 80, height: 80),
            isSelected: true,
            toggleSelection: {},
            cornerRadius: 12,
            overlayColor: Color.red.opacity(0.3),
            checkmarkSize: 20,
            checkmarkPadding: 12
        )
    }
    .padding()
}

#endif
