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
import MobileCoreServices
import CoreImage

struct VideoGeneratorView: View {
    @State private var videoURL: URL?
    @State private var isGenerating = false
    @State private var progressValue: Double = 0
    @State private var showToast = false
    @State private var selectedMusicURL: URL?
    @State private var selectedFilter: String = "None"
    @State private var selectedTransition: String = "Crossfade"
    @State private var showCustomizationOptions = false
    @State private var documentPickerManager = DocumentPickerManager()
    @State private var showDocumentPicker = false
    //@State private var selectedMusicURL: URL? // Store selected music file
    
    let selectedImages: [UIImage]

    let filters = ["None", "Sepia", "Vignette", "Noir", "Bloom", "Instant", "Comic"]
    let transitions = ["Crossfade", "Slide", "Zoom"]

    var body: some View {
        ZStack {
            LinearGradient(
                           gradient: Gradient(colors: [Color.black.opacity(0.9), Color.purple.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing
                       )
                       .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Video Generator")
                                   .font(.largeTitle)
                                   .fontWeight(.bold)
                                   .foregroundColor(.white)
                                   .shadow(radius: 5)
                                   .padding(.top, 20)
                                   .transition(.opacity)
                                   .animation(.easeInOut(duration: 0.8))
                // **Display Selected Images**
                ScrollView(.horizontal, showsIndicators: false) {
                                   HStack(spacing: 10) {
                                       ForEach(selectedImages, id: \.self) { image in
                                           Image(uiImage: image)
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 90, height: 90)
                                               .clipShape(RoundedRectangle(cornerRadius: 12))
                                               .shadow(radius: 3)
                                       }
                                   }
                                   .padding(.horizontal, 15)
                               }
                               .frame(height: 100)
                               .clipped()
                               
                
                
                // **Progress Indicator (Smooth updates)**
                if isGenerating {
                    ProgressView("Generating Video..", value: progressValue)
                        .progressViewStyle(LinearProgressViewStyle())
                        .foregroundColor(.white)
                        .padding()
                }
                
                // **Generated Video Preview**
                if let videoURL = videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
                
                // **Toolbar for Video Actions**
                VideoToolbarView(
                    onGenerateVideo: generateVideo,
                    onShareVideo: videoURL != nil ? { shareVideo(videoURL: videoURL!) } : nil,
                    selectedFilter: $selectedFilter
                )
                .padding(.bottom, 10)
                
                // **Toast Notification**
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
            //.padding()
            .frame(maxWidth: .infinity, maxHeight:.infinity, alignment: .top)
            //.navigationTitle("Video Generator")
            .animation(.easeInOut, value: showToast)
        }

    }

    // MARK: - Select Background Music
    func selectBackgroundMusic() {
        showDocumentPicker = true
    }

    
    func promptBeforeGeneratingVideo() {
        clearTempDirectory()
        let alert = UIAlertController(
            title: "Customize Your Video",
            message: "Do you want to add background music or apply filters before generating the final video?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes, Customize", style: .default, handler: { _ in
            showCustomizationOptions = true // Open customization screen
        }))

        alert.addAction(UIAlertAction(title: "No, Continue", style: .default, handler: { _ in
            generateVideo()
        }))

        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    func isValidAudioFile(_ url: URL) -> Bool {
        let supportedExtensions = ["mp3", "m4a", "wav", "aac"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
    
    func isValidImage(_ image: UIImage) -> Bool {
        return image.cgImage != nil || image.ciImage != nil
    }


    // MARK: - Generate Video
    func generateVideo() {
        clearTempDirectory()
        isGenerating = true
        progressValue = 0 // Reset progress
        VideoGenerator.fileName = "MyGeneratedVideo"
        VideoGenerator.shouldOptimiseImageForVideo = true
        VideoGenerator.videoDurationInSeconds = Double(selectedImages.count * 3)
        videoURL = nil

        let validImages = selectedImages.filter { isValidImage($0) }
        if validImages.isEmpty {
            print("No valid images for video generation")
            isGenerating = false
            return
        }

    

        // Auto-select background music based on video duration
        let videoDuration = Double(validImages.count * 3)
        let musicURL = getAutoBackgroundMusic(for: videoDuration)

        VideoGenerator.current.generate(
            withImages: validImages,
            andAudios: [],
            andType: .multiple
        ) { progress in
            DispatchQueue.main.async {
                progressValue = progress.fractionCompleted
                print("Progress: \(Int(progress.fractionCompleted * 100))%")
            }
        } outcome: { result in
            DispatchQueue.main.async {
                isGenerating = false
            }
            switch result {
 
            case .success(let videoURL):
        
                // Apply transition
               // applyTransition(to: videoURL, transitionType: selectedTransition) { transitionedURL in
                    let finalTransitionURL = videoURL


                    // Apply filter if selected
                    if selectedFilter != "None" {
                        applyVideoFilter(to: finalTransitionURL) { filteredURL in
                            let finalFilteredURL = filteredURL ?? finalTransitionURL
                            print("Applied filter: \(finalFilteredURL)")
                            mergeAudioWithVideo(videoURL: finalFilteredURL, audioURL: musicURL!) { finalURL in
                                DispatchQueue.main.async {
                                    self.videoURL = finalURL ?? finalFilteredURL
                                    print("Final video with music & filter: \(String(describing: finalURL))")
                                }
                            }
                        }
                    }
                    else {
                        print("Merging music with video...")
                        mergeAudioWithVideo(videoURL: finalTransitionURL, audioURL: musicURL!) { finalURL in
                            DispatchQueue.main.async {
                                self.videoURL = finalURL ?? finalTransitionURL
                                print("Final video with music only: \(String(describing: finalURL))")
                            }
                        }
                    }
               // }


            case .failure(let error):
                print("Video generation failed: \(error.localizedDescription)")
            }
        }
    }


    func getAutoBackgroundMusic(for duration: Double) -> URL? {
        let randomIndex = Int.random(in: 1...11) // Randomly pick a number between 1 and 11
        let fileName = "\(randomIndex)" // Matches file names like "1.mp3", "2.mp3"

        // Look for the audio file in the main bundle
        guard let audioURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Failed to find audio file: \(fileName).mp3")
            return nil
        }

        print(" Selected background music: \(audioURL)")
        return audioURL
    }


    func applyTransition(to videoURL: URL, transitionType: String, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        
        guard let assetTrack = asset.tracks(withMediaType: .video).first else {
            print("Failed to load video track")
            completion(nil)
            return
        }

        // Create composition track
        guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Could not create video track")
            completion(nil)
            return
        }

        do {
            try track.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: assetTrack, at: .zero)
        } catch {
            print("Error inserting track: \(error)")
            completion(nil)
            return
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30) // 30 FPS
        videoComposition.renderSize = assetTrack.naturalSize

        let instructions: [AVMutableVideoCompositionInstruction] = createTransitionInstructions(asset: asset, transitionType: transitionType)
        
        videoComposition.instructions = instructions

        exportVideo(with: composition, videoComposition: videoComposition, completion: completion)
    }
    
    func createTransitionInstructions(asset: AVAsset, transitionType: String) -> [AVMutableVideoCompositionInstruction] {
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        let assetTrack = asset.tracks(withMediaType: .video).first!
        let segments = splitVideoIntoSegments(asset: asset) // Get time ranges for each image
        let transitionDuration = CMTimeMake(value: 1, timescale: 2) // 0.5s transition

        for i in 0..<segments.count - 1 {
            let startTime = segments[i].start
            let endTime = segments[i].end

            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: startTime, duration: endTime - startTime)

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)

            switch transitionType {
            case "Crossfade":
                applyCrossfadeTransition(layerInstruction: layerInstruction, startTime: startTime, transitionDuration: transitionDuration)
            case "Slide":
                applySlideEffect(layerInstruction: layerInstruction, startTime: startTime, transitionDuration: transitionDuration, videoSize: assetTrack.naturalSize)
            case "Zoom":
                applyZoomEffect(layerInstruction: layerInstruction, startTime: startTime, transitionDuration: transitionDuration)
            default:
                break
            }

            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
        }
        return instructions
    }

    func splitVideoIntoSegments(asset: AVAsset) -> [(start: CMTime, end: CMTime)] {
        let duration = asset.duration
        let frameCount = Int(duration.seconds / 3) // Assuming each image is shown for 3 seconds
        var segments: [(start: CMTime, end: CMTime)] = []
        
        for i in 0..<frameCount {
            let start = CMTimeMake(value: Int64(i * 3), timescale: 1)
            let end = CMTimeMake(value: Int64((i + 1) * 3), timescale: 1)
            segments.append((start, end))
        }
        
        return segments
    }
    func applyCrossfadeTransition(layerInstruction: AVMutableVideoCompositionLayerInstruction, startTime: CMTime, transitionDuration: CMTime) {
        let fadeOutStart = CMTimeSubtract(startTime, transitionDuration)
        let fadeOutEnd = startTime
        layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange(start: fadeOutStart, duration: transitionDuration))
    }
    func applySlideEffect(layerInstruction: AVMutableVideoCompositionLayerInstruction, startTime: CMTime, transitionDuration: CMTime, videoSize: CGSize) {
        let slideIn = CGAffineTransform(translationX: videoSize.width, y: 0)
        let slideOut = CGAffineTransform(translationX: -videoSize.width, y: 0)
        
        layerInstruction.setTransformRamp(fromStart: slideIn, toEnd: .identity, timeRange: CMTimeRangeMake(start: startTime, duration: transitionDuration))
        layerInstruction.setTransformRamp(fromStart: .identity, toEnd: slideOut, timeRange: CMTimeRangeMake(start: CMTimeAdd(startTime, transitionDuration), duration: transitionDuration))
    }

    func applyZoomEffect(layerInstruction: AVMutableVideoCompositionLayerInstruction, startTime: CMTime, transitionDuration: CMTime) {
        let zoomIn = CGAffineTransform(scaleX: 1.5, y: 1.5)
        let zoomOut = CGAffineTransform(scaleX: 1.0, y: 1.0)

        layerInstruction.setTransformRamp(fromStart: zoomOut, toEnd: zoomIn, timeRange: CMTimeRange(start: startTime, duration: transitionDuration))
        layerInstruction.setTransformRamp(fromStart: zoomIn, toEnd: zoomOut, timeRange: CMTimeRange(start: CMTimeAdd(startTime, transitionDuration), duration: transitionDuration))
    }

    func exportVideo(with composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")

        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Could not create export session")
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4 // Ensure .mp4 format
        exportSession.videoComposition = videoComposition
        exportSession.shouldOptimizeForNetworkUse = true
        
        print("Exporting video...")

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    print("Video successfully exported: \(outputURL)")
                    completion(outputURL)
                case .failed:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                case .cancelled:
                    print("Export cancelled")
                    completion(nil)
                default:
                    print("Export unknown error")
                    completion(nil)
                }
            }
        }
    }


    func renameAudioFile(originalURL: URL) -> URL {
        let safeURL = FileManager.default.temporaryDirectory.appendingPathComponent("renamed_audio.m4a")
        
        do {
            try FileManager.default.moveItem(at: originalURL, to: safeURL)
            print("Audio file renamed successfully: \(safeURL)")
            return safeURL
        } catch {
            print("Failed to rename audio file: \(error.localizedDescription)")
            return originalURL // Fallback to original if renaming fails
        }
    }
    
    func mergeAudioWithVideo(videoURL: URL, audioURL: URL, completion: @escaping (URL?) -> Void) {
        let mixComposition = AVMutableComposition()

        // Load video asset
        let videoAsset = AVURLAsset(url: videoURL)
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            print("No video track found")
            completion(nil)
            return
        }

        // Load audio asset
        let audioAsset = AVURLAsset(url: audioURL)
        guard let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            print("No audio track found")
            completion(nil)
            return
        }

        // Add video track
        let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoCompositionTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero
            )
        } catch {
            print("Error adding video track: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Add audio track
        let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try audioCompositionTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: audioTrack,
                at: .zero
            )
        } catch {
            print("Error adding audio track: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Export final video
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("VideoWithAudio.mp4")

        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Merged audio and video successfully: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Audio merge failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }

    
    func adjustAudioVolume(asset: AVAsset, volume: Float) -> AVAudioMix {
        let mix = AVMutableAudioMix()
        var params: [AVMutableAudioMixInputParameters] = []

        for track in asset.tracks(withMediaType: .audio) {
            let param = AVMutableAudioMixInputParameters(track: track)
            param.setVolume(volume, at: CMTime.zero)
            params.append(param)
        }

        mix.inputParameters = params
        return mix
    }
    
    func clearTempDirectory() {
        let tempDirectory = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
            for file in tempFiles {
                try FileManager.default.removeItem(at: file)
            }
            print("Temp directory cleared")
        } catch {
            print("Failed to clear temp directory: \(error.localizedDescription)")
        }
    }

    
    func applyVideoFilter(to url: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: url)
        let composition = AVVideoComposition(asset: asset) { request in
            let filterName = getCIFilterName(selectedFilter)
            let ciImage = request.sourceImage.applyingFilter(filterName)
            request.finish(with: ciImage, context: nil)
        }
        
        exportFilteredVideo(asset: asset, composition: composition, completion: completion)
    }


    // MARK: - Export Filtered Video
    func exportFilteredVideo(asset: AVAsset, composition: AVVideoComposition, completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("FilteredVideo.mp4")

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            print("Export session failed")
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = composition
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Filtered video saved at: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Failed to export video")
                    completion(nil)
                }
            }
        }
    }


    // MARK: - Get CIFilter Name
    func getCIFilterName(_ filter: String) -> String {
        switch filter {
        case "Sepia": return "CISepiaTone"
        case "Vignette": return "CIVignette"
        case "Noir": return "CIPhotoEffectNoir"
        case "Bloom": return "CIBloom"
        case "Instant": return "CIPhotoEffectInstant"
        case "Comic": return "CIComicEffect"
        default: return "CIColorControls"
        }
    }


    // MARK: - Share Video
    func shareVideo(videoURL: URL) {
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}



#Preview {
    VideoGeneratorView(selectedImages: [])
}
