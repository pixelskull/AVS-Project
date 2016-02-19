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
    
//    var message: Message?
    
    var algorithm:String = ""
    var target:String = ""
    var worker_id:String = ""
    
    var crackedPassword:String = ""
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
    
    
    
    override init() {
        
        super.init()
        
        let notificationName = Constants.NCValues.stopWebSocket
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: notificationName,
            object: nil)
    }
    
    override func main() {
        runloop: while true {
            
            if run == false { break runloop }
            
            let message = getMessageFromQueue()
            
            if message != nil{
                
                print("WorkerOperation message from queue message type",message?.type)
                
                if message!.type == .Basic{
                    print("I'm a basic message")
                    decideWhatToDoBasicMessage(message as! BasicMessage)
                }
                else if message!.type == .Extended{
                    print("I'm a extended message")
                    decideWhatToDoExtendedMessage(message as! ExtendedMessage)
                }
                else{
                    print("I'm not a message")
                }
            }
            else{
                print("No message in the queue")
            }
            
            sleep(1)
        }
        run = true
    }
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }

    func decideWhatToDoExtendedMessage(message: ExtendedMessage){
        
        let messageHeader = message.status
        
        switch messageHeader {
            
        case MessagesHeader.setupConfig:
            setupConfig(message)
        case MessagesHeader.newWorkBlog:
            newWorkBlog(message)
        case MessagesHeader.hitTargetHash:
            hitTargetHash(message)
        case MessagesHeader.hashesPerTime:
            hashesPerTime(message)
        default:
            print("No matching extended header")
            
        }

    }
    
    func decideWhatToDoBasicMessage(message: BasicMessage){
        
        let messageHeader = message.status
        
        switch messageHeader {
    
        case MessagesHeader.newClientRegistration:
            newClientRegistration(message)
        case MessagesHeader.finishedWork:
            finishedWork(message)
        case MessagesHeader.stillAlive:
            stillAlive(message)
        case MessagesHeader.alive:
            alive(message)
        default:
            print("No matching basic header")
            
        }

    }
    
    /**
    Reaction of the server on a newClientRegistrationMessage ->  
     - adding a new Worker to the WorkerQueue
     - sending a setupConfigMessage to the new Worker
    precondition = newClientRegistrationMessage of a new client with his IP
    postcondition = setupConfigMessage with the selected hash algorithm, the target hash and the worker_id was send to the new client
    */
    func newClientRegistration(message:BasicMessage){
        print("newClientRegistration")
        
        let messageObject = message.value
        
        let workerID:String = messageObject
        
        let workerQueue = WorkerQueue.sharedInstance
        
        let newWorker = Worker(id: workerID, status: .Aktive)
        
        workerQueue.put(newWorker)

        //Send setupConfigurationMessage
        let setupConfigMessageValues: [String:String] = ["algorithm": "MD5", "target": "Test", "worker_id":workerID]
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: ExtendedMessage(status: MessagesHeader.setupConfig, values: setupConfigMessageValues))
    
        /*
        let workerQueueLenght = workerQueue.workerQueue.count + 1
        
        print("WorkerQueueLenght: \(workerQueue.workerQueue.count)")
        
        let workerID = "Worker_" + String(workerQueueLenght)
        
        print("WorkerID: " + workerID)
        
        let newWorker = Worker(id: workerID, ip: workerIP, status: .Aktive)
        
        workerQueue.put(newWorker)

        print("WorkerQueueLenght after input Worker: \(workerQueue.workerQueue.count)")
        */

    }
    
    /**
     Reaction of the server on a finishedWorkMessage ->
     - create a new target password blog
     - sending a newWorkBlogMessage to the client which send the finishedWorkMessage
     precondition = finishedWorkMessage from a client
     postcondition = newWorkBlogMessage was send to a client
     */
    func finishedWork(message:BasicMessage){
        print("finishedWork")
        
        let workerID = message.value
        
        let newWorkBlog = generateNewWorkBlog()
        
        //Send setupConfigurationMessage
        let setupConfigMessageValues: [String:String] = ["worker_id": workerID, "hashes": newWorkBlog]
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: ExtendedMessage(status: MessagesHeader.newWorkBlog, values: setupConfigMessageValues))
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
    
    /**
     Reaction of the server on a aliveMessage ->
     - keep the worker in the workerQueue and the Worker.status = .Aktive
     precondition = aliveMessage with the worker_id from a client
     postcondition = client stays in the workerQueue
     */
    func alive(message:BasicMessage){
        print("alive")
        
        let messageObject = message.value
        
        print("stillAlive message value: " + messageObject)
        
        //webSocket.sendMessage(BasicMessage(status: MessagesHeader.stillAlive, value: "worker_id"))

    }
    
    /**
     Reaction of a client on a setupConfigMessage ->
     - save the selected hash algorithm, the target hash and the worker_id
     precondition = setupConfigMessage with values : {algorithm, target, worker_id}
     postcondition = client has send a finishedWorkMessage to the server
     */
    func setupConfig(message:ExtendedMessage){
        print("setupConfig")
        
        let workerQueue = WorkerQueue.sharedInstance
        
        let workerID = message.values["worker_id"]!
        
        let ownClientWorker = Worker(id: workerID, status: .Aktive)
        
        workerQueue.put(ownClientWorker)
        
        algorithm = "MD5"
        target = "Test"
        
        //Send finishedWorkMessage
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: BasicMessage(status: MessagesHeader.finishedWork, value: workerID))
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
        
        var hashedPassword:String = ""
        var hashAlgorithm: HashAlgorithm?
        
        switch algorithm {
        case "MD5":
            hashAlgorithm = HashMD5()
            hashedPassword = hashAlgorithm!.hash(string: target)
        case "SHA-128":
            hashAlgorithm = HashSHA()
            hashedPassword = hashAlgorithm!.hash(string: target)
        case "SHA-256":
            hashAlgorithm = HashSHA256()
            hashedPassword = hashAlgorithm!.hash(string: target)
        default:
            hashedPassword = "Password not successfully hashed"
            break
        }

        if(compareHash(hashAlgorithm!, passwordArray: passwordArray, hashedPassword: hashedPassword)){
            let hitTargetHashValues: [String:String] = ["hash": hashedPassword, "password": crackedPassword, "time_needed": "ka", "by_worker": workerID!]
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
     Reaction of the server/client on a hitTargetHashMessage ->
     - client = stop calculating und checking hash values
     - server = issue the result of the successful hash crack
     precondition = hitTargetHashMessage from a client/the server
     postcondition = clients stopped their work / the server showed the result
     */
    func hitTargetHash(message:ExtendedMessage){
        print("hitTargetHash")
        
        let hash = message.values["hash"]
        let password = message.values["password"]
        let time_needed = message.values["time_needed"]
        let by_worker = message.values["by_worker"]
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password is cracked!")
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Hash of the password: " + hash!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password: " + password!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Time needed: " + time_needed!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object:
            "By worker: " + by_worker!)
        
        /*
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
        }
        */
    }
    
    func hashesPerTime(message:ExtendedMessage){
        print("hashesPerTime")
    }
    
    func compareHash(hashAlgorithm: HashAlgorithm, passwordArray:[String], hashedPassword: String) -> Bool{
        
        for password in passwordArray{
            
            let hashedPasswordFromArray = hashAlgorithm.hash(string: password)
            
            if(hashedPasswordFromArray == hashedPassword){
                print("Found the searched password! \(hashedPasswordFromArray) == \(hashedPassword) -> Password = \(password) (\(target))")
                crackedPassword = password
                return true
            }
            else{
                print("\(password) isn't the searched password")
            }
        }
        
        return false
        
    }
    
    func generateNewWorkBlog() -> String{
        
        let newWorkBlogString = "bla,blub,bli,test,Test,foo"
        
        return newWorkBlogString
    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
}
