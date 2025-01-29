//
//  GridCollageView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI

struct GridCollageView: View {
    var images: [UIImage]
    var canvasSize: CGSize
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: canvasSize.width / 2 - 10, height: canvasSize.height / 4)
                    .clipped()
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

