//
//  UIImage+Extensions.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/30.
//

#if canImport(UIKit)
import UIKit
import ImageIO

// MARK: - Basic Image Processing

extension UIImage {

    /// Converts image to raw byte array
    /// 将图片转换为字节数组
    ///
    /// - Returns: Array of UInt8 representing the image data
    func toByteArray() -> [UInt8] {
        guard let imageRef = cgImage,
              let dataProvider = imageRef.dataProvider,
              let cfData = dataProvider.data else {
            return []
        }

        let length = CFDataGetLength(cfData)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(cfData, CFRange(location: 0, length: length), &rawData)

        return rawData
    }
    
    
    /// 预处理：缩放到指定宽高并转灰度 (供 ImageHasher 使用)
    func preprocessForHashing(width: Int, height: Int) -> UIImage? {
        guard let scaled = self.scaleToSize(size: CGSize(width: width, height: height)) else {
            return nil
        }
        return scaled.getGrayImage()
    }
    
    ///第一步，缩小尺寸。
    //1.缩小图片8*8
    func scaleToSize(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func getGrayImage() -> UIImage? {
        guard let imageRef = self.cgImage else {return nil}
        let width: Int = imageRef.width
        let height: Int = imageRef.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {return nil}
        
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: width, height: height)
        
        context.draw(imageRef, in: rect)

        
        guard let outPutImage = context.makeImage() else {return nil}
        
        let newImage: UIImage = UIImage.init(cgImage: outPutImage)
        
        return newImage
    }
}

// MARK: - Image Transformation

extension UIImage {

    /// Scales image to specified size
    /// 缩放图片到指定尺寸
    ///
    /// - Parameter size: Target size / 目标尺寸
    /// - Returns: Scaled image, or nil if failed / 缩放后的图片，失败返回 nil
    func scaled(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Converts image to grayscale
    /// 转换图片为灰度图
    ///
    /// - Returns: Grayscale image, or nil if failed / 灰度图，失败返回 nil
    func grayscaled() -> UIImage? {
        guard let imageRef = cgImage else { return nil }

        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(imageRef, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        guard let outputImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: outputImage)
    }

    /// Crops image to specified rectangle
    /// 裁剪图片到指定矩形区域
    ///
    /// - Parameter rect: Rectangle to crop to / 裁剪矩形
    /// - Returns: Cropped image, or nil if failed / 裁剪后的图片，失败返回 nil
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: croppedCGImage)
    }
}

// MARK: - Advanced Image Processing

extension UIImage {

    /// Asynchronously draws image with optional background color and corner radius
    /// 异步绘制图像，支持背景颜色和圆角
    ///
    /// - Parameters:
    ///   - rect: Target rectangle / 目标矩形
    ///   - cornerRadius: Corner radius (default: 0) / 圆角半径
    ///   - backgroundColor: Optional background color (default: nil) / 可选背景颜色
    ///   - completion: Completion handler called on main thread with result image / 在主线程调用的完成回调
    func asyncDraw(
        in rect: CGRect,
        cornerRadius: CGFloat = 0,
        backgroundColor: UIColor? = nil,
        completion: @escaping (UIImage?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIGraphicsBeginImageContextWithOptions(rect.size, backgroundColor != nil, 1.0)
            defer { UIGraphicsEndImageContext() }

            // Fill background if specified
            // 如果指定了背景色则填充
            if let backgroundColor = backgroundColor {
                backgroundColor.setFill()
                UIRectFill(rect)
            }

            // Apply corner clipping if specified
            // 如果指定了圆角则应用裁切
            if cornerRadius > 0 {
                let path = UIBezierPath(
                    roundedRect: rect,
                    cornerRadius: cornerRadius
                )
                path.addClip()
            }

            // Draw image
            // 绘制图像
            self.draw(in: rect)

            let result = UIGraphicsGetImageFromCurrentImageContext()

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Downsamples image from URL to fit within specified size
    /// 从 URL 降采样图片以适应指定尺寸
    ///
    /// This is memory-efficient for large images
    /// 这对大图片来说是内存高效的
    ///
    /// - Parameters:
    ///   - url: Image file URL / 图片文件 URL
    ///   - size: Target size in points / 目标尺寸（点）
    ///   - scale: Scale factor (default: 1.0) / 缩放因子
    ///
    /// - Returns: Downsampled image, or nil if failed / 降采样后的图片，失败返回 nil
    static func downsample(
        from url: URL,
        to size: CGSize,
        scale: CGFloat = 1.0
    ) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, options as CFDictionary) else {
            return nil
        }

        let maxDimension = max(size.width, size.height) * scale
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource,
            0,
            downsampleOptions as CFDictionary
        ) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}

#endif
