//
//  VideoGeneratorView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI
import SwiftVideoGenerator
import Photos
import AVKit

struct VideoGeneratorView: View {
    //@StateObject private var viewModel = VideoGeneratorViewModel()
    @State private var videoURL: URL? // URL of the generated video
    @State private var isGenerating = false // Generation status
    @State private var progressValue: Double = 0 // Progress value
    let selectedImages: [UIImage] // Passed from VideoTabView
    @State private var showToast = false // Controls the visibility of the toast message

   // @State private var isGenerating = false

    var body: some View {
        ZStack {
            VStack {
                // Selected Images Display
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                
//                // Form Inputs
//                Form {
//                    //                TextField("Enter text for video", text: $videoText)
//                    //                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    //
//                    //                Picker("Theme", selection: $videoTheme) {
//                    //                    Text("Custom").tag("Custom")
//                    //                    Text("Birthday").tag("Birthday")
//                    //                    Text("Travel").tag("Travel")
//                    //                }
//                    //                .pickerStyle(SegmentedPickerStyle())
//                    
//                    Button(action: {
//                        generateVideo()
//                        //isGenerating = true
//                        //viewModel.generateVideo(images: selectedImages)
//                        //viewModel.generateVideo(theme: videoTheme, text: videoText, images: selectedImages)
//                    }) {
//                        Text("Generate Video")
//                            .font(.headline)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(isGenerating || selectedImages.isEmpty)
//                    .padding()
//                    .background(isGenerating ? Color.gray : Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
                
                // Progress Indicator
                if isGenerating {
                    ProgressView(value: progressValue)
                        .padding()
                }
                
                if let videoURL = videoURL {
                    VStack {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 300)
                            .cornerRadius(10)
                            .padding()
                        
//                        // Save to camera roll button
//                        Button("Save to Camera Roll") {
//                            saveVideoToGallery(videoURL: videoURL)
//                        }
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
                    }
                }
                
                // Floating Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        // Generate Video FAB
                        Button(action: generateVideo) {
                            Image(systemName: "video.badge.plus")
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                        .padding()

                        // Save to Camera Roll FAB
                        if let videoURL = videoURL {
                            Button(action: {
                                saveVideoToGallery(videoURL: videoURL)
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.title)
                                    .padding()
                                    .background(Circle().fill(Color.green))
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                            .padding()
                        }
                    }
                }
                
                if showToast {
                    VStack {
                        Spacer()
                        Text("Video saved to Camera Roll!")
                            .font(.body)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                            .transition(.opacity)
                    }
                }
                       
            }
            .padding()
            .navigationTitle("Video Generator")
        }
        .animation(.easeInOut, value: showToast) // Animates the toast appearance and disappearance
    }
    
    // MARK: - Save Video to Camera Roll

        func saveVideoToGallery(videoURL: URL) {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Photo Library access denied")
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { success, error in
                    if success {
                        print("Video successfully saved to the gallery!")
                        // Show toast message on success
                        DispatchQueue.main.async {
                            showToastMessage()
                        }
                    } else if let error = error {
                        print("Failed to save video: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    // MARK: - Toast Message Logic

        private func showToastMessage() {
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Hide toast after 2 seconds
                showToast = false
            }
        }
    
    func generateVideo() {
           isGenerating = true
           VideoGenerator.fileName = "MyGeneratedVideo"
           VideoGenerator.shouldOptimiseImageForVideo = true
           VideoGenerator.videoDurationInSeconds = Double(selectedImages.count * 3) // 3 seconds per image

        VideoGenerator.current.generate(withImages: selectedImages, andAudios: [], andType: .multiple) { progress in
            print("Progress update: \(progress.fractionCompleted * 100)%")
            // Update progress
            DispatchQueue.main.async {
                    progressValue = progress.fractionCompleted
                }
           } outcome: { result in
               // Handle completion
               isGenerating = false
               switch result {
               case .success(let url):
                   videoURL = url
                   print("Video successfully generated: \(url)")
               case .failure(let error):
                   print("Video generation failed: \(error.localizedDescription)")
               }
           }
       }
}





#Preview {
    VideoGeneratorView(selectedImages: [])
}
