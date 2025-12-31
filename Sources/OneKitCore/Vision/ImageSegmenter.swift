//
//  ImageSegmenter.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

/// Image segmentation using Vision framework
/// Vision 框架图像分割
open class ImageSegmenter: @unchecked Sendable {
    
    let context: CIContext
    
    let requestHandler: VNSequenceRequestHandler
    
    let humanRectanglesRequest: VNDetectHumanRectanglesRequest

    let segmentationRequest: VNGeneratePersonSegmentationRequest

    /// The default segmenter.
    /// 默认分割器
    nonisolated(unsafe) public static let `default` = ImageSegmenter()
    
    public init() {
        self.context = CIContext()
        self.requestHandler = VNSequenceRequestHandler()
        self.humanRectanglesRequest = VNDetectHumanRectanglesRequest()
        self.segmentationRequest = VNGeneratePersonSegmentationRequest()
        
        
        humanRectanglesRequest.revision = VNDetectHumanRectanglesRequestRevision2
        humanRectanglesRequest.upperBodyOnly = true
        
        segmentationRequest.qualityLevel = .balanced
        segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
    }
    
    /// Check if someone
    open func checkHum(_ image: CIImage) -> Bool {
        try? requestHandler.perform([humanRectanglesRequest], on: image, orientation: .up)
        let humanCount = humanRectanglesRequest.results?.count ?? 0
        return humanCount > 0
    }
    
    /// segmentat image
    open func segmentatToImage(_ image: CIImage, backgroundImage: CIImage? = nil) -> CIImage? {

        guard self.checkHum(image) == true else { return nil }
        try? requestHandler.perform([segmentationRequest], on: image, orientation: .up)
        
        guard let maskPixelBuffer =
                segmentationRequest.results?.first?.pixelBuffer else { return nil }
        
        // Process the images.
        return blendImage(original: image, mask: maskPixelBuffer, backgroundImage: backgroundImage)
    }
    
    /// blend image
    open func blendImage(original image: CIImage,
                         mask: CVPixelBuffer,
                         backgroundImage: CIImage?) -> CIImage? {


        // Create CIImage objects for the video frame and the segmentation mask.
        let originalImage = image.oriented(.up)
        var maskImage = CIImage(cvPixelBuffer: mask)

        // Scale the mask image to fit the bounds of the video frame.
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: __CGAffineTransformMake(scaleX, 0, 0, scaleY, 0, 0))

        maskImage = maskImage.transformed(by: CGAffineTransform(translationX: originalImage.extent.origin.x, y: originalImage.extent.origin.y))

        // Blend the original, background, and mask images.
        guard let blendFilter = CIFilter(name:"CIBlendWithRedMask") else { return nil }
        
        blendFilter.setValue(originalImage, forKey: kCIInputImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)
        blendFilter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)

        return blendFilter.outputImage?.oriented(.up)
    }
}

#endif
