//
//  TemplateThumbnailButton.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import Foundation
import SwiftUI

struct TemplateThumbnailButton: View {
    let template: Template
    let isSelected: Bool
    let images:[UIImage]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                DynamicThumbnailView(template: template, images: images)
                    .frame(width: 80, height: 80)
                    .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                Text(template.name)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .blue : .black)
            }
        }
        .frame(width: 100)
        .padding(5)
    }
}

