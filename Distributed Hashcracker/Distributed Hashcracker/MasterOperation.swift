//
//  MasterOperation.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 19.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class MasterOperation: NSOperation {

    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
    
    override init() {
        
        super.init()
        
        let notificationName = Constants.NCValues.stopMaster
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: notificationName,
            object: nil)
    }
    
    override func main() {
        runloop: while true {
            guard run == true else { break runloop }
            
            if let message = getMessageFromQueue() {
                print("MasterOperation message from queue message type",message.type)
                switch message.type {
                case .Basic:
                    print("I'm a basic message")
                    decideWhatToDoBasicMessage(message as! BasicMessage)
                    break
                case .Extended:
                    print("I'm a extended message")
                    decideWhatToDoExtendedMessage(message as! ExtendedMessage)
                    break
                }
            } else{
                print("No message in the queue")
            }
        }
        sleep(1)
        run = true
    }
    
    func decideWhatToDoBasicMessage(message: BasicMessage){
        let messageHeader = message.status
        
        switch messageHeader {
            
        default:
            print("No matching basic header")
        }
    }
    
    func decideWhatToDoExtendedMessage(message: ExtendedMessage){
        let messageHeader = message.status
        
        switch messageHeader {
        
        default:
            print("No matching extended header")
        }
    }
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }
    
    func stop() {
        run = false
    }
}
