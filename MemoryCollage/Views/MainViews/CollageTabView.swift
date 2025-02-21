//
//  CollageTabView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI

struct CollageTabView: View {
    @State private var navigateToCollageEditor = false
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Collage Generator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top, 30)
                        .animation(.easeInOut(duration: 0.8))

                    PhotoSelectionScreen(selectedImages: $selectedImages, purpose: "Collage")
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .shadow(radius: 5)
                        )
                        .padding()

                    Spacer()

                    Button(action: {
                        navigateToCollageEditor = true
                    }) {
                        Text("Start Creating!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .scaleEffect(navigateToCollageEditor ? 1.1 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6))
                    }
                    .padding(.horizontal, 40)
                    .disabled(selectedImages.isEmpty) 
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToCollageEditor) {
                CollageEditorScreen(selectedImages: selectedImages)
            }
        }
    }
}



#Preview {
    CollageTabView()
}
