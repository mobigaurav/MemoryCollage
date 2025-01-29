//
//  VideoGeneratorViewModel.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI

class VideoGeneratorViewModel: ObservableObject {
    @Published var videoURL: URL? = nil
    @Published var isComplete: Bool = false
    @Published var progress: String = "Initializing..."
    
    func generateVideo(images: [UIImage]) {
        // Convert images to base64
        let encodedImages = images.compactMap { $0.jpegData(compressionQuality: 0.8)?.base64EncodedString() }

//        // Prepare the payload
//        let payload: [String: Any] = [
//            "theme": theme,
//            "text": text,
//            "images": encodedImages
//        ]
//
//        // Send the request
//        guard let url = URL(string: "https://example.com/generateVideo") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let data = data, let result = try? JSONDecoder().decode(VideoJobResponse.self, from: data) {
//                DispatchQueue.main.async {
//                    self?.trackVideoGeneration(jobId: result.jobId)
//                }
//            } else {
//                print("Error starting video generation: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }.resume()
    }

//    func generateVideo(theme: String, text: String, images: [UIImage]) {
//        // Convert images to base64
//        let encodedImages = images.compactMap { $0.jpegData(compressionQuality: 0.8)?.base64EncodedString() }
//
//        // Prepare the payload
//        let payload: [String: Any] = [
//            "theme": theme,
//            "text": text,
//            "images": encodedImages
//        ]
//
//        // Send the request
//        guard let url = URL(string: "https://example.com/generateVideo") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let data = data, let result = try? JSONDecoder().decode(VideoJobResponse.self, from: data) {
//                DispatchQueue.main.async {
//                    self?.trackVideoGeneration(jobId: result.jobId)
//                }
//            } else {
//                print("Error starting video generation: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }.resume()
//    }

    func trackVideoGeneration(jobId: String) {
        guard let url = URL(string: "https://example.com/videoStatus/\(jobId)") else { return }

        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let status = try? JSONDecoder().decode(VideoStatusResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self?.progress = status.progress

                        if status.status == "Complete", let videoURLString = status.videoURL, let videoURL = URL(string: videoURLString) {
                            self?.videoURL = videoURL
                            self?.isComplete = true
                            timer.invalidate()
                        }
                    }
                }
            }.resume()
        }
    }
}

// Models for API responses
struct VideoJobResponse: Decodable {
    let jobId: String
}

struct VideoStatusResponse: Decodable {
    let status: String
    let progress: String
    let videoURL: String?
}


