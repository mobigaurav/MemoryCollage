//
//  VideoGeneratorScreen.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import SwiftUI
import Photos

struct VideoGeneratorScreen: View {
    @State  var selectedImages: [UIImage]
    @State private var selectedAudioURL: URL? = nil
    @State private var isGeneratingVideo = false
    @State private var progress: CGFloat = 0.0
    @State private var statusMessage = "Ready to start"
    @State private var pickerSelection = false
    @State private var outputVideoURL: URL? = nil
    
    var body: some View {
        ZStack {
            // Main Content
            VStack {
                // Selected Images Display
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                }

                // Progress Bar and Status
                if isGeneratingVideo {
                    VStack {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                        Text(statusMessage)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    .padding(.vertical)
                }

                Spacer()
            }
            .padding(.trailing, 60) // Leave space for the toolbar

            // Right-Side Toolbar
            VStack {
                Spacer()

                // Select Images
                Button(action: {
                    selectedImages = []
                    pickerSelection = true
                }) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.largeTitle)
                            .padding()
                        Text("Images")
                            .font(.caption2)
                    }
                }
                .buttonStyle(ToolbarButtonStyle())
                .padding()
                .sheet(isPresented: $pickerSelection, content: {
                               ImagePicker(images: $selectedImages)
                           })

                Spacer()

                // Select Music
                Button(action: {
                    pickerSelection = true
                }) {
                    VStack {
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                            .padding()
                        Text("Music")
                            .font(.caption2)
                    }
                }
                .buttonStyle(ToolbarButtonStyle())
                .padding()
                .sheet(isPresented: $pickerSelection, content: {
                               ImagePicker(images: $selectedImages)
                           })

                Spacer()

                // Generate Video
                Button(action: generateVideo) {
                    VStack {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .padding()
                        Text("Generate")
                            .font(.caption2)
                    }
                }
                .buttonStyle(ToolbarButtonStyle())

                Spacer()
            }
            .frame(width: 80)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            .position(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height / 2.5)
        }
        .navigationTitle("Generate Video")
    }

    // MARK: - Actions
    private func selectImages() {
        // Image selection logic
      
        statusMessage = "Selecting images..."
    }

    private func selectMusic() {
        // Music selection logic
        statusMessage = "Selecting music..."
    }
    
    func resolveFileProviderURL(_ url: URL) -> URL? {
        guard url.startAccessingSecurityScopedResource() else {
            print("[ERROR] Could not access security-scoped resource.")
            return nil
        }

        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            var isStale = false
            let resolvedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                print("[WARNING] Resolved URL is stale.")
            }
            return resolvedURL
        } catch {
            print("[ERROR] Could not resolve URL: \(error)")
            return nil
        }
    }
    
//    private func validateImages(_ images: [UIImage]) -> Bool {
//        for image in images {
//            if VideoGenerator.normalizeImage(image) == nil {
//                print("Image is incompatible or cannot be normalized.")
//                return false
//            }
//        }
//        return true
//    }



    private func generateVideo() {
        guard !selectedImages.isEmpty else {
            statusMessage = "Please select images first."
            return
        }

        let videoSize = CGSize(width: 1920, height: 1080) // Set desired resolution
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("GeneratedVideo.mp4")

        isGeneratingVideo = true
        statusMessage = "Generating video..."

//        VideoGenerator.createVideo(from: selectedImages, outputURL: outputURL, videoSize: videoSize) { success, error in
//            DispatchQueue.main.async {
//                self.isGeneratingVideo = false
//                if success {
//                    self.statusMessage = "Video generated successfully!"
//                    self.saveToPhotoLibrary(videoURL: outputURL)
//                } else {
//                    self.statusMessage = "Failed to generate video: \(error ?? "Unknown error")"
//                }
//            }
//        }
    }

    
    
    private func saveToPhotoLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.statusMessage = "Photo Library access denied."
                }
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.statusMessage = "Video saved to Photo Library!"
                    } else {
                        self.statusMessage = "Failed to save video: \(error?.localizedDescription ?? "Unknown error")"
                    }
                }
            }
        }
    }
}





// MARK: - Toolbar Button Style
struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 60, height: 60)
            .background(configuration.isPressed ? Color.gray.opacity(0.4) : Color.clear)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

