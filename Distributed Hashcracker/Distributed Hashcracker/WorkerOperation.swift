//
//  WorkerOperation.swift
//  Distributed Hashcracker
//
//  Created by Sebastian Domke  on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation
import Starscream

class WorkerOperation:NSOperation {
    
    var webSocket:WebSocketBackgroundOperation
    
    var message: Message?
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
    
    override init() {
        
        webSocket = WebSocketBackgroundOperation()
        
        super.init()
        
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: "stopWebSocketOperation",
            object: nil)
    }
    
    override func main() {
        runloop: while true {
            if run == false { break runloop }
            
            message = getMessageFromQueue()
            
            print("WorkerOperation message from queue message type",message?.type)
            
            if message != nil{
                
                if message!.type == .Basic{
                    print("I'm a basic message")
                    decideWhatToDoBasicMessage(message!)
                }
                else if message!.type == .Extended{
                    print("I'm a extended message")
                    decideWhatToDoExtendedMessage(message!)
                }
                else{
                    print("I'm not a message")
                }
            }

            sleep(1)
        }
        run = true
    }
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }

    func decideWhatToDoExtendedMessage(message: Message){
        
        let messageHeader = message.status
        
        switch messageHeader {
            
        case MessagesHeader.setupConfig:
            setupConfig()
        case MessagesHeader.newWorkBlog:
            newWorkBlog()
        case MessagesHeader.hitTargetHash:
            hitTargetHash()
        default:
            print("No matching extended header")
            
        }

    }
    
    func decideWhatToDoBasicMessage(message: Message){
        
        let messageHeader = message.status
        
        switch messageHeader {
    
        case MessagesHeader.newClientRegistration:
            newClientRegistration()
        case MessagesHeader.finishedWork:
            finishedWork()
        case MessagesHeader.stillAlive:
            stillAlive()
        case MessagesHeader.alive:
            alive()
        default:
            print("No matching basic header")
            
        }

    }
    
    func newClientRegistration(){
        print("newClientRegistration")
    }
    
    func finishedWork(){
        print("finishedWork")
    }
    
    func stillAlive(){
        print("stillAlive")
        
        let messageObject = message?.jsonObject()
        
        let messageValue:String = messageObject!["value"] as! String
        
        print("stillAlive message value: " + messageValue)
        
    }
    
    func alive(){
        print("alive")
        let jsonStringStillAlive = jsonParser.createJSONStringFromMessage(BasicMessage(status: MessagesHeader.stillAlive, value: "true"))
        webSocket.socket.writeString(jsonStringStillAlive!)
    }
    
    func setupConfig(){
        print("setupConfig")
        
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
        }

    }
    
    func newWorkBlog(){
        print("newWorkBlog")
        
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
        }
        
    }
    
    func hitTargetHash(){
        print("hitTargetHash")
        
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
        }

    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
}
