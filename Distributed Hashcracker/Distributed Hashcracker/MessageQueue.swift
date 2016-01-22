//
//  MessageQueue.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa



protocol Initializable: class { init() }

class MessageQueue {

    let notificationCenter = NSNotificationCenter.defaultCenter()
    var messages:[Message] = [Message]()
    
    
    static let sharedInstance = MessageQueue()
    
    init() {
        notificationCenter.addObserver(self, selector: "put:", name: "putMessage", object: nil)
    }

    func put(message:Message) {
        messages.append(message)
    }
    
    func get() -> Message? {
        guard let firstElement = messages.first else { return nil }
        
        messages = messages.dropFirst().map { $0 }
        return firstElement
    }
    
    func poll() -> Message? {
        guard messages.count > 0 else { return nil }
        
        let firstElement = messages.first!
        messages = messages.dropFirst().map { $0 }
        return firstElement
    }
    
    func notify(notificationName:String) {}
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
