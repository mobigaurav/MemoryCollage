//
//  DocumentPickerManager.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/13/25.
//

import UIKit
import UniformTypeIdentifiers

class DocumentPickerManager: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    var completionHandler: ((URL?) -> Void)?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            completionHandler?(nil)
            return
        }
        
        // Ensure the URL is accessible by copying it to the app's directory
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL) // Remove existing file
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            completionHandler?(destinationURL)
        } catch {
            print("Failed to copy audio file: \(error.localizedDescription)")
            completionHandler?(nil)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completionHandler?(nil)
    }
}

