//
//  MainAppView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import SwiftUI

struct MainAppView:View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Slight transparency
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    
       
}

struct SidebarView: View {
    var body: some View {
           List {
               NavigationLink(destination: CollageTabView()) {
                   Label("Collage", systemImage: "photo")
               }
               NavigationLink(destination: VideoTabView()) {
                   Label("Videos", systemImage: "film")
               }
           }
           .navigationTitle("MemoryCollage")
       }
}
