//
//  Distributed_HashcrackerTests.swift
//  Distributed HashcrackerTests
//
//  Created by Pascal Schönthier on 08.12.15.
//  Copyright © 2015 Pascal Schönthier. All rights reserved.
//

import XCTest
@testable import Distributed_Hashcracker

class Distributed_HashcrackerTests: XCTestCase {
    
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
    
    //Produces new Work Packages
    func testGeneratingCreateWorkerPackages() {
    
    }
    
    //Find out double "finishedWork" messages from the MasterOperation-Class
    func testFinishedWork() {
    
    }
    
    
    //Find out double "compareHashes" messages from the WorkerOperation-Class
    func testCompareHashes() {
        
    }

}
