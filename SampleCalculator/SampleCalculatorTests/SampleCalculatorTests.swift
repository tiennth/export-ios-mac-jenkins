//
//  SampleCalculatorTests.swift
//  SampleCalculatorTests
//
//  Created by Tien on 12/29/19.
//  Copyright © 2019 Gomu Soft. All rights reserved.
//

import XCTest
@testable import SampleCalculator

class SampleCalculatorTests: XCTestCase {

    let calculator = Calculator()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testID01() {
        let addResult = calculator.add(x: 4, y: 6)
        XCTAssertEqual(addResult, 10)
    }

    func testID02() {
        let addResult = calculator.subtract(x: 10, y: 6)
        XCTAssertEqual(addResult, 4)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
