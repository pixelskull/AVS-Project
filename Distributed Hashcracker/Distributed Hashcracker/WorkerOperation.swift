//
//  WorkerOperation.swift
//  Distributed Hashcracker
//
//  Created by Sebastian Domke  on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class WorkerOperation:NSOperation {
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
    
    override init() {
        
        super.init()
        
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: "stopWebSocketOperation",
            object: nil)
    }
    
    override func main() {
        runloop: while true {
            if run == false { break runloop }
            
            let message = getMessageFromQueue()
            
            if message != nil{
                
                if message?.type == .Basic{
                    print("I'm a basic message")
                    decideWhatToDoBasicMessage(message?.status)
                }
                else if message?.type == .Extended{
                    print("I'm a extended message")
                }
                else{
                    print("I'm not a message")
                }
                //decideWhatToDo(message!)
            }

            sleep(1)
        }
        run = true
    }
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }

    func decideWhatToDoExtendedMessage(messageHeader: String){
        switch messageHeader {
            
        case "setupConfig":
            setupConfig()
        case "newWorkBlog":
            newWorkBlog()
        case "hitTargetHash":
            hitTargetHash()
        default:
            print("No matching basic header");
            break
        }

    }
    
    func decideWhatToDoBasicMessage(messageHeader: String){
        switch messageHeader {
        
        case "newClientRegistration":
            newClientRegistration()
        case "hitTargetHash":
            hitTargetHash()
        case "finishedWork":
            finishedWork()
        case "stillAlive":
            stillAlive()
        case "alive":
            alive()
        default:
            print("No matching basic header");
            break
        }

    }
    
    func newClientRegistration(){
        
    }
    
    func hitTargetHash(){
        
    }
    
    func finishedWork(){
        
    }
    
    func stillAlive(){
        
    }
    
    func alive(){
    
    }
    
    func setupConfig(){
        
    }
    
    func newWorkBlog(){
        
    }
    
    func hitTargetHash(){
        
    }
    
}
