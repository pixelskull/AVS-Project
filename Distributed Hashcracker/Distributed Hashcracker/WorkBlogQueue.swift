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
    
    static let sharedInstance = WorkBlogQueue()
    
    var read_semaphore = dispatch_semaphore_create(1)
    let write_semaphore = dispatch_semaphore_create(1)
    
    
    /**
     appends new worker to WorkerQueue (Blocking)
     
     - parameter message: Worker to append
     */
    func put(newWorkBlog:WorkBlog) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
        workBlogQueue.append(newWorkBlog)
        dispatch_semaphore_signal(write_semaphore)
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getWorkBlogByID(workBlogID:String) -> WorkBlog? {
        guard let workerByIdIndex = workBlogQueue.indexOf({$0.id == workBlogID}) else { return nil }
        
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let workBlogByID = workBlogQueue[workerByIdIndex]
        dispatch_semaphore_signal(read_semaphore)
        return workBlogByID
    }
    
    /**
     get Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func getFirstWorkBlog() -> WorkBlog? {
        guard workBlogQueue.count > 1 else { return nil }
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let firstWorkBlog = workBlogQueue.removeFirst()
        dispatch_semaphore_signal(read_semaphore)
        
        return firstWorkBlog
    }
    
    
    /**
     delete Worker by ID if WorkerQueue is not empty (Blocking)
     
     - returns: Worker by from list when not empty otherwise nil
     */
    func removeWorkBlog(workBlogID:String) -> WorkBlog? {
        guard let workBlogByIdIndex = workBlogQueue.indexOf({$0.id == workBlogID}) else { return nil }
        
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        let workBlogByID = workBlogQueue.removeAtIndex(workBlogByIdIndex)
        dispatch_semaphore_signal(read_semaphore)
        
        return workBlogByID
        
    }
}
