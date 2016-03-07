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
    
    var activeWorkerQueue:[Worker] = [Worker]()
    
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
     get first Worker if WorkerQueue is not empty (Blocking)
     
     - returns: First Worker from list when not empty otherwise nil
     */
    func getFirstWorker() -> Worker? {
        guard workerQueue.count > 0 else { return nil }
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let firstWorker = workerQueue.first!
        dispatch_semaphore_signal(read_semaphore)
        return firstWorker
    }

    /**
     delete Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: removed Worker from list when not empty otherwise nil
     */
    func remove(workerID:String) -> Worker? {
        guard let workerByIdIndex = workerQueue.indexOf({$0.id == workerID}) else { return nil }
        
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueue.removeAtIndex(workerByIdIndex)
        dispatch_semaphore_signal(read_semaphore)
        
        return workerByID

    }
    
    
    /**
     appends new worker to activeWorkerQueue (Blocking)
     
     - parameter message: active Worker to append
     */
    func putActiveWorker(worker:Worker) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
        activeWorkerQueue.append(worker)
        dispatch_semaphore_signal(write_semaphore)
    }
}
