//
//  DocumentPicker.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/13/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation
//import FileHelper

struct DocumentPicker: UIViewControllerRepresentable {
    var completion: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            DispatchQueue.main.async {
                guard let selectedURL = urls.first else {
                    self.parent.completion(nil)
                    return
                }

                //  Request explicit read permission for the file
                let hasAccess = selectedURL.startAccessingSecurityScopedResource()
                defer { if hasAccess { selectedURL.stopAccessingSecurityScopedResource() } }

                // Copy file to a writable temp directory
                if let copiedURL = copyAudioFileToTempDirectory(originalURL: selectedURL) {
                    self.parent.completion(copiedURL)
                } else {
                    print("❌ Failed to copy audio file")
                    self.parent.completion(nil)
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            DispatchQueue.main.async {
                self.parent.completion(nil)
            }
        }
        
    }
    
    
}


