//
//  VideoGeneratorGPU.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/24/25.
//

import Foundation
import SwiftVideoGenerator
import Photos

class SwiftVideoGenerator {
    func createVideo(from images: [UIImage], outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        VideoGenerator.fileName = "output_video" // Optional: Set custom file name
        VideoGenerator.shouldOptimiseImageForVideo = true // Optimize images for video

        VideoGenerator.current.generate(withImages: images, andAudios: [], andType: .single) { progress in
            print("Progress: \(progress.fractionCompleted * 100)%")
        } outcome: { result in
            switch result {
            case .success(let url):
                        print("Video successfully generated at: \(url)")
                        completion(.success(url))
            case .failure(let error):
                print("Video generation failed with error: \(error.localizedDescription)")
                completion(.failure(error))
                
            }
        }
           
    }

    func saveVideoToGallery(videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false, NSError(domain: "PhotoLibraryError", code: -1, userInfo: nil))
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                completion(success, error)
            }
        }
    }
    
}



