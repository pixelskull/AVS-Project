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
    var array:[String]?
    let bruteForce = BruteForceAttack()
    let MasterOperation = MasterWorkerOperation()
    
    
    let workBlockQueue = WorkBlogQueue.sharedInstance
    let workerQueue = WorkerQueue.sharedInstance
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
        let targetHash = HashSHA().hash(string: password)
        
        
        let workerOperation = WorkerOperation()
        workerQueue.put(Worker(id: "eins", status: .Aktive))
        dispatch_async(dispatch_get_main_queue()) {
            self.bruteForce.fillWorkBlogQueue()
        }
        while true {
            let workBlock = workBlockQueue.getFirstWorkBlog()
            workBlockQueue.removeWorkBlogByWorkBlogID(workBlock!.id)
            let algo:HashAlgorithm = HashSHA()
            workerOperation.compareHashes(algo, passwordArray: workBlock!.value, targetHash: targetHash, workBlogId: workBlock!.id)
        }
    }
    
    
}
