//
//  MasterOperation.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 19.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class MasterOperation:MasterWorkerOperation {
    
    var targetHash:String   = ""
    var selectedAlgorithm:String = ""
    
    
    private override init() {
        
        super.init()
        
        let notificationName = Constants.NCValues.stopMaster
        notificationCenter.addObserver(self,
            selector: "stopMasterOperation:",
            name: notificationName,
            object: nil)
    }
    
    convenience init(targetHash:String, selectedAlgorithm:String) {
        self.init()
        self.targetHash = targetHash
        self.selectedAlgorithm = selectedAlgorithm
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
            }
//            else{
//                print("No message in the queue")
//            }
        }
        sleep(1)
        run = true
    }
    
    /*
    Decision functions
    */
    
    func decideWhatToDoBasicMessage(message: BasicMessage){
        let messageHeader = message.status
        
        switch messageHeader {
        case MessagesHeader.newClientRegistration:
            newClientRegistration(message)
            break
        case MessagesHeader.finishedWork:
            finishedWork(message)
            break
        case MessagesHeader.alive:
            alive(message)
            break
        default:
            print("No matching basic header")
            break
        }
    }
    
    func decideWhatToDoExtendedMessage(message: ExtendedMessage){
        let messageHeader = message.status
        
        switch messageHeader {
        case MessagesHeader.hitTargetHash:
            hitTargetHash(message)
            break
        case MessagesHeader.hashesPerTime:
            hashesPerTime(message)
            break
        default:
            print("No matching extended header")
        }
    }
    
    
    /*
    Master related Message reactions
    */
    
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
        
        print("Länge workerQueue: \(workerQueue.workerQueue.count)")
        
        if(workerQueue.workerQueue.count == 0){
            dispatch_async(dispatch_get_main_queue()) {
               print("generateNewWorkBlog")
                
               self.generateNewWorkBlog()
            }
        }
        
        let newWorker = Worker(id: workerID, status: .Aktive)
        
        workerQueue.put(newWorker)
        
        //Send setupConfigurationMessage
        let setupConfigMessageValues: [String:String] = ["algorithm": selectedAlgorithm, "target": targetHash, "worker_id":workerID]
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
        let worker_id = message.values["worker_id"]
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password is cracked!")
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Hash of the password: " + hash!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password: " + password!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Time needed: " + time_needed!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object:
            "By worker: " + worker_id!)
        
        /*
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
        print("Dictionary key \(key) -  Dictionary value \(value)")
        }
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
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        
        let workerID = message.value
        
        
        if(workBlogQueue.workBlogQueue.count > 0){
        let newWorkBlog = convertWorkBlogArrayToString(workBlogQueue.getFirstWorkBlog()!.value)
        
        //Send setupConfigurationMessage
        let setupConfigMessageValues: [String:String] = ["worker_id": workerID, "hashes": newWorkBlog]
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: ExtendedMessage(status: MessagesHeader.newWorkBlog, values: setupConfigMessageValues))
        }
        else{
            print("Es ist momentan kein WorkBlog vorhanden")
        }
    }
    
    func hashesPerTime(message:ExtendedMessage){
        print("hashesPerTime")
        
        let hash_count = message.values["hash_count"]
        let time_needed = message.values["time_needed"]
        let worker_id = message.values["worker_id"]
        
        let hashesPerSecond:Int = Int(hash_count!)! / Int(time_needed!)!
        
        print("HashesPerTimeMessage -> Worker_ID: \(worker_id) hashesPerSecond: \(hashesPerSecond)")
        
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
    
    /*
    Helper functions
    */
    
    func getMessageFromQueue() -> Message? {
        return messageQueue.get()
    }
    
    func generateNewWorkBlog(){
        
        var workBlogID:Int = 1
        
        let charArray = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "i", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "I", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        var tempArray:[String] = charArray
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        
        //let newWorkBlogString = "bla,blub,bli,test,Test,foo"

        func appendToArrayFirstTime(array:[String], toAppend:[String]){
            var tmpArray:[String] = [String]()
            
            for char in toAppend {
                tmpArray += array.map({ return $0 + char })
                
            }
            
            let firstWorkArray = charArray + tmpArray
            
            print("First Work Array: \(firstWorkArray)")
            
            let firstWorkBlog = WorkBlog(id: String(workBlogID), value: firstWorkArray)
            
            ++workBlogID
            
            workBlogQueue.put(firstWorkBlog)
            
            print("Länge WorkBlogQueue:  \(workBlogQueue.workBlogQueue.count)")
            
            tempArray = firstWorkArray
        }
        
        func appendToArray(array:[String], toAppend:[String]){
            var tmpArray:[String] = [String]()
            
            for char in toAppend {
                
                if(tmpArray.count < 5000){
                    tmpArray += array.map({ return $0 + char })
                    tempArray = tmpArray
                }
                else{
                    tempArray = tmpArray
                    print("Current WorkArray: \(tmpArray)")
                    
                    let newWorkBlog = WorkBlog(id: String(workBlogID), value: tmpArray)
                    workBlogQueue.put(newWorkBlog)
                    
                    print("Länge WorkBlogQueue:  \(workBlogQueue.workBlogQueue.count)")
                    tmpArray = [String]()
                    ++workBlogID
                }
            }
        }

        
        for var index = 0; index < 9; ++index{
            
            if(index == 0){
                appendToArrayFirstTime(tempArray, toAppend: charArray)
            }
           else{
                appendToArray(tempArray, toAppend: charArray)
            }
        }
        
    }
    
    func convertWorkBlogArrayToString(workBlog:[String]) -> String{
        
        var counter=0
        var workBlogString:String = ""
        
        for character in workBlog{
            if(counter < workBlog.count){
                workBlogString = workBlogString + character + ","
                counter++
            }
            else{
                workBlogString = workBlogString + character
            }
        }
        
        return workBlogString
    }
    
    func stopMasterOperation(notification:NSNotification) {
        run = false
    }
}
