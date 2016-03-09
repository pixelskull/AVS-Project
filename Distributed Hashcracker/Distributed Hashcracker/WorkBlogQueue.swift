//
//  MessageQueue.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class WorkBlogQueue {
    
    var workBlogQueue:[WorkBlog] = [WorkBlog]()
    let workBlogQueueLens = Lens<[WorkBlog], [WorkBlog]>(
        get: { $0 },
        set: { (newValue, value) in
            value + newValue
        }
    )
    
    static let sharedInstance = WorkBlogQueue()
    
    var read_semaphore = dispatch_semaphore_create(1)
    let write_semaphore = dispatch_semaphore_create(1)
    
    
    /**
     appends new WorkBlog to WorkBlogQueue (Blocking)
     
     - parameter message: Worker to append
     */
    func put(newWorkBlog:WorkBlog) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
//        workBlogQueue.append(newWorkBlog)
        workBlogQueue = workBlogQueueLens.set([newWorkBlog], workBlogQueue)
        dispatch_semaphore_signal(write_semaphore)
    }
    
    /**
     get WorkerBlog by ID if WorkerQueue is not empty (Blocking)
     
     - returns: WorkerBlog by ID from list when not empty otherwise nil
     */
    func getWorkBlogByID(workBlogID:String) -> WorkBlog? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
//        guard let workerByIdIndex = workBlogQueue.indexOf({$0.id == workBlogID}) else {
//            dispatch_semaphore_signal(read_semaphore)
//            return nil
//        }
        let workBlogByID = workBlogQueueLens.get(workBlogQueue).filter{ $0.id == workBlogID }.first// [workerByIdIndex]
        dispatch_semaphore_signal(read_semaphore)
        
        return workBlogByID
    }
    
    /**
     get first WorkBlog if WorkerQueue is not empty (Blocking)
     
     - returns: first WorkBlog from list when not empty otherwise nil
     */
    func getFirstWorkBlog() -> WorkBlog? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
//        guard workBlogQueueLens.get(workBlogQueue).count > 0 else {
//            dispatch_semaphore_signal(read_semaphore)
//            return nil
//        }
        let firstWorkBlog = workBlogQueueLens.get(workBlogQueue).first
        dispatch_semaphore_signal(read_semaphore)
        
        return firstWorkBlog
    }
    
    
    /**
     delete WorkBlog by WorkBlogID if WorkBlogQueue is not empty (Blocking)
     
     - returns: Removed WorkBLog from list when not empty otherwise nil
     */
    func removeWorkBlogByWorkBlogID(workBlogID:String) -> WorkBlog? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
//        guard let workBlogByWorkBlogIdIndex = workBlogQueue.indexOf({$0.id == workBlogID}) else {
//            dispatch_semaphore_signal(read_semaphore)
//            return nil
//        }
        let tmpQueue = workBlogQueueLens.get(workBlogQueue)
        let workBlogByID = tmpQueue.filter{ $0.id == workBlogID }.first // .removeAtIndex(workBlogByWorkBlogIdIndex)
        workBlogQueue = workBlogQueueLens.set([], tmpQueue.filter{ $0.id != workBlogID })
        dispatch_semaphore_signal(read_semaphore)
        
        return workBlogByID
        
    }
    
    /**
     delete WorkBlog by WorkerID if WorkBlogQueue is not empty (Blocking)
     
     - returns: Removed WorkBLog from list by ID when not empty otherwise nil
     */
    func removeWorkBlogByWorkerID(workerID:String) -> WorkBlog? {
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
//        guard let workBlogByWorkerIdIndex = workBlogQueue.indexOf({$0.inProcessBy == workerID}) else {
//            dispatch_semaphore_signal(read_semaphore)
//            return nil
//        }
        let tmpQueue = workBlogQueueLens.get(workBlogQueue)
        let workBlogByWorkerID =  tmpQueue.filter{ $0.inProcessBy == workerID }.first // .removeAtIndex(workBlogByWorkerIdIndex)
        workBlogQueue = workBlogQueueLens.set([], tmpQueue.filter{$0.inProcessBy != workerID })
        dispatch_semaphore_signal(read_semaphore)
        
        return workBlogByWorkerID
        
    }
}
