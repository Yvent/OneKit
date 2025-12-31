//
//  TextRecognizer.swift
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

/// Text recognition using Vision framework
/// Vision 框架文字识别
open class TextRecognizer: @unchecked Sendable {
        
    var results: [VNRecognizedTextObservation]?
    
    var requestHandler: VNImageRequestHandler?
    
    var textRecognitionRequest: VNRecognizeTextRequest
    
    var resultBack: ((String) -> Void)?

    /// The default recognizer.
    /// 默认识别器
    nonisolated(unsafe) public static let `default` = TextRecognizer()
    
    public init() {
        self.textRecognitionRequest = VNRecognizeTextRequest()
    }

    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in

            self.results = self.textRecognitionRequest.results

            guard let results = self.results else { return }
            var textStr: String = ""
            for result in results {
                let candidate: VNRecognizedText = result.topCandidates(1)[0]
                textStr +=  candidate.string + "\n"
            }

            self.resultBack?(textStr)

        }
    }

    func imageDidChange(toImage image: UIImage?, resultBack: ((String) -> Void)?) {
        self.textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        self.resultBack = resultBack
        guard let newImage = image else { return  }
        guard let cgImage = newImage.cgImage else { return  }
        // Create the request handler.
        requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Perform the request.
        textRecognitionRequest.cancel()
        updateRequestParameters()
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            do {
                try self.requestHandler?.perform([self.textRecognitionRequest])
            } catch _ {}
        }
    }
    
    func updateRequestParameters() {
        
        textRecognitionRequest.recognitionLevel = .accurate
        
        // Update the minimum text height.
        textRecognitionRequest.minimumTextHeight = 0
        
        // Update the language-based correction.
        textRecognitionRequest.usesLanguageCorrection = true
        
        textRecognitionRequest.customWords = []
        
        // Update the CPU-only flag.
        textRecognitionRequest.usesCPUOnly = false
        
        // Set the request revision.
        textRecognitionRequest.revision = Int(2)
        
        // Set the primary language.
        textRecognitionRequest.recognitionLanguages = ["zh-Hans"]

    }
}

#endif

