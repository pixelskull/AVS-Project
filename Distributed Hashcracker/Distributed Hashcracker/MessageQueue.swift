//
//  MessageQueue.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class MessageQueue {

//    let notificationCenter = NSNotificationCenter.defaultCenter()
    var messages:[Message] = [Message]()
    
    static let sharedInstance = MessageQueue()
    
    var read_semaphore = dispatch_semaphore_create(0)
    let write_semaphore = dispatch_semaphore_create(0)
    
    private init() {}

    /**
     appends new message to MessageQueue (Blocking)
     
     - parameter message: Message to append
    */
    func put(message:Message) {
        dispatch_semaphore_wait(write_semaphore, DISPATCH_TIME_FOREVER)
        messages.append(message)
        dispatch_semaphore_signal(write_semaphore)
    }
    
    /**
     get first Message if MessageQueue is not empty (Blocking)
     
     - returns: first message in list when not empty otherwise nil
    */
    func get() -> Message? {
        guard let firstElement = messages.first else { return nil }
        dispatch_semaphore_wait(read_semaphore, DISPATCH_TIME_FOREVER)
        messages = messages.dropFirst().map { $0 }
        dispatch_semaphore_signal(read_semaphore)
        return firstElement
    }
    
    /**
     get first Message if MessageQueue is not empty (Blocking)
     
     - returns: first message in list when not empty otherwise nil
    */
    func poll() -> Message? {
        guard let firstElement = messages.first else { return nil }
        messages = messages.dropFirst().map { $0 }
        return firstElement
    }
    
    /**
     add notify worker when new Message is appended (not implemented)
    */
    func notify(notificationName:String) {}
    
//    deinit {
//        notificationCenter.removeObserver(self)
//    }
}
