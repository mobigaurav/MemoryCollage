//
//  VideoOptionsView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/13/25.
//

import SwiftUI

struct VideoOptionsView: View {
    @Binding var selectedFilter: String
    @Binding var selectedTransition: String
    let filters: [String]
    let transitions: [String]

    var body: some View {
        HStack {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(filters, id: \.self) { filter in
                    Text(filter).tag(filter)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Picker("Transition", selection: $selectedTransition) {
                ForEach(transitions, id: \.self) { transition in
                    Text(transition).tag(transition)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
        }
    }
}



