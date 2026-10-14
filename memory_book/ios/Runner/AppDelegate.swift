import AVFoundation
import Flutter
import ImageIO
import UIKit
import UniformTypeIdentifiers
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    let channel = FlutterMethodChannel(
      name: "memory_book/video_encoder",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          switch call.method {
          case "encodeFrames":
            let args = call.arguments as? [String: Any] ?? [:]
            let path = try MemoryBookEncoder.encodeFrames(args: args)
            DispatchQueue.main.async { result(path) }
          case "encodeSlideshow":
            let args = call.arguments as? [String: Any] ?? [:]
            let path = try MemoryBookEncoder.encodeSlideshow(args: args)
            DispatchQueue.main.async { result(path) }
          case "preparePlayback":
            MemoryBookEncoder.activatePlayback()
            DispatchQueue.main.async { result(nil) }
          case "mixAudio":
            let args = call.arguments as? [String: Any] ?? [:]
            let video = args["videoPath"] as? String ?? ""
            let audio = args["audioPath"] as? String ?? ""
            let path = try MemoryBookEncoder.mixAudio(video: video, audio: audio)
            DispatchQueue.main.async { result(path) }
          case "encodeHeic":
            let args = call.arguments as? [String: Any] ?? [:]
            let bytes = args["bytes"] as? FlutterStandardTypedData
            let out = MemoryBookEncoder.encodeHeic(bytes?.data ?? Data())
            DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: out)) }
          case "editClip":
            let args = call.arguments as? [String: Any] ?? [:]
            let path = try MemoryBookEncoder.editClip(args: args)
            DispatchQueue.main.async { result(path) }
          case "posterFrame":
            let args = call.arguments as? [String: Any] ?? [:]
            let bytes = try MemoryBookEncoder.posterFrame(args: args)
            DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: bytes)) }
          default:
            DispatchQueue.main.async { result(FlutterMethodNotImplemented) }
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "encode", message: error.localizedDescription, details: nil))
          }
        }
      }
    }
    let notify = FlutterMethodChannel(name: "memory_book/notify", binaryMessenger: messenger)
    notify.setMethodCallHandler { call, result in
      switch call.method {
      case "request":
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
          DispatchQueue.main.async { result(nil) }
        }
      case "show":
        let args = call.arguments as? [String: Any] ?? [:]
        let content = UNMutableNotificationContent()
        content.title = args["title"] as? String ?? "Memory Book"
        content.body = args["body"] as? String ?? "Your reel is ready."
        content.sound = .default
        let req = UNNotificationRequest(
          identifier: UUID().uuidString,
          content: content,
          trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.4, repeats: false)
        )
        UNUserNotificationCenter.current().add(req) { _ in
          DispatchQueue.main.async { result(nil) }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

enum MemoryBookEncoder {
  static func encodeHeic(_ data: Data) -> Data {
    guard let image = UIImage(data: data), let cg = image.cgImage else { return data }
    let destData = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(
      destData,
      UTType.heic.identifier as CFString,
      1,
      nil
    ) else { return data }
    CGImageDestinationAddImage(dest, cg, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
    CGImageDestinationFinalize(dest)
    return destData as Data
  }

  static func encodeFrames(args: [String: Any]) throws -> String {
    let frames = args["frames"] as? [String] ?? []
    let output = args["outputPath"] as? String ?? ""
    let width = args["width"] as? Int ?? 1080
    let height = args["height"] as? Int ?? 1920
    let fps = args["fps"] as? Int ?? 12
    let audio = args["audioPath"] as? String
    try writeImages(frames, output: output, width: width, height: height, fps: Double(fps), hold: 1)
    if let audio, FileManager.default.fileExists(atPath: audio) {
      return try mix(video: output, audio: audio)
    }
    return output
  }

  static func encodeSlideshow(args: [String: Any]) throws -> String {
    let images = args["images"] as? [String] ?? []
    let output = args["outputPath"] as? String ?? ""
    let width = args["width"] as? Int ?? 1080
    let height = args["height"] as? Int ?? 1920
    let seconds = args["secondsPerSlide"] as? Double ?? 3
    let transition = args["transition"] as? String ?? "crossfade"
    let filter = args["filter"] as? String ?? "none"
    let fps = 24.0
    let hold = max(1, Int(seconds * fps))
    let trans = transition == "none" ? 0 : 8
    let audio = args["audioPath"] as? String
    try writeImages(
      images,
      output: output,
      width: width,
      height: height,
      fps: fps,
      hold: hold,
      transitionFrames: trans,
      transition: transition,
      filter: filter
    )
    if let audio, FileManager.default.fileExists(atPath: audio) {
      return try mix(video: output, audio: audio)
    }
    return output
  }

  private static func writeImages(
    _ paths: [String],
    output: String,
    width: Int,
    height: Int,
    fps: Double,
    hold: Int,
    transitionFrames: Int = 0,
    transition: String = "none",
    filter: String = "none"
  ) throws {
    try? FileManager.default.removeItem(atPath: output)
    let url = URL(fileURLWithPath: output)
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let settings: [String: Any] = [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: width,
      AVVideoHeightKey: height,
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ]
    )
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    var frame = 0
    let frameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
    func append(_ buffer: CVPixelBuffer) {
      while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.01) }
      let time = CMTimeMultiply(frameDuration, multiplier: Int32(frame))
      adaptor.append(buffer, withPresentationTime: time)
      frame += 1
    }
    let loaded = paths.compactMap { path -> UIImage? in
      guard let image = UIImage(contentsOfFile: path) else { return nil }
      return applyFilter(upright(image), filter)
    }
    for (index, image) in loaded.enumerated() {
      let still = pixelBuffer(from: image, to: nil, t: 0, type: "none", width: width, height: height)
      for _ in 0..<hold { append(still) }
      if transitionFrames > 0, index + 1 < loaded.count {
        let next = loaded[index + 1]
        for step in 1...transitionFrames {
          let t = CGFloat(step) / CGFloat(transitionFrames)
          append(pixelBuffer(from: image, to: next, t: t, type: transition, width: width, height: height))
        }
      }
    }
    input.markAsFinished()
    let sema = DispatchSemaphore(value: 0)
    writer.finishWriting { sema.signal() }
    sema.wait()
    if writer.status != .completed {
      throw NSError(domain: "MemoryBook", code: 2, userInfo: [NSLocalizedDescriptionKey: writer.error?.localizedDescription ?? "writer failed"])
    }
  }

  private static func applyFilter(_ image: UIImage, _ name: String) -> UIImage {
    guard name != "none", let cg = image.cgImage else { return image }
    let ci = CIImage(cgImage: cg)
    let filtered: CIImage?
    switch name {
    case "sepia":
      let f = CIFilter(name: "CISepiaTone")
      f?.setValue(ci, forKey: kCIInputImageKey)
      f?.setValue(0.75, forKey: kCIInputIntensityKey)
      filtered = f?.outputImage
    case "noir":
      filtered = CIFilter(name: "CIPhotoEffectNoir", parameters: [kCIInputImageKey: ci])?.outputImage
    case "instant":
      filtered = CIFilter(name: "CIPhotoEffectInstant", parameters: [kCIInputImageKey: ci])?.outputImage
    case "bloom":
      let f = CIFilter(name: "CIBloom")
      f?.setValue(ci, forKey: kCIInputImageKey)
      f?.setValue(0.6, forKey: kCIInputIntensityKey)
      filtered = f?.outputImage
    case "vignette":
      let f = CIFilter(name: "CIVignette")
      f?.setValue(ci, forKey: kCIInputImageKey)
      f?.setValue(1.4, forKey: kCIInputIntensityKey)
      filtered = f?.outputImage
    case "comic":
      filtered = CIFilter(name: "CIComicEffect", parameters: [kCIInputImageKey: ci])?.outputImage
    case "enhance":
      let f = CIFilter(name: "CIColorControls")
      f?.setValue(ci, forKey: kCIInputImageKey)
      f?.setValue(1.12, forKey: kCIInputSaturationKey)
      f?.setValue(0.03, forKey: kCIInputBrightnessKey)
      f?.setValue(1.06, forKey: kCIInputContrastKey)
      filtered = f?.outputImage
    default:
      return image
    }
    guard let out = filtered else { return image }
    let ctx = CIContext()
    guard let done = ctx.createCGImage(out, from: out.extent) else { return image }
    return UIImage(cgImage: done)
  }

  private static func upright(_ image: UIImage) -> UIImage {
    if image.imageOrientation == .up { return image }
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = image.scale
    let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: image.size))
    }
  }

  static func activatePlayback() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .moviePlayback)
    try? session.setActive(true)
  }

  static func mixAudio(video: String, audio: String) throws -> String {
    try mix(video: video, audio: audio)
  }

  private static func mix(video: String, audio: String) throws -> String {
    activatePlayback()
    let mixUrl = URL(fileURLWithPath: video).deletingPathExtension().appendingPathExtension("mixed.mp4")
    try? FileManager.default.removeItem(at: mixUrl)
    let composition = AVMutableComposition()
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: video))
    let audioAsset = AVURLAsset(url: URL(fileURLWithPath: audio))
    guard let videoTrack = firstTrack(videoAsset, .video) else { return video }
    let videoSpan = loadedDuration(videoAsset)
    guard videoSpan.isValid, videoSpan.seconds > 0.2 else { return video }
    let v = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    v?.preferredTransform = videoTrack.preferredTransform
    try v?.insertTimeRange(CMTimeRange(start: .zero, duration: videoSpan), of: videoTrack, at: .zero)
    if let aTrack = firstTrack(audioAsset, .audio) {
      let a = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
      let audioSpan = loadedDuration(audioAsset)
      let span = CMTimeMinimum(videoSpan, audioSpan)
      if span.isValid && span.seconds > 0.05 {
        try a?.insertTimeRange(CMTimeRange(start: .zero, duration: span), of: aTrack, at: .zero)
      }
    }
    guard let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
      return video
    }
    session.outputURL = mixUrl
    session.outputFileType = .mp4
    let sema = DispatchSemaphore(value: 0)
    session.exportAsynchronously { sema.signal() }
    _ = sema.wait(timeout: .now() + 60)
    if session.status == .completed { return mixUrl.path }
    try? FileManager.default.removeItem(at: mixUrl)
    guard let fallback = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else {
      return video
    }
    fallback.outputURL = mixUrl
    fallback.outputFileType = .mp4
    let again = DispatchSemaphore(value: 0)
    fallback.exportAsynchronously { again.signal() }
    _ = again.wait(timeout: .now() + 60)
    return fallback.status == .completed ? mixUrl.path : video
  }

  private static func firstTrack(_ asset: AVAsset, _ type: AVMediaType) -> AVAssetTrack? {
    let sema = DispatchSemaphore(value: 0)
    asset.loadValuesAsynchronously(forKeys: ["tracks", "duration"]) {
      sema.signal()
    }
    _ = sema.wait(timeout: .now() + 8)
    return asset.tracks(withMediaType: type).first
  }

  private static func loadedDuration(_ asset: AVAsset) -> CMTime {
    let sema = DispatchSemaphore(value: 0)
    var value = CMTime.zero
    asset.loadValuesAsynchronously(forKeys: ["duration"]) {
      value = asset.duration
      sema.signal()
    }
    _ = sema.wait(timeout: .now() + 8)
    if !value.isValid || value.seconds <= 0 {
      return .invalid
    }
    return value
  }

  static func posterFrame(args: [String: Any]) throws -> Data {
    let path = args["path"] as? String ?? ""
    let atMs = intArg(args["atMs"])
    let asset = AVURLAsset(url: URL(fileURLWithPath: path))
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: 1080, height: 1920)
    let time = CMTime(value: CMTimeValue(max(0, atMs)), timescale: 1000)
    let image = try generator.copyCGImage(at: time, actualTime: nil)
    guard let data = UIImage(cgImage: image).jpegData(compressionQuality: 0.86) else {
      throw NSError(domain: "MemoryBook", code: 4, userInfo: [
        NSLocalizedDescriptionKey: "Could not read a frame from this reel.",
      ])
    }
    return data
  }

  static func editClip(args: [String: Any]) throws -> String {
    let output = args["outputPath"] as? String ?? ""
    let aspect = args["aspect"] as? String ?? "original"
    let mute = args["mute"] as? Bool ?? false
    let rawClips = args["clips"] as? [[String: Any]] ?? []
    if output.isEmpty || rawClips.isEmpty {
      throw NSError(domain: "MemoryBook", code: 5, userInfo: [
        NSLocalizedDescriptionKey: "Choose a reel to edit.",
      ])
    }
    let composition = AVMutableComposition()
    guard let videoOut = composition.addMutableTrack(
      withMediaType: .video,
      preferredTrackID: kCMPersistentTrackID_Invalid
    ) else {
      throw NSError(domain: "MemoryBook", code: 6, userInfo: [
        NSLocalizedDescriptionKey: "Could not open a video track.",
      ])
    }
    let audioOut = mute
      ? nil
      : composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    var cursor = CMTime.zero
    var pieces: [(AVAssetTrack, CMTime, CMTime)] = []
    for raw in rawClips {
      let path = raw["path"] as? String ?? ""
      guard FileManager.default.fileExists(atPath: path) else { continue }
      let asset = AVURLAsset(url: URL(fileURLWithPath: path))
      guard let source = loadTrack(asset, .video) else { continue }
      let full = loadedDuration(asset)
      guard full.isValid, full.seconds > 0.05 else { continue }
      let startMs = intArg(raw["startMs"])
      let endMs = intArg(raw["endMs"])
      var start = CMTime(value: CMTimeValue(max(0, startMs)), timescale: 1000)
      var end = endMs > startMs
        ? CMTime(value: CMTimeValue(endMs), timescale: 1000)
        : full
      if start > full { start = .zero }
      if end > full { end = full }
      let span = CMTimeSubtract(end, start)
      guard span.isValid, span.seconds >= 0.05 else { continue }
      try videoOut.insertTimeRange(CMTimeRange(start: start, duration: span), of: source, at: cursor)
      if let audioOut, let sourceAudio = loadTrack(asset, .audio) {
        try? audioOut.insertTimeRange(CMTimeRange(start: start, duration: span), of: sourceAudio, at: cursor)
      }
      pieces.append((source, cursor, span))
      cursor = CMTimeAdd(cursor, span)
    }
    guard cursor.seconds >= 0.05, let first = pieces.first else {
      throw NSError(domain: "MemoryBook", code: 7, userInfo: [
        NSLocalizedDescriptionKey: "That cut is too short to save.",
      ])
    }
    let render = renderSize(aspect: aspect, sample: first.0)
    let compositionVideo = AVMutableVideoComposition()
    compositionVideo.renderSize = render
    compositionVideo.frameDuration = CMTime(value: 1, timescale: 30)
    compositionVideo.instructions = pieces.map { piece in
      let instruction = AVMutableVideoCompositionInstruction()
      instruction.timeRange = CMTimeRange(start: piece.1, duration: piece.2)
      let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoOut)
      layer.setTransform(displayTransform(track: piece.0, renderSize: render), at: piece.1)
      instruction.layerInstructions = [layer]
      return instruction
    }
    try? FileManager.default.removeItem(atPath: output)
    guard let session = AVAssetExportSession(
      asset: composition,
      presetName: AVAssetExportPresetHighestQuality
    ) else {
      throw NSError(domain: "MemoryBook", code: 8, userInfo: [
        NSLocalizedDescriptionKey: "Could not start the export.",
      ])
    }
    session.outputURL = URL(fileURLWithPath: output)
    session.outputFileType = .mp4
    session.videoComposition = compositionVideo
    session.shouldOptimizeForNetworkUse = true
    let sema = DispatchSemaphore(value: 0)
    session.exportAsynchronously { sema.signal() }
    _ = sema.wait(timeout: .now() + 180)
    if session.status == .completed { return output }
    throw NSError(domain: "MemoryBook", code: 9, userInfo: [
      NSLocalizedDescriptionKey: session.error?.localizedDescription ?? "The edit did not finish.",
    ])
  }

  private static func intArg(_ value: Any?) -> Int {
    if let number = value as? Int { return number }
    if let number = value as? NSNumber { return number.intValue }
    return 0
  }

  private static func loadTrack(_ asset: AVAsset, _ type: AVMediaType) -> AVAssetTrack? {
    let sema = DispatchSemaphore(value: 0)
    asset.loadValuesAsynchronously(forKeys: ["tracks", "duration"]) { sema.signal() }
    _ = sema.wait(timeout: .now() + 8)
    guard let track = asset.tracks(withMediaType: type).first else { return nil }
    let again = DispatchSemaphore(value: 0)
    track.loadValuesAsynchronously(forKeys: ["naturalSize", "preferredTransform"]) { again.signal() }
    _ = again.wait(timeout: .now() + 8)
    return track
  }

  private static func renderSize(aspect: String, sample: AVAssetTrack) -> CGSize {
    let upright = orientedSize(sample)
    func even(_ value: CGFloat) -> CGFloat { floor(max(value, 2) / 2) * 2 }
    switch aspect {
    case "1:1":
      let side = even(min(max(upright.width, 720), 1080))
      return CGSize(width: side, height: side)
    case "4:5":
      let width = even(min(max(upright.width, 720), 1080))
      return CGSize(width: width, height: even(width * 5 / 4))
    case "16:9":
      let width = even(min(max(upright.width, 1280), 1920))
      return CGSize(width: width, height: even(width * 9 / 16))
    case "9:16":
      let height = even(min(max(upright.height, 1280), 1920))
      return CGSize(width: even(height * 9 / 16), height: height)
    default:
      return CGSize(width: even(upright.width), height: even(upright.height))
    }
  }

  private static func orientedSize(_ track: AVAssetTrack) -> CGSize {
    let rect = CGRect(origin: .zero, size: track.naturalSize).applying(track.preferredTransform)
    let width = abs(rect.width)
    let height = abs(rect.height)
    if width < 2 || height < 2 { return CGSize(width: 720, height: 1280) }
    return CGSize(width: width, height: height)
  }

  private static func displayTransform(track: AVAssetTrack, renderSize: CGSize) -> CGAffineTransform {
    let natural = track.naturalSize
    let preferred = track.preferredTransform
    let videoRect = CGRect(origin: .zero, size: natural).applying(preferred)
    let normalized = CGAffineTransform(translationX: -videoRect.origin.x, y: -videoRect.origin.y)
    let upright = preferred.concatenating(normalized)
    let uprightSize = CGSize(width: abs(videoRect.width), height: abs(videoRect.height))
    let safe = CGSize(
      width: max(uprightSize.width, 2),
      height: max(uprightSize.height, 2)
    )
    let scale = max(renderSize.width / safe.width, renderSize.height / safe.height)
    let scaled = upright.concatenating(CGAffineTransform(scaleX: scale, y: scale))
    let fitted = CGSize(width: safe.width * scale, height: safe.height * scale)
    let dx = (renderSize.width - fitted.width) / 2
    let dy = (renderSize.height - fitted.height) / 2
    return scaled.concatenating(CGAffineTransform(translationX: dx, y: dy))
  }

  private static func pixelBuffer(
    from image: UIImage,
    to next: UIImage?,
    t: CGFloat,
    type: String,
    width: Int,
    height: Int
  ) -> CVPixelBuffer {
    var buffer: CVPixelBuffer?
    let attrs: [CFString: Any] = [
      kCVPixelBufferCGImageCompatibilityKey: true,
      kCVPixelBufferCGBitmapContextCompatibilityKey: true,
    ]
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &buffer)
    guard let pixel = buffer else { fatalError("pixel buffer") }
    CVPixelBufferLockBaseAddress(pixel, [])
    let ctx = CGContext(
      data: CVPixelBufferGetBaseAddress(pixel),
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: CVPixelBufferGetBytesPerRow(pixel),
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    )
    if let ctx {
      ctx.interpolationQuality = .high
      let frame = CGRect(x: 0, y: 0, width: width, height: height)
      ctx.setFillColor(UIColor(red: 0.965, green: 0.937, blue: 0.890, alpha: 1).cgColor)
      ctx.fill(frame)
      func draw(_ img: UIImage, rect: CGRect, alpha: CGFloat) {
        guard let cg = img.cgImage else { return }
        ctx.saveGState()
        ctx.setAlpha(alpha)
        ctx.draw(cg, in: rect)
        ctx.restoreGState()
      }
      let fromRect = AVMakeRect(aspectRatio: image.size, insideRect: frame)
      switch type {
      case "slide":
        draw(image, rect: fromRect, alpha: 1)
        if let next {
          let dest = AVMakeRect(aspectRatio: next.size, insideRect: frame)
          draw(next, rect: dest.offsetBy(dx: dest.width * (1 - t), dy: 0), alpha: 1)
        }
      case "zoom":
        draw(image, rect: fromRect.insetBy(dx: -fromRect.width * 0.08 * t, dy: -fromRect.height * 0.08 * t), alpha: 1 - t * 0.35)
        if let next {
          let dest = AVMakeRect(aspectRatio: next.size, insideRect: frame)
          draw(next, rect: dest.insetBy(dx: dest.width * 0.12 * (1 - t), dy: dest.height * 0.12 * (1 - t)), alpha: t)
        }
      case "crossfade":
        draw(image, rect: fromRect, alpha: 1 - t)
        if let next {
          draw(next, rect: AVMakeRect(aspectRatio: next.size, insideRect: frame), alpha: t)
        }
      default:
        draw(image, rect: fromRect, alpha: 1)
      }
    }
    CVPixelBufferUnlockBaseAddress(pixel, [])
    return pixel
  }
}
