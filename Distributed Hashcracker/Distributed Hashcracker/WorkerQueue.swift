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
    let workerQueueLens = Lens<[Worker], [Worker]>(
        get: { $0 },
        set: { (newValue, value) in
            value + newValue
        }
    )
    
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
        workerQueue = workerQueueLens.set([worker], workerQueue) // .append(worker)
        dispatch_semaphore_signal(write_semaphore)
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getWorkerByID(workerID:String) -> Worker? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        guard let workerByIdIndex = workerQueueLens.get(workerQueue).indexOf({$0.id == workerID}) else {
            dispatch_semaphore_signal(read_semaphore)
            return nil
        }
        let workerByID = workerQueueLens.get(workerQueue)[workerByIdIndex]
        dispatch_semaphore_signal(read_semaphore)
        
        return workerByID
    }
    
    /**
     get first Worker if WorkerQueue is not empty (Blocking)
     
     - returns: First Worker from list when not empty otherwise nil
     */
    func getFirstWorker() -> Worker? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        guard workerQueueLens.get(workerQueue).count > 0 else {
            dispatch_semaphore_signal(read_semaphore)
            return nil
        }
        let firstWorker = workerQueueLens.get(workerQueue).first!
        dispatch_semaphore_signal(read_semaphore)
        
        return firstWorker
    }

    /**
     delete Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: removed Worker from list when not empty otherwise nil
     */
    func remove(workerID:String) -> Worker? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
//        guard let workerByIdIndex = workerQueueLens.get(workerQueue).indexOf({$0.id == workerID}) else {
//            dispatch_semaphore_signal(read_semaphore)
//            return nil
//        }
        let workerByID = workerQueueLens.get(workerQueue).filter{ $0.id == workerID }.first // .removeAtIndex(workerByIdIndex)
        workerQueue = workerQueueLens.set([], workerQueue.filter{  $0.id != workerID })
        dispatch_semaphore_signal(read_semaphore)
        
        return workerByID
    }
    
    
    /**
     appends new worker to activeWorkerQueue (Blocking)
     
     - parameter message: active Worker to append
     */
    func putActiveWorker(worker:Worker) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
        workerQueue = workerQueueLens.set([worker], workerQueue)
        dispatch_semaphore_signal(write_semaphore)
    }
}
