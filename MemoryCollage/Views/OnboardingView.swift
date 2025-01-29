//
//  OnboardingView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/26/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    @Binding var isOnboardingComplete: Bool
    @State private var navigateToMainApp = false // Navigation trigger
    
    private let onboardingPages = [
        OnboardingPage(image: "photo", title: "Create Stunning Collages", description: "Combine your favorite memories into beautiful collages easily!"),
        OnboardingPage(image: "wand.and.stars", title: "Apply Templates", description: "Choose from a variety of customizable templates to suit your style."),
        OnboardingPage(image: "square.and.arrow.up", title: "Share Effortlessly", description: "Save or share your creations directly with friends and family.")
    ]

    var body: some View {
        if navigateToMainApp {
            MainAppView()
        }else {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \ .self) { index in
                            let page = onboardingPages[index]
                            
                            VStack(spacing: 20) {
                                Image(systemName: page.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.white)
                                
                                Text(page.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(page.description)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                            withAnimation {
                                           navigateToMainApp = true
                                       }
                          
                        }
                        
                    }) {
                        Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        @State  var showOnboarding = false
        OnboardingView(isOnboardingComplete: $showOnboarding)
    }
}

