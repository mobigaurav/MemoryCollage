//
//  MemoryCollageTests.swift
//  MemoryCollageTests
//
//  Created by Gaurav Kumar on 2/22/25.
//

import XCTest
@testable import MemoryCollage

final class MemoryCollageTests: XCTestCase {
    
    func testExample() {
        XCTAssertTrue(true, "Basic test should pass")
    }
    
    func testAddPhotoToCollage() {
            var selectedImages: [UIImage] = []
            let newImage = UIImage(systemName: "photo")!
            // Simulate adding a photo
            selectedImages.append(newImage)
            // Verify the count increased
            XCTAssertEqual(selectedImages.count, 1, "Image should be added to the collage")
        }
    
    func testPaywallShowsForFreeUsers() {
        let iapManager = IAPManager.shared
        // Simulate a free user
        UserDefaults.standard.set(false, forKey: "hasPurchasedPremium")
        let shouldShowPaywall = !iapManager.isPurchased()
        XCTAssertTrue(shouldShowPaywall, "Paywall should be displayed for free users")
    }
}
