//
//  VideoPlayerView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/21/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    
    var body:some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .frame(height: 300)
                .cornerRadius(10)
            
            Button(action: {
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, nil, nil, nil)
            }) {
                Text("DownloadVideos")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    let urlString:URL = URL(string: "https://google.com")!
    VideoPlayerView(videoURL: urlString)
}
