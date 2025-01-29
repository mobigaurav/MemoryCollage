//
//  TextFieldOverlayView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/1/25.
//

import SwiftUI
struct TextFieldOverlayView: View {
    @Binding var text: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Text")
                .font(.headline)
                .padding(.top)

            TextField("Enter text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Done") {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
}

