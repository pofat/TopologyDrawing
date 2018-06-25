//
//  TopologyMusicNodeTests.swift
//  TopologyMusicNodeTests
//
//  Created by Pofat Tseng on 2018/3/14.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import XCTest
@testable import TopologyMusicNode

class TopologyMusicNodeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRandomInt_success() {
        
        let aRange = 0 ... 14
        let bRange = 1 ... 7
        
        let aRandomInt = randomInt(from: aRange)
        let bRandomInt = randomInt(from: bRange)
        
        print("random numbers: \(aRandomInt), \(bRandomInt)")
        XCTAssert(aRandomInt >= aRange.lowerBound, "RandomA \(aRandomInt) is no larger than \(aRange.lowerBound)")
        XCTAssert(aRandomInt <= aRange.upperBound, "RandomA \(aRandomInt) is no less than \(aRange.upperBound)")
        XCTAssert(bRandomInt >= bRange.lowerBound, "RandomB \(bRandomInt) is no larger than \(bRange.lowerBound)")
        XCTAssert(bRandomInt <= bRange.upperBound, "RandomB \(bRandomInt) is no less than \(bRange.upperBound)")
    }
    
}
