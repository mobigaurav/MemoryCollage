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
          case "encodeHeic":
            let args = call.arguments as? [String: Any] ?? [:]
            let bytes = args["bytes"] as? FlutterStandardTypedData
            let out = MemoryBookEncoder.encodeHeic(bytes?.data ?? Data())
            DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: out)) }
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
    let loaded = paths.compactMap { UIImage(contentsOfFile: $0) }.map { applyFilter($0, filter) }
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

  private static func mix(video: String, audio: String) throws -> String {
    let mixUrl = URL(fileURLWithPath: video).deletingPathExtension().appendingPathExtension("mixed.mp4")
    try? FileManager.default.removeItem(at: mixUrl)
    let composition = AVMutableComposition()
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: video))
    let audioAsset = AVURLAsset(url: URL(fileURLWithPath: audio))
    guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else { return video }
    let v = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    try v?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)
    if let aTrack = audioAsset.tracks(withMediaType: .audio).first {
      let a = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
      try a?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: aTrack, at: .zero)
    }
    guard let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
      return video
    }
    session.outputURL = mixUrl
    session.outputFileType = .mp4
    let sema = DispatchSemaphore(value: 0)
    session.exportAsynchronously { sema.signal() }
    sema.wait()
    return session.status == .completed ? mixUrl.path : video
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
