//
//  AppleMusicPicker.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/3/25.
//

import Foundation
import SwiftUI
import MediaPlayer

struct AppleMusicPicker: UIViewControllerRepresentable {
    let onAudioSelected: (URL) -> Void

    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onAudioSelected: onAudioSelected)
    }

    class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: AppleMusicPicker
        let onAudioSelected: (URL) -> Void

        init(_ parent: AppleMusicPicker, onAudioSelected: @escaping (URL) -> Void) {
            self.parent = parent
            self.onAudioSelected = onAudioSelected
        }

        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            mediaPicker.dismiss(animated: true)

            if let item = mediaItemCollection.items.first, let url = item.assetURL {
                onAudioSelected(url)
            }
        }

        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            mediaPicker.dismiss(animated: true)
        }
    }
}

