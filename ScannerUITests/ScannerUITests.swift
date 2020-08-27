//
//  ScannerUITests.swift
//  ScannerUITests
//
//  
//   
//

import XCTest

class ScannerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        if #available(iOS 9.0, *) {
            let app = XCUIApplication()
            setupSnapshot(app)
            app.launch()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
    }
}
