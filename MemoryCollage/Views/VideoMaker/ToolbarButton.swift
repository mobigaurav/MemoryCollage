//
//  ToolbarButton.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/13/25.
//

import SwiftUI

struct ToolbarButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .padding()
                    .background(Circle().fill(color))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.black)
            }
        }
    }
}

