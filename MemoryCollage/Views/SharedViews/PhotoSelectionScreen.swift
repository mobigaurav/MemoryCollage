//
//  PhotoSelectionScreen.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI

struct PhotoSelectionScreen: View {
    @Binding var selectedImages: [UIImage] // Sync with CollageTabView
    @State private var pickerSelection = false
    var purpose: String

    var body: some View {
        NavigationStack {
            ZStack {
                // **Gradient Background**
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // **Title with Animation**
                    Text("Select Photos for \(purpose)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top, 30)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.8))

                    // **Selected Images Grid**
                    if selectedImages.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.white.opacity(0.8))
                                .onTapGesture {
                                    pickerSelection = true
                                } // Clickable Image opens Photo Picker
                                .scaleEffect(1.05)
                                .animation(.easeInOut(duration: 0.3))
                            
                            Text("Tap to add photos")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut, value: selectedImages.count)
                        
                        HStack(spacing: 20) {
                                    Button(action: {
                                        pickerSelection = true // Allow adding more photos
                                    }) {
                                        Label("Photos", systemImage: "plus.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }

                                    Button(action: {
                                        selectedImages.removeAll() // Clear selection
                                    }) {
                                        Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 10)
                    }

                    Spacer()
                }
                .padding()
            }

            .sheet(isPresented: $pickerSelection) {
                PhotoSelectionView(selectedImages: $selectedImages)
            }
            .onChange(of: selectedImages) { images in
                print("Selected images count: \(images.count)")
            }
        }
    }
}






