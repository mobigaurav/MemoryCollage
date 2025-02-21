//
//  FileHelper.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 2/14/25.
//

import Foundation

func copyAudioFileToTempDirectory(originalURL: URL) -> URL? {
    let tempDirectory = FileManager.default.temporaryDirectory
    let destinationURL = tempDirectory.appendingPathComponent("audio_temp.m4a")

    do {
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL) // Remove if exists
        }
        try FileManager.default.copyItem(at: originalURL, to: destinationURL)
        print("Audio file copied successfully to: \(destinationURL)")
        return destinationURL
    } catch {
        print("Failed to copy audio file: \(error.localizedDescription)")
        return nil
    }
}

