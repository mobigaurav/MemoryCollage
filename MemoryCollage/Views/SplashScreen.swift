//
//  SplashScreen.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/26/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var showOnboarding = false
    @State private var logoOpacity = 0.0
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity = 0.0

    var body: some View {
        if isActive {
            if showOnboarding {
                OnboardingView(isOnboardingComplete: $isActive)
                //OnboardingView()
            } else {
                MainAppView()
            }
        } else {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Logo Animation
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                        .opacity(logoOpacity)
                        .scaleEffect(titleScale)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0)) {
                                logoOpacity = 1.0
                                titleScale = 1.0
                            }
                        }

                    // Title Animation
                    Text("Memory Collage")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(titleOpacity)
                        .onAppear {
                            withAnimation(.easeIn.delay(1.0)) {
                                titleOpacity = 1.0
                            }
                        }
                }
            }
            .onAppear {
                showOnboarding = !UserDefaults.standard.bool(forKey: "isOnboardingComplete")
                // Transition to MainAppView after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
