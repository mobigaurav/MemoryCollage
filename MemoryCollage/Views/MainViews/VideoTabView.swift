//
//  VideoTabView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI

struct VideoTabView: View {
    @State private var navigateToVideoEditor = false
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // **Gradient Background**
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.9), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // **Title with Animation**
                    Text("Video Generator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top, 20)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.8))

                    // **Image Selection Section**
                    PhotoSelectionScreen(selectedImages: $selectedImages, purpose: "Video") 
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .shadow(radius: 5)
                    )
                    .padding()

                    Spacer()

                    // **Animated Generate Video Button**
                    Button(action: {
                        navigateToVideoEditor = true
                    }) {
                        Text("Start Creating!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.red, Color.orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .scaleEffect(navigateToVideoEditor ? 1.1 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6))
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToVideoEditor) {
                VideoGeneratorView(selectedImages: selectedImages)
            }
        }
    }
}



#Preview {
    VideoTabView()
}
