//
//  ScrollOffsetPreferenceKey.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/28/25.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]
    
    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct ScrollableImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var offset: CGSize = .zero
}

