//
//  PdftyTests.swift
//  PdftyTests
//
//  Created by Tatsuya Tobioka on 6/12/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import XCTest
import Pdfty

class PdftyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPage() {
        let url = NSBundle(forClass: self.dynamicType).URLForResource("example", withExtension: "pdf")!
        let pdfty = Pdfty(url: url)
        pdfty.clean()
        let image = pdfty.image(atIndex: 2)!
        let data = UIImagePNGRepresentation(image)
        XCTAssertEqual(pdfty.numberOfPages, 5)
        XCTAssertEqual(pdfty.pages.count, 5)
        XCTAssertEqual(UIImagePNGRepresentation(pdfty.image(atIndex: 2)!)?.length, data?.length)
        XCTAssertNil(pdfty.image(atIndex: 5))
        XCTAssertEqual(pdfty.rect, CGRectMake(0, 0, 1024, 768))
        
        let url2 = NSBundle(forClass: self.dynamicType).URLForResource("page3", withExtension: "pdf")!
        let pdfty2 = Pdfty(url: url2)
        pdfty2.clean()
        let image2 = pdfty2.image(atIndex: 0)!
        let data2 = UIImagePNGRepresentation(image2)
        XCTAssertEqual(pdfty2.numberOfPages, 1)
        XCTAssertEqual(pdfty2.pages.count, 1)
        XCTAssertEqual(UIImagePNGRepresentation(pdfty2.image(atIndex: 0)!)?.length, data2?.length)
        
        XCTAssertEqual(data?.length, data2?.length)
    }
    
    func testChache() {
        let expectation = expectationWithDescription("")
        
        let url = NSURL(string: "https://raw.githubusercontent.com/tnantoka/Pdfty/master/PdftyTests/example.pdf")!
        let pdfty = Pdfty(url: url)
        pdfty.clean()
        pdfty.didCache = {
            sleep(3)
            XCTAssertEqual(pdfty.cached, true)
            expectation.fulfill()
        }
        pdfty.clean()
        XCTAssertEqual(pdfty.numberOfPages, 5)
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
