//
//  PhotoSelectionScreen.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI

struct PhotoSelectionScreen: View {
    @State private var selectedImages: [UIImage] = []
    @State private var pickerSelection = false
    var purpose:String
    var onNext: ([UIImage]) -> Void // Closure for handling navigation

    var body: some View {
        NavigationView {
            VStack {
                if selectedImages.isEmpty {
                    VStack(spacing: 16) {
                        Text("Add photos for \(purpose)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                pickerSelection = true
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                
                // Floating Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            // Next Button
                            Button(action: {
                                if !selectedImages.isEmpty {
                                    print("Selected images count: \(selectedImages.count)")
                                    onNext(selectedImages)
                                } else {
                                    print("No images selected!")
                                }
                            }) {
                                Image(systemName: "arrow.forward.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(selectedImages.isEmpty ? .gray : .blue)
                            }
                            .disabled(selectedImages.isEmpty)
                            
                            // Image Upload Button
                            Button(action: {
                            //if selectedImages.count < 2{
                                  pickerSelection = true
                             // }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                            //.disabled(pickerSelection || selectedImages.count >= 10)
                        }
                        .padding()
                    }
                }
            }
       


            //.navigationTitle("Select Photos")
            .sheet(isPresented: $pickerSelection) {
                            PhotoSelectionView(selectedImages: $selectedImages)
                        }
        }
    }
}

#Preview {
    PhotoSelectionScreen(
                         purpose: "Collage",
                         onNext: {_ in })
}



