//
//  FreeformCollageView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI

struct FreeformCollageView: View {
    @State var images: [DraggableImage]
    var canvasSize: CGSize
    var body: some View {
            ZStack {
                ForEach($images) { $image in
                    Image(uiImage: image.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: canvasSize.width / 3, height: canvasSize.height / 4)
                        .clipped()
                        .cornerRadius(10)
                        .position(image.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    image.position = value.location
                                }
                        )
                }
            }
        }
}

//// Model for Draggable Images
struct DraggableImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
    var scale: CGFloat = 1.0 // Default scale factor
    var rotation: Angle = .zero // Default rotation
    var offset: CGSize = .zero
    var scrollOffset: CGSize = .zero
    
}

struct TextOverlay: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var isEditing: Bool = false
}

