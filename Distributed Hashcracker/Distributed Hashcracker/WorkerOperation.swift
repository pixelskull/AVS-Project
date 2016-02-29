//
//  WorkerOperation.swift
//  Distributed Hashcracker
//
//  Created by Sebastian Domke  on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation
import Starscream

class WorkerOperation:MasterWorkerOperation {
    
    var algorithm:String = ""
    var target:String = ""
    var worker_id:String = ""
    
    var crackedPassword:String = ""
    
    
    override init() {
        super.init()
        let notificationName = Constants.NCValues.stopWorker
        notificationCenter.addObserver(self,
            selector: "stopWorkerOperation:",
            name: notificationName,
            object: nil)
    }
    
    override func main() {
        runloop: while true {
            guard run == true else { break runloop }
            if let message = getMessageFromQueue() {
                print("WorkerOperation message from queue message type",message.type)
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
                sleep(5)
            } else{
                //print("No message in the queue")
            }
        }
        sleep(2)
        run = true
    }
    
    /*
    Decision functions
    */
    
    func decideWhatToDoBasicMessage(message: BasicMessage){
        let messageHeader = message.status
        
        switch messageHeader {
        case MessagesHeader.stillAlive:
            stillAlive(message)
            break
        default:
            print("No matching basic header")
            break
        }
    }

    func decideWhatToDoExtendedMessage(message: ExtendedMessage){
        let messageHeader = message.status
        
        switch messageHeader {
        case MessagesHeader.setupConfig:
            setupConfig(message)
            break
        case MessagesHeader.newWorkBlog:
            newWorkBlog(message)
            break
        default:
            print("No matching extended header")
            break
        }
    }
    
    /*
    Worker related Message reactions 
    */
    
    /**
     Reaction of a client on a setupConfigMessage ->
     - save the selected hash algorithm, the target hash and the worker_id
     precondition = setupConfigMessage with values : {algorithm, target, worker_id}
     postcondition = client has send a finishedWorkMessage to the server
     */
    func setupConfig(message:ExtendedMessage){
        print("setupConfig")
        
//        algorithm = "MD5"
//        target = "Test"
        
        let workerQueue = WorkerQueue.sharedInstance
        
        worker_id = message.values["worker_id"]!
        algorithm = message.values["algorithm"]!
        target = message.values["target"]!
        algorithm = message.values["algorithm"]!
        
        let ownClientWorker = Worker(id: worker_id, status: .Aktive)
        
        workerQueue.put(ownClientWorker)
        
        //Send finishedWorkMessage
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: BasicMessage(status: MessagesHeader.finishedWork, value: worker_id))
    }
    
    /**
     Reaction of a client on a newWorkBlogMessage ->
     - client calculats hash values of the array with the new target passwords and checks if the target hash was found
     precondition = newWorkBlogMessage with a array of the new target passwords
     postcondition = calculated and checked hash values -> if(target hash was hit){send hitTargetHashMessage with the hash, the password, the time needed and the worker_id to the server} else {send finishedWorkMessage with the worker_id to the server}
     */
    func newWorkBlog(message:ExtendedMessage){
        print("newWorkBlog")
        
        //let passwordArray:[String] = ["Bla", "blub", "test"]
        
        let workerID = message.values["worker_id"]
        
        let passwordArray: [String] = (message.values["hashes"]?.componentsSeparatedByString(","))!
        
        var hashAlgorithm: HashAlgorithm?
        
        switch algorithm {
        case "MD5":
            hashAlgorithm = HashMD5()
        case "SHA-128":
            hashAlgorithm = HashSHA()
        case "SHA-256":
            hashAlgorithm = HashSHA256()
        default:
            print("Selected hash algorithm wasn't found: Default hash algorithm MD5 has been set")
            hashAlgorithm = HashMD5()
            break
        }
        
        /*
        var hashedPassword:String = ""
        var hashAlgorithm: HashAlgorithm?
        
        switch algorithm {
        case "MD5":
            hashAlgorithm = HashMD5()
        case "SHA-128":
            hashAlgorithm = HashSHA()
        case "SHA-256":
            hashAlgorithm = HashSHA256()
        default:
            hashAlgorithm = HashMD5()
            print("Selected Hashalgorithm not found - Default HashMD5 selected")
            break
        }
        */
        
        if(compareHash(hashAlgorithm!, passwordArray: passwordArray, targetHash: target)){
            let hitTargetHashValues: [String:String] = ["hash": target, "password": crackedPassword, "time_needed": "ka", "worker_id": workerID!]
            notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: ExtendedMessage(status: MessagesHeader.hitTargetHash, values: hitTargetHashValues))
            
            print("Found the searched password -> hitTargetHashMessage was send")
        }
        else{
            notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: BasicMessage(status: MessagesHeader.finishedWork, value: workerID!))
            print("The searched password wasn't there -> finishedWorkMessage was send")
        }
        
        /*
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
        print("Dictionary key \(key) -  Dictionary value \(value)")
        }
        */
    }
    
    /**
     Reaction of a client on a stillAliveMessage ->
     - send a aliveMessage with his own worker_id
     precondition = stillAliveMessage from the server
     postcondition = aliveMessage was send to the server
     */
    func stillAlive(message:BasicMessage){
        print("stillAlive")
        let workerQueue = WorkerQueue.sharedInstance
        let worker_id = workerQueue.getFirstWorker()?.getID()
        //Send a stillAliveMessage to the master with the worker_id of the client
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage, object: BasicMessage(status: MessagesHeader.alive, value: worker_id!))
    }
    
    
    /*
    Helper functions
    */
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }
    
    func compareHash(hashAlgorithm: HashAlgorithm, passwordArray:[String], targetHash: String) -> Bool{
        
        for password in passwordArray{
            
            let hashedPasswordFromArray = hashAlgorithm.hash(string: password)
            
            if(hashedPasswordFromArray == targetHash){
                print("Found the searched password! \(hashedPasswordFromArray) == \(targetHash) -> Password = \(password) (\(target))")
                crackedPassword = password
                return true
            }
            else{
                print("\(password) isn't the searched password")
            }
        }
        
        return false
        
    }
    
    func stopWorkerOperation(notification:NSNotification) {
        run = false
    }
    
}
