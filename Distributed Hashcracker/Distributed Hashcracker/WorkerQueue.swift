//
//  MessageQueue.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class WorkerQueue {
    
    var workerQueue:[Worker] = [Worker]()
    
    static let sharedInstance = WorkerQueue()
    
    var read_semaphore = dispatch_semaphore_create(1)
    let write_semaphore = dispatch_semaphore_create(1)
    
    
    /**
     appends new worker to WorkerQueue (Blocking)
     
     - parameter message: Worker to append
     */
    func put(worker:Worker) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
        workerQueue.append(worker)
        dispatch_semaphore_signal(write_semaphore)
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getWorkerByID(workerID:String) -> Worker? {
        guard let workerByIdIndex = workerQueue.indexOf({$0.id == workerID}) else { return nil }
        
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueue[workerByIdIndex]
        dispatch_semaphore_signal(read_semaphore)
        return workerByID
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getFirstWorker() -> Worker? {
        guard let firstWorker = workerQueue.first else { return nil }
        return firstWorker
    }

    
    /**
     delete Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func remove(workerID:String) -> Worker? {
        guard let workerByIdIndex = workerQueue.indexOf({$0.id == workerID}) else { return nil }
        
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueue.removeAtIndex(workerByIdIndex)
        dispatch_semaphore_signal(read_semaphore)
        
        return workerByID

    }
}
