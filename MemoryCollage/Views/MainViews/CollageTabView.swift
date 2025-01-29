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
        NavigationView {
                    VStack {
                        PhotoSelectionScreen(purpose: "Collage") { selectedImages in
                            self.selectedImages = selectedImages
                            //print("selcted image", self.selectedImages)
                            // Trigger navigation only after updating images
                            navigateToCollageEditor = true
                        }
                        .navigationTitle("Collage Generator")
                        
                        // Use NavigationLink for seamless navigation
                        NavigationLink(
                            destination: CollageEditorScreen(selectedImages: selectedImages)
                                .navigationBarBackButtonHidden(true) // Back button for user navigation
                                .navigationBarTitleDisplayMode(.inline)
//                                .onAppear {
//                                        hideTabBar()
//                                    }
//                                    .onDisappear {
//                                        showTabBar()
//                                    },
                            ,
                            isActive: $navigateToCollageEditor
                        ) {
                            EmptyView() // Invisible link trigger
                        }
                    }
//                    .fullScreenCover(isPresented: $navigateToCollageEditor) {
//                                   CollageEditorScreen(selectedImages: selectedImages)
//                               }
                }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures smooth navigation behavior
            }
    
    // Helper Methods to Hide/Show Tab Bar
        private func hideTabBar() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
                return
            }
            tabBarController.tabBar.isHidden = true
        }

        private func showTabBar() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
                return
            }
            tabBarController.tabBar.isHidden = false
        }
}

#Preview {
    CollageTabView()
}
