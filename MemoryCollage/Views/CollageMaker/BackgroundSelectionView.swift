//
//  BackgroundSelectionView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/1/25.
//

import SwiftUI

struct BackgroundSelectionView: View {
    @Binding var selectedBackground: Color
    @Binding var selectedGradient: Int?
    @Binding var isGradientSelected: Bool
    @Binding var isPresented: Bool

    let solidColors: [Color] = [.white, .black, .blue, .pink, .yellow, .gray]

    // Use an array of gradients with unique IDs
    let gradientOptions: [(id: Int, gradient: LinearGradient)] = [
        (0, LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)),
        (1, LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)),
        (2, LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .leading, endPoint: .trailing)),
        (3, LinearGradient(gradient: Gradient(colors: [.pink, .indigo]), startPoint: .bottomLeading, endPoint: .topTrailing))
    ]

    var body: some View {
        VStack {
            Text("Select Background Style")
                .font(.headline)
                .padding()

            // Solid Color Selection
            Text("Solid Colors")
                .font(.subheadline)
                .padding(.top)

            HStack(spacing: 15) {
                ForEach(solidColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: selectedBackground == color && !isGradientSelected ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedBackground = color
                            selectedGradient = nil
                            isGradientSelected = false
                            isPresented = false
                        }
                }
            }
            .padding()

            // Gradient Selection
            Text("Gradient Backgrounds")
                .font(.subheadline)
                .padding(.top)

            HStack(spacing: 15) {
                ForEach(gradientOptions, id: \.id) { gradientItem in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(gradientItem.gradient)
                        .frame(width: 60, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: selectedGradient == gradientItem.id ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedGradient = gradientItem.id
                            isGradientSelected = true
                            isPresented = false
                        }
                }
            }
            .padding()

            // Cancel Button
            Button("Cancel") {
                isPresented = false
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .padding()
    }
}

