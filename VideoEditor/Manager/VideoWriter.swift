//
//  VideoWriter.swift
//  test
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import AVFoundation
import UIKit

struct RenderSettings {
    var size: CGSize = CGSize(width: 600, height: 600)
    var fps: Int32 = 8
    var avCodecKey = AVVideoCodecType.h264
    var videoFilename = "render"
    var videoFilenameExt = "mp4"
    
    var outputURL: URL? {
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true) {
            return tmpDirURL
                .appendingPathComponent(videoFilename)
                .appendingPathExtension(videoFilenameExt)
        }
        print("URLForDirectory() failed")
        return nil
    }
}

final class VideoWriter {
    
    let renderSettings: RenderSettings
    
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    static func pixelBufferFromImage(image: UIImage,
                                     pixelBufferPool: CVPixelBufferPool,
                                     size: CGSize) -> CVPixelBuffer? {
        
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,
                                                        pixelBufferPool,
                                                        &pixelBufferOut)
        if status != kCVReturnSuccess {
            print("CVPixelBufferPoolCreatePixelBuffer() failed")
            return nil
        }
        
        guard let pixelBuffer = pixelBufferOut else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context?.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * aspectRatio,
                             height: image.size.height * aspectRatio)
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
        
        guard let cgImage = image.cgImage else {
            return nil
        }

        context?.draw(cgImage, in: CGRect(x: x, y: y,
                                          width: newSize.width, height: newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func start(completion: ((Result<Any?, Error>) -> Void)?) {
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
        ]
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter? {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
                completion?(.failure(VideoRenderingError.error))
                return nil
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                completion?(.failure(VideoRenderingError.error))
                return nil
            }
            
            return assetWriter
        }
        
        guard let outputURL = renderSettings.outputURL else {
            completion?(.failure(VideoRenderingError.error))
            return
        }
        
        videoWriter = createAssetWriter(outputURL: outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        } else {
            completion?(.failure(VideoRenderingError.error))
        }
        
        createPixelBufferAdaptor()
        
        if videoWriter.startWriting() == false {
            completion?(.failure(VideoRenderingError.error))
        }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
        completion?(.success(nil))
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    func render(appendPixelBuffers: ((VideoWriter) -> Bool)?, completion: (() -> Void)?) {
        
        precondition(videoWriter != nil, "Call start() to initialze the writer")
        
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers?(self) ?? false
            guard isFinished else {
                return
            }
            self.videoWriterInput.markAsFinished()
            self.videoWriter.finishWriting {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
        
        guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool,
              let pixelBuffer = VideoWriter.pixelBufferFromImage(
            image: image,
            pixelBufferPool: pixelBufferPool,
            size: renderSettings.size) else {
            return false
        }
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
    
    private func createPixelBufferAdaptor() {
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
        ]
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
    }
}
