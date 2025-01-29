////
////  CollageEditorScreen.swift
////  MemoryCollage
////
////  Created by Gaurav Kumar on 12/31/24.
////
//
//import SwiftUI
//
//struct CollageEditorScreen: View {
//    @State var selectedImages: [UIImage]
//    @State private var draggableImages: [DraggableImage] = []
//    @State private var selectedTemplate: Template = TemplateManager.shared.templates.first!
//    @State private var textOverlays: [TextOverlay] = []
//    @State private var showTemplatePicker = false
//    @State private var showExportAlert = false
//    @State private var selectedResolution: String = "High"
//    @State private var selectedFormat: ExportFormat = .jpeg
//    @State private var keyboardHeight: CGFloat = 0
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
//
//                VStack(spacing: 0) {
//                    // Collage Canvas
//                    GeometryReader { geometry in
//                        ZStack {
//                            Color.white
//                                .cornerRadius(12)
//                                .shadow(radius: 8)
//                                .padding()
//
//                            renderTemplate(in: geometry.size)
//
//                            // Text Overlays
//                            // Text Overlays
//                            ForEach($textOverlays.indices, id: \.self) { index in
//                                if textOverlays[index].isEditing {
//                                    TextField("", text: $textOverlays[index].text)
//                                        .font(.headline)
//                                        .foregroundColor(.black)
//                                        .padding(5)
//                                        .background(Color.white.opacity(0.8))
//                                        .cornerRadius(5)
//                                        .frame(maxWidth: 200)
//                                        .position(textOverlays[index].position)
//                                        .offset(y: keyboardHeight > 0 && textOverlays[index].position.y > UIScreen.main.bounds.height - keyboardHeight - 50 ? -keyboardHeight / 2 : 0)
//                                        .onSubmit {
//                                            textOverlays[index].isEditing = false
//                                        }
//                                } else {
//                                    Text(textOverlays[index].text)
//                                        .font(.headline)
//                                        .foregroundColor(.black)
//                                        .padding(5)
//                                        .background(Color.white.opacity(0.8))
//                                        .cornerRadius(5)
//                                        .position(textOverlays[index].position)
//                                        .gesture(
//                                            DragGesture()
//                                                .onChanged { value in
//                                                    textOverlays[index].position = value.location
//                                                }
//                                        )
//                                        .onTapGesture {
//                                            textOverlays[index].isEditing = true
//                                        }
//                                }
//                            }
//                        }
//                    }
//
//                    // Template Selection and Toolbar
//                    VStack(spacing: 10) {
//                        // Horizontal Template Selection
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 10) {
//                                ForEach(TemplateManager.shared.templates) { template in
//                                    TemplateThumbnailButton(
//                                        template: template,
//                                        isSelected: template.id == selectedTemplate.id
//                                    ) {
//                                        withAnimation {
//                                            selectedTemplate = template
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        .frame(height: 80)
//
//                        // Vertical Toolbar
//                        HStack(spacing: 20) {
//                                            Button(action: {
//                                                addTextOverlay()
//                                            }) {
//                                                Image(systemName: "textformat")
//                                                    .font(.system(size: 24))
//                                                    .foregroundColor(.blue)
//                                            }
//
//                                            Button(action: {
//                                                exportCollage()
//                                            }) {
//                                                Image(systemName: "square.and.arrow.down")
//                                                    .font(.system(size: 24))
//                                                    .foregroundColor(.blue)
//                                            }
//
//                                            Button(action: {
//                                                showTemplatePicker = true
//                                            }) {
//                                                Image(systemName: "eye")
//                                                    .font(.system(size: 24))
//                                                    .foregroundColor(.blue)
//                                            }
//
//                                            Button(action: {
//                                                exportCollage(shouldShare: true)
//                                            }) {
//                                                Image(systemName: "square.and.arrow.up")
//                                                    .font(.system(size: 24))
//                                                    .foregroundColor(.blue)
//                                            }
//                                        }
//                                        .padding()
//                                        .background(Color.white)
//                    }
//                    .background(Color.white)
//                }
//            }
//            .navigationTitle("Collage Editor")
//            .navigationBarTitleDisplayMode(.inline)
//               .navigationBarItems(leading: Button(action: {
//                   dismiss() // Dismiss the full-screen modal
//               }) {
//                   Image(systemName: "chevron.left")
//                       .foregroundColor(.blue)
//                       .font(.system(size: 18, weight: .medium))
//                   Text("Back")
//               })
//            .sheet(isPresented: $showTemplatePicker) {
//                TemplatePickerView(selectedTemplate: $selectedTemplate, isPresented: $showTemplatePicker)
//            }
//            .onAppear {
//                initializeDraggableImages()
//                addKeyboardObservers()
//            }
//            .onDisappear {
//                removeKeyboardObservers()
//            }
//        }
//    }
//
//    private func renderTemplate(in canvasSize: CGSize) -> some View {
//        ZStack {
//            if selectedTemplate.type == .freeform {
//                ForEach(draggableImages) { draggableImage in
//                    Image(uiImage: draggableImage.image)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 100)
//                        .position(draggableImage.position)
//                        .scaleEffect(draggableImage.scale)
//                        .gesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    if let index = draggableImages.firstIndex(where: { $0.id == draggableImage.id }) {
//                                        draggableImages[index].position = value.location
//                                    }
//                                }
//                                .simultaneously(with: MagnificationGesture()
//                                    .onChanged { value in
//                                        if let index = draggableImages.firstIndex(where: { $0.id == draggableImage.id }) {
//                                            draggableImages[index].scale = value
//                                        }
//                                    }
//                                )
//                        )
//                }
//            } else {
//                ForEach(0..<selectedImages.count, id: \.self) { index in
//                    let frame = getFrame(for: index, canvasSize: canvasSize)
//                    Image(uiImage: selectedImages[index])
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: frame.width, height: frame.height)
//                        .clipped()
//                        .position(x: frame.midX, y: frame.midY)
//                }
//            }
//        }
//    }
//
//
//    private func addTextOverlay() {
//        let newOverlay = TextOverlay(text: "New Text", position: CGPoint(x: 100, y: 100))
//        textOverlays.append(newOverlay)
//    }
//
//    private func exportCollage(shouldShare: Bool = false) {
//        // Export logic
//    }
//
//    private func initializeDraggableImages() {
//        draggableImages = selectedImages.enumerated().map { index, image in
//            DraggableImage(image: image, position: CGPoint(x: 100 + index * 50, y: 100 + index * 50))
//        }
//    }
//
//    private func getFrame(for index: Int, canvasSize: CGSize) -> CGRect {
//          switch selectedTemplate.type {
//          case .circle:
//              let circleLayout = TemplateManager.shared.circularLayout(for: selectedImages.count, in: canvasSize, radiusScale: 1.0)
//              return circleLayout[index % circleLayout.count]
//          case .customShape(let shape):
//              switch shape {
//              case "Star":
//                  let starLayout = TemplateManager.shared.starLayout(for: selectedImages.count, in: canvasSize)
//                  return starLayout[index % starLayout.count]
//              case "Triangle":
//                  let triangleLayout = TemplateManager.shared.triangleLayout(for: selectedImages.count, in: canvasSize)
//                  return triangleLayout[index % triangleLayout.count]
//              case "Diamond":
//                  let diamondLayout = TemplateManager.shared.diamondLayout(for: selectedImages.count, in: canvasSize)
//                  return diamondLayout[index % diamondLayout.count]
//              default:
//                  return CGRect.zero
//              }
//          default:
//              let rect = selectedTemplate.layout[index % selectedTemplate.layout.count]
//              return CGRect(
//                  x: rect.origin.x * canvasSize.width,
//                  y: rect.origin.y * canvasSize.height,
//                  width: rect.width * canvasSize.width,
//                  height: rect.height * canvasSize.height
//              )
//          }
//      }
//
//    private func addKeyboardObservers() {
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
//            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                keyboardHeight = keyboardFrame.height
//            }
//        }
//
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
//            keyboardHeight = 0
//        }
//    }
//
//    private func removeKeyboardObservers() {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//}
//
//// Supporting Structures
//struct DraggableImage: Identifiable {
//    let id = UUID()
//    var image: UIImage
//    var position: CGPoint
//    var scale: CGFloat = 1.0
//    var rotation: Angle = .zero
//}
//
//struct TextOverlay: Identifiable {
//    let id = UUID()
//    var text: String
//    var position: CGPoint
//    var isEditing: Bool = false
//}
//
//enum ExportFormat: String, CaseIterable {
//    case jpeg = "JPEG"
//    case png = "PNG"
//}
//
//struct ToolbarButton: View {
//    let icon: String
//    let label: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            VStack {
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .padding()
//                Text(label)
//                    .font(.caption)
//            }
//        }
//        .frame(width: 60, height: 60)
//        .background(Color(UIColor.systemGray6))
//        .cornerRadius(30)
//        .shadow(radius: 5)
//    }
//}
//
//
//
//
//
//
//
//
