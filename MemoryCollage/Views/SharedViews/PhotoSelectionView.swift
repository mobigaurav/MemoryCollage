//
//  PhotoSelectionView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 12/31/24.
//

import SwiftUI
import PhotosUI

struct PhotoSelectionView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 15 // Allow up to 15 photos
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoSelectionView
        
        init(_ parent: PhotoSelectionView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
               picker.dismiss(animated: true)
               guard !results.isEmpty else { return }
               let dispatchGroup = DispatchGroup()
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        dispatchGroup.enter()
                        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                            if let image = image as? UIImage {
                                DispatchQueue.main.async {
                                    self?.parent.selectedImages.append(image)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    print("Selected images count: \(self.parent.selectedImages.count)")
                }
        }
    }
}

