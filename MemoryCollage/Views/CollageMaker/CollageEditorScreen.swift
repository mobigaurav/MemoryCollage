//
//  CollageEditorScreen_old.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/24/25.
//

import Foundation
import SwiftUI

struct CollageEditorScreen: View {
    @State var selectedImages: [UIImage]
    @State private var draggableImages: [DraggableImage] = []
    @State private var selectedTemplate: Template = TemplateManager.shared.templates.first!
    @State private var textOverlays: [TextOverlay] = []
    @State private var showTemplatePicker = false
    @State private var showTextEditor = false
    @State private var activeTextOverlayIndex: Int? = nil
    @State private var radiusScale: CGFloat = 1.0 // Default radius scale
    //@State private var selectedResolution: ExportResolution = .standard
    @State private var selectedFormat: ExportFormat = .jpeg
    @State private var showExportAlert = false
    @State private var selectedResolution: String = "High"
    @State private var selectedImageType: String = "JPEG"
    @State private var backgroundColor: Color = .gray
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollableImages: [ScrollableImage] = []
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        // Render Template
                        renderTemplate(in: geometry.size)
                        
                        // Text Overlays with Drag Gesture
                        ForEach($textOverlays.indices, id: \.self) { index in
                            if textOverlays[index].isEditing {
                                TextField("", text: $textOverlays[index].text)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(5)
                                    .frame(width: 150) // Set text field width
                                    .position(textOverlays[index].position)
                                    .offset(y: keyboardHeight > 0 && textOverlays[index].position.y > UIScreen.main.bounds.height - keyboardHeight - 50
                                            ? -keyboardHeight / 2 : 0)
                                    .onSubmit {
                                        textOverlays[index].isEditing = false // Exit editing mode
                                    }
                            } else {
                                Text(textOverlays[index].text)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(5)
                                    .position(textOverlays[index].position)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                textOverlays[index].position = value.location
                                            }
                                    )
                                    .onTapGesture {
                                        textOverlays[index].isEditing = true // Enter editing mode
                                    }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                
                // Horizontal Scrollable Templates
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TemplateManager.shared.templates) { template in
                            TemplateThumbnailButton(
                                template: template,
                                isSelected: template.id == selectedTemplate.id,
                                images:selectedImages
                            ) {
                                withAnimation {
                                    selectedTemplate = template
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
                .padding(.horizontal)
                .frame(height: 80)
                
                // Buttons for Adding Text and Saving Collage
                // Toolbar
                ToolbarView(
                    selectedResolution: $selectedResolution,
                    selectedImageType: $selectedImageType,
                    onAddText: { addTextOverlay() },
                    onSaveImage: { exportCollage() },
                    onShareImage: { exportCollage(shouldShare: true) },
                    onShuffle: { shuffleImages() }
                )
                .padding(.vertical)
                
            }
            .navigationTitle("Edit Collage")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                dismiss() // Dismiss the full-screen modal
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.system(size: 18, weight: .medium))
                Text("Back")
            })
            .onAppear {
                DispatchQueue.main.async {
                    initializeDraggableImages()
                }
                addKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
    }
    
    private func shuffleImages() {
        selectedImages.shuffle() // Shuffle the selected images
        initializeDraggableImages() // Reinitialize draggable images
    }
    
    func getFrame(for index: Int, canvasSize: CGSize) -> CGRect {
        switch selectedTemplate.type {
        case .circle:
            let circleLayout = TemplateManager.shared.circularLayout(for: selectedImages.count, in: canvasSize, radiusScale: radiusScale)
            return circleLayout[index % circleLayout.count]
            
        case .grid(let rows, let columns):
            // Calculate the cell width
            let cellWidth = canvasSize.width / CGFloat(columns)
            let totalImages = selectedImages.count
            
            // Calculate rows to fill dynamically based on selected images
            let rowsToFill = max(1, (totalImages + columns - 1) / columns)
            let cellHeight = canvasSize.height / CGFloat(rowsToFill) // Expand height if fewer images
            
            // Determine the row and column for the current index
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
                let starLayout = TemplateManager.shared.starLayout(for: selectedImages.count, in: canvasSize)
                return starLayout[index % starLayout.count]
            case "Triangle":
                let triangleLayout = TemplateManager.shared.triangleLayout(for: selectedImages.count, in: canvasSize)
                return triangleLayout[index % triangleLayout.count]
            case "Diamond":
                let diamondLayout = TemplateManager.shared.diamondLayout(for: selectedImages.count, in: canvasSize)
                return diamondLayout[index % diamondLayout.count]
            case "Heart":
                let heartLayout = TemplateManager.shared.createHeartLayout(for: selectedImages.count, in: canvasSize)
                return heartLayout[index % heartLayout.count]
            case "Flower":
                let flowerLayout = TemplateManager.shared.createFlowerLayout(for: selectedImages.count, in: canvasSize)
                return flowerLayout[index % flowerLayout.count]
              
            case "Spiral":
                let spiralLayout = TemplateManager.shared.createSpiralLayout(for: selectedImages.count, in: canvasSize)
                return spiralLayout[index % spiralLayout.count]
             
            default:
                return CGRect.zero
            }
        default:
            guard !selectedTemplate.layout.isEmpty else {
                // Return a default CGRect if the layout is empty
                return CGRect.zero
            }
            let rect = selectedTemplate.layout[index % selectedTemplate.layout.count]
            return CGRect(
                x: rect.origin.x * canvasSize.width,
                y: rect.origin.y * canvasSize.height,
                width: rect.width * canvasSize.width,
                height: rect.height * canvasSize.height
            )
        }
    }
    
    private func initializeDraggableImages() {
        scrollableImages = selectedImages.map { ScrollableImage(image: $0, offset: .zero) }
    }
    
    private func renderTemplate(in canvasSize: CGSize) -> some View {
        ZStack {
            if selectedTemplate.type == .freeform {
                ForEach($scrollableImages) { $scrollableImage in
                    ScrollView([.horizontal, .vertical]) {
                        Image(uiImage: scrollableImage.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .offset(scrollableImage.offset)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    scrollableImage.offset = CGSize(
                                        width: value.translation.width,
                                        height: value.translation.height
                                    )
                                }
                            )
                    }
                    .frame(width: 200, height: 200)
                    .clipped()
                }
            } else {
                ForEach(0..<selectedImages.count, id: \.self) { index in
                    if index < scrollableImages.count {  // Prevent out-of-bounds access
                        let frame = getFrame(for: index, canvasSize: canvasSize)
                        
                        ScrollView([.horizontal, .vertical]) {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: frame.width * 1.5, height: frame.height * 1.5)
                                .offset(scrollableImages[index].offset) // Apply stored scroll offsets
                        }
                        .frame(width: frame.width, height: frame.height)
                        .clipped()
                        .position(x: frame.midX, y: frame.midY)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }


    
    private func calculateBoundingRect(using canvasSize: CGSize) -> CGRect {
        var boundingRect: CGRect = .null
        
        // Include image frames
        if selectedTemplate.type == .freeform {
            // Use draggableImages positions for freeform collage
            for draggableImage in draggableImages {
                let imageFrame = CGRect(
                    x: draggableImage.position.x - 50, // Adjust position based on image size
                    y: draggableImage.position.y - 50,
                    width: 100, // Default image width
                    height: 100 // Default image height
                )
                boundingRect = boundingRect.union(imageFrame)
            }
        } else {
            // Include image frames for other templates
            for index in 0..<selectedImages.count {
                let frame = getFrame(for: index, canvasSize: canvasSize)
                boundingRect = boundingRect.union(frame)
            }
        }
        
        // Include text overlay frames
        for textOverlay in textOverlays {
            let textFrame = CGRect(
                origin: textOverlay.position,
                size: CGSize(width: 150, height: 50) // Adjust size based on font and text
            )
            boundingRect = boundingRect.union(textFrame)
        }
        
        return boundingRect
    }
    

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addTextOverlay() {
        let newOverlay = TextOverlay(text: "New Text", position: CGPoint(x: 100, y: 100))
        textOverlays.append(newOverlay)
        //activeTextOverlayIndex = textOverlays.count - 1
        // showTextEditor = true
    }
    
    private func showPaywallModal() {
        let paywallView = UIHostingController(rootView: PaywallView())
        UIApplication.shared.windows.first?.rootViewController?.present(paywallView, animated: true)
    }
    
    private func captureCollage(contentSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let boundingRect = calculateBoundingRect(using: contentSize)

        let collageView = CollageCaptureView(contentSize: boundingRect.size, content: {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                ForEach(0..<selectedImages.count, id: \.self) { index in
                    let frame = getFrame(for: index, canvasSize: contentSize)
                    
                    Image(uiImage: selectedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: frame.width * 1.5, height: frame.height * 1.5)
                        .offset(scrollableImages[index].offset) // Apply scroll offset
                        .frame(width: frame.width, height: frame.height)
                        .clipped()
                        .position(x: frame.midX, y: frame.midY)
                }

                // Text Overlays Corrected Positioning
                ForEach(textOverlays) { overlay in
                    Text(overlay.text)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(5)
                        .position(
                            x: overlay.position.x - boundingRect.origin.x,
                            y: overlay.position.y - boundingRect.origin.y
                        )
                }
                
              // Add watermark for free users
               if !UserDefaults.standard.bool(forKey: "hasPurchasedPremium") {
                   VStack {
                       Spacer()
                       Text("Memory Collage - Free Version")
                           .font(.caption)
                           .foregroundColor(.white.opacity(0.7))
                           .padding()
                           .background(Color.black.opacity(0.5))
                           .cornerRadius(8)
                           .padding(.bottom, 10)
                   }
               }
            }
        }, onCapture: { image in
            completion(image)
        })

        DispatchQueue.main.async {
            let hostingController = UIHostingController(rootView: collageView)
            hostingController.view.frame = CGRect(origin: .zero, size: contentSize)

            UIApplication.shared.windows.first?.rootViewController?.view.addSubview(hostingController.view)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hostingController.view.removeFromSuperview()
            }
        }
    }


    
    private func exportCollage(shouldShare: Bool = false) {
        // Check purchase status
        let hasPurchasedPremium = UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if let window = UIApplication.shared.windows.first {
                    let contentSize = window.rootViewController?.view.bounds.size ?? UIScreen.main.bounds.size
                    
                    self.captureCollage(contentSize: contentSize) { baseImage in
                        DispatchQueue.main.async {
                            var finalImage = baseImage

                            // Add watermark if not purchased
                            if !hasPurchasedPremium {
                                let alert = UIAlertController(
                                    title: "Created with Watermark!",
                                    message: "Your collage has been created with a watermark. Upgrade to premium to remove the watermark.",
                                    preferredStyle: .alert
                                )
                                
                                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                                    if shouldShare {
                                        self.shareCollage(image: finalImage)
                                    } else {
                                        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
                                        let saveAlert = UIAlertController(
                                            title: "Saved!",
                                            message: "Your collage with watermark has been saved to Photos. Upgrade to premium to remove the watermark.",
                                            preferredStyle: .alert
                                        )
                                        saveAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                        UIApplication.shared.windows.first?.rootViewController?.present(saveAlert, animated: true)
                                    }
                                }))
                                
                                alert.addAction(UIAlertAction(
                                    title: "Upgrade to Premium",
                                    style: .default,
                                    handler: { _ in
                                        self.showPaywallModal()
                                    }
                                ))
                                
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                                
                            } else {
                                if shouldShare {
                                    self.shareCollage(image: finalImage)
                                } else {
                                    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
                                    let alert = UIAlertController(
                                        title: "Saved!",
                                        message: "Your collage has been saved to Photos.",
                                        preferredStyle: .alert
                                    )
                                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }



    private func resetStateAfterSave() {
        textOverlays = textOverlays.map { overlay in
            var updatedOverlay = overlay
            updatedOverlay.isEditing = false
            return updatedOverlay
        }
        draggableImages = draggableImages // Reset draggable image positions if needed
    }
    
    func showExportConfirmation() {
        showExportAlert = true
    }
    
    func saveCollage(image: UIImage, format: ExportFormat) {
        switch format {
        case .jpeg:
            if let data = image.jpegData(compressionQuality: 1.0) {
                saveToPhotos(data: data, extension: "jpg")
            }
        case .png:
            if let data = image.pngData() {
                saveToPhotos(data: data, extension: "png")
            }
        }
    }
    
    func shareCollage(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func saveToPhotos(data: Data, extension fileExtension: String) {
        let filename = "\(UUID().uuidString).\(fileExtension)"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        // Share or save URL
    }
    
    
}

enum ExportFormat: String, CaseIterable {
    case jpeg = "JPEG"
    case png = "PNG"
    // case pdf = "PDF"
}

enum ExportResolution: String, CaseIterable {
    case standard = "Standard"
    case high = "High Resolution"
}



func getCanvasSize(for resolution: ExportResolution) -> CGSize {
    switch resolution {
    case .standard:
        return CGSize(width: 1080, height: 1080)
    case .high:
        return CGSize(width: 2160, height: 2160)
    }
}


struct AnyShape: Shape {
    private let pathClosure: (CGRect) -> Path
    
    init<S: Shape>(_ wrapped: S) {
        self.pathClosure = { rect in
            wrapped.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        pathClosure(rect)
    }
}


// Helper for optional binding
extension Binding {
    init<T>(_ source: Binding<T?>, replacingNilWith defaultValue: T) where Value == T {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

