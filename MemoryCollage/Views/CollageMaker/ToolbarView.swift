//
//  ToolbarView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import SwiftUI
struct ToolbarView: View {
    @Binding var selectedResolution: String
    @Binding var selectedImageType: String
    var onAddText: () -> Void
    var onSaveImage: () -> Void
    var onShareImage: () -> Void
    let onShuffle: () -> Void
    //var onPreview: () -> Void // New parameter for the preview action
    
    let resolutions = ["Low", "Medium", "High"]
    let imageTypes = ["JPEG", "PNG", "HEIC"]

    var body: some View {
        HStack(spacing: 15) {
            // Add Text
            Button(action: onAddText) {
                VStack {
                    Image(systemName: "textformat")
                        .font(.system(size: 20))
                    Text("Text")
                        .font(.caption2)
                }
            }

            // Save Image
            Button(action: onSaveImage) {
                VStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20))
                    Text("Save")
                        .font(.caption2)
                }
            }
        

            // Share Image
            Button(action: onShareImage) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                    Text("Share")
                        .font(.caption2)
                }
            }

            // Resolution Picker
            Menu {
                ForEach(resolutions, id: \.self) { resolution in
                    Button(action: {
                        selectedResolution = resolution
                    }) {
                        Text(resolution)
                    }
                }
            } label: {
                VStack {
                    Image(systemName: "aspectratio")
                        .font(.system(size: 20))
                    Text(selectedResolution)
                        .font(.caption2)
                }
            }
            
            Button(action: onShuffle) {
                            Image(systemName: "shuffle")
                                .font(.title2)
                        }

            // Image Type Picker
            Menu {
                ForEach(imageTypes, id: \.self) { type in
                    Button(action: {
                        selectedImageType = type
                    }) {
                        Text(type)
                    }
                }
            } label: {
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text(selectedImageType)
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(height: 80)
    }
}

