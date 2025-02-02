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
    @State private var imageOffsets: [CGSize] = []
    @State private var geometrySize:CGSize = CGSize(width: 100, height: 100)
    @State private var selectedBackground: Color = .white
    @State private var selectedGradient: Int? = nil
    @State private var isGradientSelected = false
    @State private var showBackgroundSelection = false
    @State private var collageFrame: CGRect = .zero  // Store collage area
    
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
                    
                    .onAppear {
                           // ✅ Store the geometry size as collage frame
                           DispatchQueue.main.async {
                               self.collageFrame = geometry.frame(in: .global)
                           }
                       }
                }
                .frame(maxHeight: .infinity)
                
                
                // Horizontal Scrollable Templates
                ScrollView(.horizontal, showsIndicators: true) {
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
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .padding(.top, 10)
                .frame(height: 90)
                
                // Toolbar
                ToolbarView(
                    selectedResolution: $selectedResolution,
                    selectedImageType: $selectedImageType,
                    onAddText: { addTextOverlay() },
                    onSaveImage: { exportCollage() },
                    onShareImage: { exportCollage(shouldShare: true) },
                    onShuffle: { shuffleImages() },
                    onBackgroundColor: { displayBackgroundColorOptions() }
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
            .sheet(isPresented: $showBackgroundSelection) {
                BackgroundSelectionView(
                    selectedBackground: $selectedBackground,
                    selectedGradient: $selectedGradient,
                    isGradientSelected: $isGradientSelected,
                    isPresented: $showBackgroundSelection
                )
            }
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
    
    private func displayBackgroundColorOptions() {
        showBackgroundSelection = true
    }
    
    private func shuffleImages() {
        selectedImages.shuffle() // Shuffle the selected images
        initializeDraggableImages() // Reinitialize draggable images
    }
    
    private func initializeDraggableImages() {

        scrollableImages = selectedImages.enumerated().map { index, image in
               ScrollableImage(
                   image: image,
                   offset: .zero,
                   position: CGPoint(x: 150 + index * 50, y: 200 + index * 50)
               )
           }
           imageOffsets = Array(repeating: .zero, count: selectedImages.count)
    }
    
    private func getGradientByID(_ id: Int) -> LinearGradient {
        let gradientOptions: [Int: LinearGradient] = [
            0: LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom),
            1: LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing),
            2: LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .leading, endPoint: .trailing),
            3: LinearGradient(gradient: Gradient(colors: [.pink, .indigo]), startPoint: .bottomLeading, endPoint: .topTrailing)
        ]
        
        return gradientOptions[id] ?? LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .top, endPoint: .bottom)
    }
    
    func getFrame(for index: Int, canvasSize: CGSize) -> CGRect {
        switch selectedTemplate.type {
        case .circle:
            let circleLayout = TemplateManager.shared.circularLayout(for: selectedImages.count, in: canvasSize, radiusScale: radiusScale)
            return circleLayout[index % circleLayout.count]
            
        case .grid(_ , let columns):
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
    
    
    private func renderTemplate(in canvasSize: CGSize) -> some View {
        ZStack {
            // ✅ Apply Selected Background
            if isGradientSelected, let selectedGradientID = selectedGradient {
                let gradient = getGradientByID(selectedGradientID)
                gradient.edgesIgnoringSafeArea(.all)
            } else {
                selectedBackground.edgesIgnoringSafeArea(.all)
            }

          
            if selectedTemplate.type == .freeform {
                ForEach($scrollableImages) { $scrollableImage in
                    Image(uiImage: scrollableImage.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: scrollableImage.scale * 100, height: scrollableImage.scale * 100) // ✅ Dynamic Scaling
                        .position(scrollableImage.position) // ✅ Correctly place inside collage area
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    scrollableImage.position = value.location // ✅ Drag without affecting templates
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scrollableImage.scale = max(0.5, min(2.0, value)) // ✅ Scale within limits
                                }
                        )
                }
            }
            else {
                ForEach(0..<selectedImages.count, id: \.self) { index in
                    if index < scrollableImages.count {
                        let frame = getFrame(for: index, canvasSize: canvasSize)

                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: frame.width * 1.5, height: frame.height * 1.5) // Larger to allow scrolling
                                .offset(scrollableImages[index].offset)
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



    private func captureCollage(contentSize: CGSize, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let collageView = CollageRendererView(
                images: self.selectedImages,
                scrollableImages: self.scrollableImages,
                template: self.selectedTemplate,
                background: self.isGradientSelected ? UIColor.clear : UIColor.white,
                isGradient: self.isGradientSelected
            )

            // Ensure rendering happens on the main thread
            DispatchQueue.main.async {
                if let finalImage = collageView.captureSnapshot(size: contentSize) {
                    DispatchQueue.main.async {
                        completion(finalImage)
                    }
                } else {
                    print("⚠️ Snapshot failed!")
                }
            }
        }
    }

    


    private func addWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size)) // Draw the original image
            
            // Watermark attributes
            let watermarkText = "Memory Collage - Free Version"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 25),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                .backgroundColor: UIColor.black.withAlphaComponent(0.5)
            ]

            let textSize = watermarkText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: image.size.width - textSize.width - 20,
                y: image.size.height - textSize.height - 20,
                width: textSize.width,
                height: textSize.height
            )

            watermarkText.draw(in: textRect, withAttributes: attributes)
        }
    }


    private func exportCollage(shouldShare:Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let screenshot = takeScreenshot() {
               let collageFrame = findCollageContentFrame()
               
               if let croppedImage = cropImage(screenshot, to: collageFrame) {
                   let hasPurchasedPremium = UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
                   // Apply watermark only if not purchased
                  let finalImage = hasPurchasedPremium ? croppedImage : addWatermark(to: croppedImage)
                   handleFinalImage(finalImage, shouldShare: shouldShare)
               } else {
                   print("❌ Failed to crop image correctly")
               }
           } else {
               print("❌ Screenshot failed")
           }
        }
    }
    
    // 📸 Take a Screenshot of the Current View
    private func takeScreenshot() -> UIImage? {
        let window = UIApplication.shared.windows.first
        let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? .zero)
        return renderer.image { _ in
            window?.drawHierarchy(in: window?.bounds ?? .zero, afterScreenUpdates: true)
        }
    }
    
    // 📏 Find the CGRect of the Collage Content Inside GeometryReader
    private func findCollageContentFrame() -> CGRect {
       // let collageView = UIApplication.shared.windows.first?.rootViewController?.view
        //let collageFrame = collageView?.convert(collageView?.bounds ?? .zero, to: nil) ?? .zero
        return collageFrame
    }
    
    // ✂️ Crop the Screenshot to the Collage Area
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let scale = image.scale
        let adjustedRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        if let croppedCGImage = cgImage.cropping(to: adjustedRect) {
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: image.imageOrientation)
        }
        return nil
    }
    
    private func handleFinalImage(_ image: UIImage, shouldShare: Bool) {
        let hasPurchasedPremium = UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
        if !hasPurchasedPremium {
            let alert = UIAlertController(
                title: "Created with Watermark!",
                message: "Your collage has been created with a watermark. Upgrade to premium to remove the watermark.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                if shouldShare {
                    self.shareCollage(image: image)
                } else {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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

        }else {
                    if shouldShare {
                        shareCollage(image: image)
                    } else {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        print("✅ Collage saved successfully!")
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
    
    
    private func exportCollage1(shouldShare: Bool = false) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if let window = UIApplication.shared.windows.first {
                    let canvasSize = window.rootViewController?.view.bounds.size ?? UIScreen.main.bounds.size

                    self.captureCollage(contentSize: canvasSize) { baseImage in
                        DispatchQueue.main.async {
                            var finalImage = baseImage

                            // Handle watermark logic
                            let hasPurchasedPremium = UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
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

