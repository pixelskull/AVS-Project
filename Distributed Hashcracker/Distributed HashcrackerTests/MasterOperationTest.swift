//
//  MasterOperationTest.swift
//  Distributed Hashcracker
//
//  Created by Dennis Jaeger on 18.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import XCTest
@testable import Distributed_Hashcracker
class MasterOperationTest: XCTestCase {
    
    let password = "aaaA"
    let bruteForce = BruteForceAttack()
    let MasterOperation = MasterWorkerOperation()
 //   var passwords:[String]?
    
    override func setUp() {
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    func testFillWorkerQueue() {
//    bruteForce.fillWorkBlogQueue();
        
        
    }
    
    
}
