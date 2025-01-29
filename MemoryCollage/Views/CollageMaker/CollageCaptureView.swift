//
//  CollageCaptureView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import SwiftUI

struct CollageCaptureView<Content: View>: UIViewRepresentable {
    let content: Content
    let contentSize: CGSize // Add content size to control rendering dimensions
    let onCapture: (UIImage) -> Void

    init(contentSize: CGSize, @ViewBuilder content: () -> Content, onCapture: @escaping (UIImage) -> Void) {
        self.content = content()
        self.contentSize = contentSize
        self.onCapture = onCapture
    }

    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView(frame: CGRect(origin: .zero, size: contentSize))
        containerView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        captureImage(from: uiView)
    }

    private func captureImage(from view: UIView) {
        DispatchQueue.main.async {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                onCapture(image)
            } else {
                UIGraphicsEndImageContext()
            }
        }
    }
}



