//
//  ImageAnimator.swift
//  test
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import AVFoundation
import Photos
import UIKit

enum VideoRenderingError: Error {
    case error
}

final class ImageAnimator {
    static let kTimescale: Int32 = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    var images: [UIImage]!
    
    var frameNum = 0
    
    init(renderSettings: RenderSettings, images: [UIImage]) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
        self.images = images
    }
    
    func render(completion: ((Result<String, Error>) -> Void)?) {
        
        guard let outputURL = settings.outputURL else {
            completion?(.failure(VideoRenderingError.error))
            return 
        }
        
        removeFileAtURL(fileURL: outputURL)
        
        videoWriter.start { result in
            switch result {
            case .failure: completion?(.failure(VideoRenderingError.error))
            case .success:
                self.videoWriter.render(appendPixelBuffers: self.appendPixelBuffers) {
                    self.saveToLibrary(videoURL: outputURL)
                    completion?(.success("saving to: \(outputURL.absoluteString)"))
                }
            }
        }
    }
    
    private func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let value = Int64(ImageAnimator.kTimescale / settings.fps)
        let frameDuration = CMTimeMake(value: value,
                                       timescale: ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            
            if writer.isReadyForData == false {
                return false
            }
            
            let image = images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
            let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
            if success == false {
                print("addImage() failed")
                return false
            }
            
            frameNum += 1
        }
        
        return true
    }
    
    private func saveToLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library:", error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    private func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch _ as NSError {
            print("Assume file doesn't exist.")
        }
    }
}
