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
    @ObservedObject var iapManager = IAPManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    enum ExportFormat: String, CaseIterable {
        case jpeg = "JPEG"
        case png = "PNG"
    }

    enum ExportResolution: String, CaseIterable {
        case standard = "Standard"
        case high = "High Resolution"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),  // Darker at the top for contrast
                            Color.purple.opacity(0.9),
                            Color.blue.opacity(0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                VStack {
//                    Text("Collage Generator")
//                                       .font(.largeTitle)
//                                       .fontWeight(.bold)
//                                       .foregroundColor(.white)
//                                       .shadow(radius: 5)
//                                       .padding(.top, 20)
//                                       .transition(.opacity)
//                                       .animation(.easeInOut(duration: 0.8))
                    
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
                               // Store the geometry size as collage frame
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
                .navigationTitle("Collage Editor")
                //.navigationTitle(Text("Collage Editor"), displayMode: .inline)
                .navigationBarTitleDisplayMode(.inline)
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
                    
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.clear // Keeps it aligned with gradient
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title in white
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Large title in white
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    UINavigationBar.appearance().tintColor = .white //
                    
                   
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .onDisappear {
                    removeKeyboardObservers()
                }
            }
          
        }
        
        .onChange(of: iapManager.purchaseState) { newState in
                   if newState == .purchased {
                       print("Purchase detected! Saving image without watermark...")
                       exportCollage()
                   }
               }
        
    }
    
    // **Background Layer**
       private func renderBackground(in canvasSize: CGSize) -> some View {
           ZStack {
               if isGradientSelected, let selectedGradientID = selectedGradient {
                   CollageHelper.shared.getGradientByID(selectedGradientID)
                       .frame(width: canvasSize.width, height: canvasSize.height)
               } else {
                   selectedBackground
                       .frame(width: canvasSize.width, height: canvasSize.height)
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
            if isGradientSelected, let selectedGradientID = selectedGradient {
                        getGradientByID(selectedGradientID)
                            .frame(width: canvasSize.width, height: canvasSize.height)
                            .clipped()
                    } else {
                        selectedBackground
                            .frame(width: canvasSize.width, height: canvasSize.height)
                            .clipped()
            }

            if selectedTemplate.type == .freeform {
                ForEach($scrollableImages) { $scrollableImage in
                    Image(uiImage: scrollableImage.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: scrollableImage.scale * 100, height: scrollableImage.scale * 100)
                        .position(scrollableImage.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    scrollableImage.position = value.location
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scrollableImage.scale = max(0.5, min(2.0, value))
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
                                .frame(width: frame.width * 1.5, height: frame.height * 1.5)
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
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    private func addWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
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
               let resolutionSize = getCanvasSize(for: selectedResolution)
                if let resizedImage = resizeImage(image: screenshot, targetSize: resolutionSize) ,
                    let croppedImage = cropImage(screenshot, to: collageFrame) {
                   let hasPurchasedPremium = UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
                  let finalImage = hasPurchasedPremium ? croppedImage : addWatermark(to: croppedImage)
                   handleFinalImage(finalImage, shouldShare: shouldShare)
               } else {
                   print("Failed to crop image correctly")
               }
           } else {
               print("Screenshot failed")
           }
        }
    }
    
    // Take a Screenshot of the Current View
    private func takeScreenshot() -> UIImage? {
        let window = UIApplication.shared.windows.first
        let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? .zero)
        return renderer.image { _ in
            window?.drawHierarchy(in: window?.bounds ?? .zero, afterScreenUpdates: true)
        }
    }
    
    // Find the CGRect of the Collage Content Inside GeometryReader
    private func findCollageContentFrame() -> CGRect {
       // let collageView = UIApplication.shared.windows.first?.rootViewController?.view
        //let collageFrame = collageView?.convert(collageView?.bounds ?? .zero, to: nil) ?? .zero
        return collageFrame
    }
    
    // Crop the Screenshot to the Collage Area
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
        let hasPurchasedPremium = IAPManager.shared.isPurchased()
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
                    saveCollageToPhotos(image)
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
                    self.shareCollage(image: image)
                } else {
                    self.saveCollageToPhotos(image)
                }
        }

    }
    
    private func saveCollageToPhotos(_ image: UIImage) {
        DispatchQueue.main.async {
            if let imageData = saveImage(image, format: selectedImageType) {
                let fileName = "collage.\(selectedImageType.lowercased())"
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try? imageData.write(to: url)

                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                let alert = UIAlertController(
                    title: "Saved!",
                    message: "Your collage has been saved in \(selectedImageType) format.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            } else {
                print("Error saving the image")
            }
        }
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
    }
    
    private func showPaywallModal() {
        let paywallView = UIHostingController(rootView: PaywallView())
        UIApplication.shared.windows.first?.rootViewController?.present(paywallView, animated: true)
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
    
    // Resizes an image to the selected resolution
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // Saves the image in the correct format (JPEG, PNG, HEIC)
    private func saveImage(_ image: UIImage, format: String) -> Data? {
        switch format {
        case "JPEG":
            return image.jpegData(compressionQuality: 1.0)
        case "PNG":
            return image.pngData()
        case "HEIC":
            if let heicData = image.jpegData(compressionQuality: 1.0) {
                return heicData
            }
            return nil
        default:
            return image.jpegData(compressionQuality: 1.0) // Default to JPEG
        }
    }
    
    private func getCanvasSize(for resolution: String) -> CGSize {
        switch resolution {
        case "Low":
            return CGSize(width: 720, height: 720)
        case "Medium":
            return CGSize(width: 1080, height: 1080)
        case "High":
            return CGSize(width: 2160, height: 2160)
        default:
            return CGSize(width: 1080, height: 1080) // Default to Medium
        }
    }
    
    
}


