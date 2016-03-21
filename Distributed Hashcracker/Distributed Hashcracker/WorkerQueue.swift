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
    let activeWorkerQueueLens = Lens<[Worker], [Worker]>(
        get: { $0 },
        set: { (newValue, value) in
            value + newValue
        }
    )
    
    
    static let sharedInstance = WorkerQueue()
    
    let semaphore = dispatch_semaphore_create(1)
    
    /**
     appends new worker to WorkerQueue (Blocking)
     
     - parameter message: Worker to append
     */
    func put(worker:Worker) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        workerQueue = workerQueueLens.set([worker], workerQueue)
        dispatch_semaphore_signal(semaphore)
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getWorkerByID(workerID:String) -> Worker? {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueueLens.get(workerQueue).filter{ $0.id == workerID }.first
        dispatch_semaphore_signal(semaphore)
        
        return workerByID
    }
    
    /**
     update Worker.status by WorkBlogID and workerID
     */
    func updateWorkerByID(workerID:String, status:Worker.Status){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueueLens.get(workerQueue).filter{ $0.id == workerID }.first
        workerByID!.status = status
        dispatch_semaphore_signal(semaphore)
    }
    
    /**
     get first Worker if WorkerQueue is not empty (Blocking)
     
     - returns: First Worker from list when not empty otherwise nil
     */
    func getFirstWorker() -> Worker? {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let firstWorker = workerQueueLens.get(workerQueue).first
        dispatch_semaphore_signal(semaphore)
        
        return firstWorker
    }

    /**
     delete Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: removed Worker from list when not empty otherwise nil
     */
    func remove(workerID:String) -> Worker? {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let workerByID = workerQueueLens.get(workerQueue).filter{ $0.id == workerID }.first
        workerQueue = workerQueueLens.set([], workerQueue.filter{  $0.id != workerID })
        dispatch_semaphore_signal(semaphore)
        
        return workerByID
    }
    
    
    /**
     appends new worker to activeWorkerQueue (Blocking)
     
     - parameter message: active Worker to append
     */
    func putActiveWorker(worker:Worker) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        workerQueue = workerQueueLens.set([worker], workerQueue)
        dispatch_semaphore_signal(semaphore)
    }
}
