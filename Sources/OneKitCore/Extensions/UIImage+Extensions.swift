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

    /// Preprocesses image for hashing: scales to specified size and converts to grayscale
    /// 预处理图片用于哈希计算：缩放到指定尺寸并转为灰度图
    ///
    /// - Parameters:
    ///   - width: Target width / 目标宽度
    ///   - height: Target height / 目标高度
    ///
    /// - Returns: Processed grayscale image, or nil if failed / 处理后的灰度图，失败返回 nil
    func preprocessForHashing(width: Int, height: Int) -> UIImage? {
        guard let scaled = scaled(to: CGSize(width: width, height: height)) else {
            return nil
        }
        return scaled.grayscaled()
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

// MARK: - Resizing (保持宽高比)

extension UIImage {

    /// Resizes image to specified width while maintaining aspect ratio
    /// 调整图片到指定宽度（保持宽高比）
    ///
    /// - Parameter width: Target width / 目标宽度
    /// - Returns: Resized image, or nil if failed / 调整后的图片，失败返回 nil
    func resized(toWidth width: CGFloat) -> UIImage? {
        let scale = width / size.width
        let newHeight = size.height * scale
        return scaled(to: CGSize(width: width, height: newHeight))
    }

    /// Resizes image to specified height while maintaining aspect ratio
    /// 调整图片到指定高度（保持宽高比）
    ///
    /// - Parameter height: Target height / 目标高度
    /// - Returns: Resized image, or nil if failed / 调整后的图片，失败返回 nil
    func resized(toHeight height: CGFloat) -> UIImage? {
        let scale = height / size.height
        let newWidth = size.width * scale
        return scaled(to: CGSize(width: newWidth, height: height))
    }

    /// Resizes image to fit within specified size while maintaining aspect ratio
    /// 调整图片以适应指定尺寸（保持宽高比，完全包含在目标尺寸内）
    ///
    /// - Parameter size: Maximum size / 最大尺寸
    /// - Returns: Resized image, or nil if failed / 调整后的图片，失败返回 nil
    func resized(toFit size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let targetAspectRatio = size.width / size.height

        let newSize: CGSize
        if aspectRatio > targetAspectRatio {
            // Image is wider, fit to width
            // 图片更宽，适应宽度
            newSize = CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            // Image is taller, fit to height
            // 图片更高，适应高度
            newSize = CGSize(width: size.height * aspectRatio, height: size.height)
        }

        return scaled(to: newSize)
    }

    /// Resizes image to fill specified size while maintaining aspect ratio (may crop)
    /// 调整图片以填充指定尺寸（保持宽高比，可能会裁剪）
    ///
    /// - Parameter size: Target size / 目标尺寸
    /// - Returns: Resized and cropped image, or nil if failed / 调整并裁剪后的图片，失败返回 nil
    func resized(toFill size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let targetAspectRatio = size.width / size.height

        let newSize: CGSize
        if aspectRatio > targetAspectRatio {
            // Image is wider, fill height
            // 图片更宽，填充高度
            newSize = CGSize(width: size.height * aspectRatio, height: size.height)
        } else {
            // Image is taller, fill width
            // 图片更高，填充宽度
            newSize = CGSize(width: size.width, height: size.width / aspectRatio)
        }

        guard let resized = scaled(to: newSize) else {
            return nil
        }

        // Crop to center
        // 裁剪到中心
        let cropRect = CGRect(
            x: (newSize.width - size.width) / 2,
            y: (newSize.height - size.height) / 2,
            width: size.width,
            height: size.height
        )

        return resized.cropped(to: cropRect)
    }
}

// MARK: - Rotation

extension UIImage {

    /// Rotates image by specified degrees
    /// 旋转图片指定角度
    ///
    /// - Parameter degrees: Rotation in degrees (positive = clockwise) / 旋转角度（正数为顺时针）
    /// - Returns: Rotated image, or nil if failed / 旋转后的图片，失败返回 nil
    func rotated(by degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180.0
        return rotated(byRadians: radians)
    }

    /// Rotates image by specified radians
    /// 按弧度旋转图片
    ///
    /// - Parameter radians: Rotation in radians / 旋转弧度
    /// - Returns: Rotated image, or nil if failed / 旋转后的图片，失败返回 nil
    private func rotated(byRadians radians: CGFloat) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral

        UIGraphicsBeginImageContextWithOptions(rotatedSize.size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // Move origin to center
        // 将原点移到中心
        context.translateBy(x: rotatedSize.size.width / 2, y: rotatedSize.size.height / 2)
        context.rotate(by: radians)

        // Draw image centered
        // 绘制居中的图片
        draw(in: CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        ))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Rotates image 90 degrees clockwise
    /// 顺时针旋转90度
    ///
    /// - Returns: Rotated image, or nil if failed / 旋转后的图片，失败返回 nil
    func rotated90() -> UIImage? {
        return rotated(by: 90)
    }

    /// Rotates image 180 degrees
    /// 旋转180度
    ///
    /// - Returns: Rotated image, or nil if failed / 旋转后的图片，失败返回 nil
    func rotated180() -> UIImage? {
        return rotated(by: 180)
    }

    /// Rotates image 270 degrees clockwise (or 90 degrees counter-clockwise)
    /// 顺时针旋转270度（或逆时针90度）
    ///
    /// - Returns: Rotated image, or nil if failed / 旋转后的图片，失败返回 nil
    func rotated270() -> UIImage? {
        return rotated(by: 270)
    }
}

// MARK: - Rounded Corners & Circular

extension UIImage {

    /// Returns image with rounded corners
    /// 返回带圆角的图片
    ///
    /// - Parameter radius: Corner radius / 圆角半径
    /// - Returns: Image with rounded corners, or nil if failed / 带圆角的图片，失败返回 nil
    func withRoundedCorners(radius: CGFloat) -> UIImage? {
        return withRoundedCorners(radius: radius, corners: .allCorners)
    }

    /// Returns image with rounded corners for specified corners
    /// 返回指定角带圆角的图片
    ///
    /// - Parameters:
    ///   - radius: Corner radius / 圆角半径
    ///   - corners: Corners to round / 要圆角的角
    ///
    /// - Returns: Image with rounded corners, or nil if failed / 带圆角的图片，失败返回 nil
    func withRoundedCorners(radius: CGFloat, corners: UIRectCorner) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(origin: .zero, size: size)

        // Create rounded path
        // 创建圆角路径
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        // Add clipping
        // 添加裁切
        context.addPath(path.cgPath)
        context.clip()

        // Draw image
        // 绘制图片
        draw(in: rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Returns circular image (clips to circle)
    /// 返回圆形图片（裁剪为圆形）
    ///
    /// - Returns: Circular image, or nil if failed / 圆形图片，失败返回 nil
    func circular() -> UIImage? {
        let minDimension = min(size.width, size.height)

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: minDimension, height: minDimension),
            false,
            scale
        )
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(
            origin: .zero,
            size: CGSize(width: minDimension, height: minDimension)
        )

        // Create circular path
        // 创建圆形路径
        let path = UIBezierPath(ovalIn: rect)

        // Add clipping
        // 添加裁切
        context.addPath(path.cgPath)
        context.clip()

        // Draw image centered
        // 绘制居中的图片
        draw(in: CGRect(
            x: (minDimension - size.width) / 2,
            y: (minDimension - size.height) / 2,
            width: size.width,
            height: size.height
        ))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Returns image with border
    /// 返回带边框的图片
    ///
    /// - Parameters:
    ///   - width: Border width / 边框宽度
    ///   - color: Border color / 边框颜色
    ///
    /// - Returns: Image with border, or nil if failed / 带边框的图片，失败返回 nil
    func withBorder(width: CGFloat, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)

        // Draw original image
        // 绘制原始图片
        draw(in: rect)

        // Draw border
        // 绘制边框
        let borderPath = UIBezierPath(rect: rect)
        color.setStroke()
        borderPath.lineWidth = width
        borderPath.stroke()

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Compression & Format

extension UIImage {

    /// Compresses image to JPEG data
    /// 压缩图片为 JPEG 数据
    ///
    /// - Parameter quality: JPEG quality (0.0 - 1.0) / JPEG 质量
    /// - Returns: JPEG data, or nil if failed / JPEG 数据，失败返回 nil
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return jpegData(compressionQuality: quality)
    }

    /// Returns data with maximum size in bytes (iteratively compresses)
    /// 返回指定最大大小的数据（迭代压缩）
    ///
    /// - Parameter maxSize: Maximum size in bytes / 最大字节数
    /// - Returns: Compressed data, or nil if failed / 压缩后的数据，失败返回 nil
    func maxSize(_ maxSize: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSize && compression > 0.1 {
            compression -= 0.1
            imageData = jpegData(compressionQuality: compression)
        }

        return imageData
    }

    /// Converts image to PNG data
    /// 转换图片为 PNG 数据
    ///
    /// - Returns: PNG data, or nil if failed / PNG 数据，失败返回 nil
    func pngData() -> Data? {
        guard let cgImage = self.cgImage else { return nil }
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        return image.pngData()
    }
}

// MARK: - Color Effects

extension UIImage {

    /// Returns image with tint color applied
    /// 返回应用了颜色的图片
    ///
    /// - Parameters:
    ///   - tintColor: Color to apply / 要应用的颜色
    ///   - blendMode: Blend mode / 混合模式
    ///
    /// - Returns: Tinted image, or nil if failed / 着色后的图片，失败返回 nil
    func with(tintColor: UIColor, blendMode: CGBlendMode = .sourceIn) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // Draw image
        // 绘制图片
        draw(in: rect)

        // Apply tint color with blend mode
        // 使用混合模式应用颜色
        context.saveGState()
        tintColor.setFill()
        UIRectFillUsingBlendMode(rect, blendMode)
        context.restoreGState()

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Image Info

extension UIImage {

    /// Returns approximate size in bytes
    /// 返回近似字节数大小
    var sizeInBytes: Int {
        guard let cgImage = self.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }

    /// Returns aspect ratio (width / height)
    /// 返回宽高比
    var aspectRatio: CGFloat {
        guard size.height > 0 else { return 0 }
        return size.width / size.height
    }
}

// MARK: - Factory Methods

extension UIImage {

    /// Creates image from data
    /// 从数据创建图片
    ///
    /// - Parameter data: Image data / 图片数据
    /// - Returns: Image, or nil if failed / 图片，失败返回 nil
    static func from(data: Data) -> UIImage? {
        return UIImage(data: data)
    }

    /// Creates image from data with specified scale
    /// 从数据创建指定缩放的图片
    ///
    /// - Parameters:
    ///   - data: Image data / 图片数据
    ///   - scale: Image scale / 图片缩放
    ///
    /// - Returns: Image, or nil if failed / 图片，失败返回 nil
    static func from(data: Data, scale: CGFloat) -> UIImage? {
        return UIImage(data: data, scale: scale)
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
