//
//  CollageHelper.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/20/25.
//

import SwiftUI

class CollageHelper {
    static let shared = CollageHelper()
    var keyboardHeight: CGFloat = 0
    private var collageFrame: CGRect = .zero

    // **Store Collage Frame**
    func storeCollageFrame(from geometry: GeometryProxy) {
        DispatchQueue.main.async {
            self.collageFrame = geometry.frame(in: .global)
        }
    }

    // **Get Frame for Image Based on Selected Template**
//    func getFrame(for index: Int, in canvasSize: CGSize, template: Template, imagesCount: Int) -> CGRect {
//        return TemplateManager.shared.getFrame(for: index, canvasSize: canvasSize, template: template, imagesCount: imagesCount)
//    }

    // **Generate Gradient Background**
    func getGradientByID(_ id: Int) -> LinearGradient {
        let gradients: [Int: LinearGradient] = [
            0: LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
            1: LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            2: LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing),
            3: LinearGradient(colors: [.pink, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
        ]
        return gradients[id] ?? LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
    }

    // **Process Final Image (Resize, Crop, Watermark)**
//    func processFinalImage(_ resolution: String, _ format: String, hasPremium: Bool) -> UIImage? {
//        if let screenshot = takeScreenshot(),
//           let croppedImage = cropImage(screenshot, to: collageFrame) {
//            let finalImage = hasPremium ? croppedImage : addWatermark(to: croppedImage)
//            return finalImage
//        }
//        return nil
//    }

    // **Take Screenshot**
    private func takeScreenshot() -> UIImage? {
        let window = UIApplication.shared.windows.first
        let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? .zero)
        return renderer.image { _ in
            window?.drawHierarchy(in: window?.bounds ?? .zero, afterScreenUpdates: true)
        }
    }

    // **Crop Image to Collage Frame**
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let scale = image.scale
        let adjustedRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.width * scale, height: rect.height * scale)
        return cgImage.cropping(to: adjustedRect).flatMap { UIImage(cgImage: $0, scale: scale, orientation: image.imageOrientation) }
    }

//    // **Add Watermark**
//    private func addWatermark(to image: UIImage) -> UIImage {
//        return WatermarkUtility.addWatermark(to: image)
//    }
}

