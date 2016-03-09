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
    var messages = [Message]()
    let messagesLens = Lens<[Message], [Message]>(
        get: {
            $0
        },
        set: { (newValue, value) in
            value + newValue
        }
    )
    
    static let sharedInstance = MessageQueue()
    
    let semaphore = dispatch_semaphore_create(1)
    
    private init() {}

    /**
     appends new message to MessageQueue (Blocking)
     
     - parameter message: Message to append
    */
    func put(message:Message) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        messages = messagesLens.set([message], messages) 
        dispatch_semaphore_signal(semaphore)
    }
    
    /**
     get first Message if MessageQueue is not empty (Blocking)
     
     - returns: first message in list when not empty otherwise nil
    */
    func get() -> Message? {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        guard let firstElement = messagesLens.get(messages).first else {
            dispatch_semaphore_signal(semaphore)
            return nil
        }
        messages = messagesLens.set([], messages.dropFirst().map{ $0 })
        dispatch_semaphore_signal(semaphore)
            
        return firstElement
    }
    
    /**
     get first Message if MessageQueue is not empty (Blocking)
     
     - returns: first message in list when not empty otherwise nil
    */
    func poll() -> Message? {
        guard let firstElement = messagesLens.get(messages).first else { return nil }
        messages = messagesLens.set([], messages.dropFirst().map { $0 })
        return firstElement
    }
    
    /**
     add notify worker when new Message is appended (not implemented)
    */
    func notify(notificationName:String) {}
}
