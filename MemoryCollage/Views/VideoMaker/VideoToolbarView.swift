//
//  VideoToolbarView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/13/25.
//
import SwiftUI

struct VideoToolbarView: View {
    let onGenerateVideo: () -> Void
    let onShareVideo: (() -> Void)?

    @Binding var selectedFilter: String 
   // @Binding var selectedTransition: String
    
    let filters = ["None", "Sepia", "Vignette", "Noir", "Bloom", "Instant", "Comic"]
    let transitions = ["Crossfade", "Slide", "Zoom"]
    var body: some View {
        HStack(spacing: 16) {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(filters, id: \.self) { filter in
                    Text(filter).tag(filter)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 120)
            
//            Picker("Transition", selection: $selectedTransition) {
//                            ForEach(transitions, id: \.self) { transition in
//                                Text(transition).tag(transition)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                        .frame(width: 110)

            ToolbarButton(title: "",
                          icon: "video.badge.plus",
                          color: .blue,
                          action: onGenerateVideo)
            ToolbarButton(
                           title: "",
                           icon: "square.and.arrow.up",
                           color: videoGenerated ? .pink : .gray,
                           action: {
                               onShareVideo?()
                           }
                       )
                       .disabled(!videoGenerated) 
        }
        .padding()
        .frame(height: 90)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    var videoGenerated: Bool {
            return onShareVideo != nil
        }
}


