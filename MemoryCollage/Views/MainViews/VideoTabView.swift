//
//  VideoTabView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI

struct VideoTabView: View {
    @State private var navigateToVideoGenerator = false
    @State private var selectedImages: [UIImage] = []
  

       var body: some View {
           NavigationView {
                      VStack {
                          PhotoSelectionScreen(purpose:"Videos") { selectedImages in
                              self.selectedImages = selectedImages
                              navigateToVideoGenerator = true
                          }
                          NavigationLink(
                            destination: VideoGeneratorView(
                                                   selectedImages: selectedImages
                                               ),
                              isActive: $navigateToVideoGenerator
                          ) {
                              EmptyView()
                          }
                      }
                      .navigationTitle("Video Generator")
                  }
              }
}


#Preview {
    VideoTabView()
}
