//
//  MainAppView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import SwiftUI

struct MainAppView:View {
    var body:some View {
        TabView {
            CollageTabView()
                            .tabItem {
                                Label("Collage", systemImage: "photo")
                            }

                        VideoTabView()
                            .tabItem {
                                Label("Videos", systemImage: "film")
                            }

        }
    }
}
