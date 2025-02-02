//
//  CollageRendererView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/2/25.
//

import SwiftUI

struct CollageRendererView: UIViewRepresentable {
    var images: [UIImage]
    var scrollableImages: [ScrollableImage]
    var template: Template
    var background: UIColor
    var isGradient: Bool

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 1080, height: 1080))
        containerView.backgroundColor = background

        // Apply Gradient if Selected
        if isGradient {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
            gradientLayer.frame = containerView.bounds
            containerView.layer.insertSublayer(gradientLayer, at: 0)
        }

        for (index, image) in images.enumerated() {
            let frame = getFrame(for: index, canvasSize: containerView.bounds.size)

            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = frame
            imageView.clipsToBounds = true

            // Apply Scroll Offset
            if index < scrollableImages.count {
                let offset = scrollableImages[index].offset
                imageView.frame = imageView.frame.offsetBy(dx: offset.width, dy: offset.height)
            }

            containerView.addSubview(imageView)
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func captureSnapshot(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let hostingController = UIHostingController(rootView: self)
            let view = hostingController.view!
            view.frame = CGRect(origin: .zero, size: size)
            
            // Ensure proper layout
            let window = UIApplication.shared.windows.first!
            window.addSubview(view)
            view.layoutIfNeeded()
            
            // Render the view hierarchy into the image
            view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
            
            // Clean up after capturing
            view.removeFromSuperview()
        }
    }



    func getFrame(for index: Int, canvasSize: CGSize) -> CGRect {
        switch template.type {
        case .circle:
            let circleLayout = TemplateManager.shared.circularLayout(for: images.count, in: canvasSize)
            return circleLayout[index % circleLayout.count]
        case .grid(_, let columns):
            let cellWidth = canvasSize.width / CGFloat(columns)
            let totalImages = images.count
            let rowsToFill = max(1, (totalImages + columns - 1) / columns)
            let cellHeight = canvasSize.height / CGFloat(rowsToFill)
            let row = index / columns
            let column = index % columns
            return CGRect(
                x: CGFloat(column) * cellWidth,
                y: CGFloat(row) * cellHeight,
                width: cellWidth,
                height: cellHeight
            )
        case .customShape(let shape):
            switch shape {
            case "Star":
                let starLayout = TemplateManager.shared.starLayout(for: images.count, in: canvasSize)
                return starLayout[index % starLayout.count]
            case "Triangle":
                let triangleLayout = TemplateManager.shared.triangleLayout(for: images.count, in: canvasSize)
                return triangleLayout[index % triangleLayout.count]
            case "Diamond":
                let diamondLayout = TemplateManager.shared.diamondLayout(for: images.count, in: canvasSize)
                return diamondLayout[index % diamondLayout.count]
            default:
                return CGRect.zero
            }
        default:
            guard !template.layout.isEmpty else { return CGRect.zero }
            let rect = template.layout[index % template.layout.count]
            return CGRect(
                x: rect.origin.x * canvasSize.width,
                y: rect.origin.y * canvasSize.height,
                width: rect.width * canvasSize.width,
                height: rect.height * canvasSize.height
            )
        }
    }
}



