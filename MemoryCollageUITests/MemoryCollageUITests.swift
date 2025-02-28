//
//  MemoryCollageUITests.swift
//  MemoryCollageUITests
//
//  Created by Gaurav Kumar on 12/31/24.
//

import XCTest

final class MemoryCollageUITests: XCTestCase {
    
    let app = XCUIApplication()


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    @MainActor
        func testTabsExist() throws {
            XCTAssertTrue(app.tabBars.buttons["Collage"].exists, "Collage tab should be visible")
            XCTAssertTrue(app.tabBars.buttons["Videos"].exists, "Videos tab should be visible")
        }

       
    @MainActor
    func testStartCreatingButtonExists() throws {
        let startButton = app.buttons["Start Creating!"]
        XCTAssertTrue(startButton.exists, "Start Creating button should be visible")
    }

  
}
