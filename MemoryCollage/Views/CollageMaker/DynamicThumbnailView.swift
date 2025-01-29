//
//  DynamicThumbnailView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//
import SwiftUI

struct DynamicThumbnailView: View {
    let template: Template
    let sampleImages: [UIImage] = [
        UIImage(systemName: "photo")!,  // Replace with actual sample images
        UIImage(systemName: "photo.fill")!,
        UIImage(systemName: "photo.on.rectangle")!
    ]
    let images: [UIImage]

    var body: some View {
        GeometryReader { geometry in
            renderTemplate(in: geometry.size)
        }
    }

    @ViewBuilder
    private func renderTemplate(in canvasSize: CGSize) -> some View {
        ZStack {
            ForEach(0..<images.count, id: \.self) { index in
                templateFrame(for: index, in: canvasSize, image: images[index])
            }
        }
    }

    @ViewBuilder
    private func templateFrame(for index: Int, in canvasSize: CGSize, image:UIImage) -> some View {
        if let frame = getFrame(for: index, in: canvasSize) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: frame.width, height: frame.height)
                .applyClipShape(for: template.type)
                .clipped()
                .position(x: frame.midX, y: frame.midY)
        }
    }

    private func getFrame(for index: Int, in canvasSize: CGSize) -> CGRect? {
        switch template.type {
        case .circle:
            let circleLayout = TemplateManager.shared.circularLayout(for: images.count, in: canvasSize)
            return circleLayout[safe: index]
        case .customShape(let shape):
            switch shape {
            case "Star":
                return TemplateManager.shared.starLayout(for: images.count, in: canvasSize)[safe: index]
            case "Triangle":
                return TemplateManager.shared.triangleLayout(for: images.count, in: canvasSize)[safe: index]
            case "Diamond":
                return TemplateManager.shared.diamondLayout(for: images.count, in: canvasSize)[safe: index]
            case "Heart":
               return TemplateManager.shared.createHeartLayout(for: images.count, in: canvasSize)[safe: index]
               
            case "Flower":
                return TemplateManager.shared.createFlowerLayout(for: images.count, in: canvasSize)[safe: index]
               
//            case "Starburst":
//                let starburstLayout = TemplateManager.shared.generateStarburstLayout(for: selectedImages.count)
//                return starburstLayout[index % starburstLayout.count]
//            case "Wave":
//                let waveLayout = TemplateManager.shared.generateWaveLayout(for: selectedImages.count)
//                return waveLayout[index % waveLayout.count]
//            case "Hexagon":
//                let hexagonLayout = TemplateManager.shared.createHexagonLayout()
//                return hexagonLayout[index % hexagonLayout.count]
//            case "Arrow":
//                let arrowLayout = TemplateManager.shared.createArrowLayout()
//                return arrowLayout[index % arrowLayout.count]
//            case "Zigzag":
//                let zigzagLayout = TemplateManager.shared.createZigzagLayout()
//                return zigzagLayout[index % zigzagLayout.count]
//            case "Ladder":
//                let ladderLayout = TemplateManager.shared.createLadderLayout()
//                return ladderLayout[index % ladderLayout.count]
//            case "Diamond Grid":
//                let diamondGridLayout = TemplateManager.shared.createDiamondGridLayout()
//                return diamondGridLayout[index % diamondGridLayout.count]
            case "Spiral":
                return TemplateManager.shared.createSpiralLayout(for: images.count, in: canvasSize)[safe: index]
               
//            case "Checkerboard":
//                let checkerboardLayout = TemplateManager.shared.createCheckerboardLayout()
//                return checkerboardLayout[index % checkerboardLayout.count]
//            case "Infinity":
//                let infinityLayout = TemplateManager.shared.createInfinityLayout()
//                return infinityLayout[index % infinityLayout.count]
            default:
                return nil
            }
        default:
            guard index < template.layout.count else { return nil }
            let rect = template.layout[index]
            return CGRect(
                x: rect.origin.x * canvasSize.width,
                y: rect.origin.y * canvasSize.height,
                width: rect.width * canvasSize.width,
                height: rect.height * canvasSize.height
            )
        }
    }
}

// Array safe indexing helper
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension View {
    func applyClipShape(for templateType: TemplateType) -> some View {
        Group {
            if templateType == .circle {
                self.clipShape(Circle())
            } else {
                self.clipShape(Rectangle())
            }
        }
    }
}


