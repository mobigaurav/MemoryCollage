//
//  TemplatePickerView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI

struct TemplatePickerView: View {
    @Binding var selectedTemplate: Template
    @Binding var isPresented: Bool // New binding to control visibility
    
    var body: some View {
        VStack {
            Text("Choose a Template")
                .font(.headline)
                .padding()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(TemplateManager.shared.templates) { template in
                        Button(action: {
                            selectedTemplate = template
                            isPresented = false
                        }) {
                            HStack {
                                Text(template.name)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()

                                Spacer()

                                if selectedTemplate.id == template.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .padding(.trailing, 10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(selectedTemplate.id == template.id ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
    }
}


