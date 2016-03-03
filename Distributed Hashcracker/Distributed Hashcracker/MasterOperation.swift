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
    var startTimePasswordCrack: NSDate = NSDate()
    
    private override init() {
        
        super.init()
        
        let notificationName = Constants.NCValues.stopMaster
        notificationCenter.addObserver(self,
            selector: "stopMasterOperation:",
            name: notificationName,
            object: nil)
        
         NSTimer.scheduledTimerWithTimeInterval(60.0,
            target: self,
            selector: "sendStillAlive",
            userInfo: nil,
            repeats: true)
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
    
    
    func sendStillAlive() {
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: BasicMessage(status: .stillAlive, value: ""))
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
        
        // Start time of the password crack
        startTimePasswordCrack = NSDate()
        
        let messageObject = message.value
        
        let workerID:String = messageObject
        
        let workerQueue = WorkerQueue.sharedInstance
        
        //print("Länge workerQueue: \(workerQueue.workerQueue.count)")
//        
//        if(workerQueue.workerQueue.count == 0){
//            dispatch_async(dispatch_get_main_queue()) {
//               print("generateNewWorkBlog")
//                
//               self.generateNewWorkBlog()
//            }
//        }
//        performSelectorInBackground("generateNewWorkBlog", withObject: nil)
        if workerQueue.workerQueue.count == 0 {
            let queue = dispatch_queue_create("de.th-koeln.DistributedHashCracker", nil)
            dispatch_async(queue) {
                print("work work work")
                self.generateNewWorkBlog()
            }
        }
        //print("it goes on and on and on ... ")
        
        let newWorker = Worker(id: workerID, status: .Aktive)
        
        workerQueue.put(newWorker)
        
        //Send setupConfigurationMessage
        let setupConfigMessageValues: [String:String] = ["algorithm": selectedAlgorithm, "target": targetHash, "worker_id":workerID]
        notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
            object: ExtendedMessage(status: MessagesHeader.setupConfig, values: setupConfigMessageValues))
        
        
        //print("Send SetupMessage")
        
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
        
        //Endtime of the passwordCrack
        let endTimeMeasurement = NSDate();
        // <<<<< Time difference in seconds (double)
        let timeIntervalPasswordCrack: Double = endTimeMeasurement.timeIntervalSinceDate(startTimePasswordCrack);
        
        let hash = message.values["hash"]
        let password = message.values["password"]
        //let time_needed = message.values["time_needed"]
        let worker_id = message.values["worker_id"]
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password is cracked!")
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Hash of the password: " + hash!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Password: " + password!)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "Time needed: " + String(timeIntervalPasswordCrack))
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "By worker: " + worker_id!)
        
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
        
        //Try to remove the workBlog from the workBlogQueue by the worker how processed the workBlog
        let removedWorkBlog = workBlogQueue.removeWorkBlogByWorkerID(workerID)
        
        if(removedWorkBlog != nil){
            //WorkBlog was processed by a worker and has been removed from the workBlogQueue
            print("WorkBlog: \(removedWorkBlog?.id) wurde von \(workerID) bearbeitet und kann aus der Queue gelöscht werden")
        } else{
            //There was no assaigned workBlog in the workBlogQueue for the searched worker
            print("Kein WorkBlog mit: \(removedWorkBlog?.id), \(removedWorkBlog?.inProcessBy), \(workerID) vorhanden")
        }
        
        //Wait until the workBlogQueue got new entries
        while workBlogQueue.workBlogQueue.count == 0 {
            print("Es ist momentan kein WorkBlog vorhanden")
        }
        
        if(workBlogQueue.workBlogQueue.count > 0){
        
            //let newWorkBlog = convertWorkBlogArrayToString(workBlogQueue.getFirstWorkBlog()!.value)
            
            var nextWorkBlog:WorkBlog? = nil
            
            //Check if there is a workBlog in the WorkBlogQueue that is free to compute by a worker
            while nextWorkBlog == nil{
                nextWorkBlog = getAndCheckNewWorkBlog(workerID)
            }
            
            //Convert the newWorkBlog into a String
            let newWorkBlog = convertWorkBlogArrayToString(nextWorkBlog!.value)
            
            //Send setupConfigurationMessage
            let setupConfigMessageValues: [String:String] = ["worker_id": workerID, "hashes": newWorkBlog]
            notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: ExtendedMessage(status: MessagesHeader.newWorkBlog, values: setupConfigMessageValues))
        }
        else{
            print("Es ist momentan kein WorkBlog vorhanden")
        }
    }
    
    /**
     Reaction of the server on a hashesPerTimeMessage ->
     - calculate the hashes per second
     - send a postNotifiaction to the LogViewController to show the result
     precondition = hashesPerTimeMessage from a client
     postcondition = display the hashes per second from the client in the LogViewController
     */
    func hashesPerTime(message:ExtendedMessage){
        print("hashesPerTime")
        
        let hash_count = message.values["hash_count"]
        let time_needed = message.values["time_needed"]
        let worker_id = message.values["worker_id"]
        
        //calculate the hashes per second
        let hashesPerSecond:Int = Int(hash_count!)! / Int(time_needed!)!
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "The Worker: \(worker_id) generates and compares \(hashesPerSecond) per second")
        
        //print("HashesPerTimeMessage -> Worker_ID: \(worker_id) hashesPerSecond: \(hashesPerSecond)")
        
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
    
    func generateNewWorkBlog() {
        
        var workBlogID:Int = 1
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        let charArray = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "i", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "I", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        //let newWorkBlogString = "bla,blub,bli,test,Test,foo"
        
        func appendToArrayFirstTime(array:[String], toAppend:[String]) -> [String]{
            var tmpArray:[String] = [String]()
            
            for char in toAppend {
                tmpArray += array.map({ return $0 + char })
                
            }
            
            let firstWorkArray = charArray + tmpArray
            
            //print("First Work Array: \(firstWorkArray)")
            //print("Länge firstWorkArray: \(firstWorkArray.count)")
            
            
            let firstWorkBlog = WorkBlog(id: String(workBlogID), value: firstWorkArray)
            
            ++workBlogID
            
            workBlogQueue.put(firstWorkBlog)
            
            return tmpArray
        }
        
        func generateWorkBlogs(array:[String], toAppend:[String]) -> [String]{
            var currentArray:[String] = [String]()
            var tmpArray = [String]()
            for char in toAppend {
                
                for subset in array.splitBy(100) {
                    tmpArray += subset.map{ $0 + char }
                    if tmpArray.count > 5000 {
                        //print(tmpArray.count)
                        //print(tmpArray)
                        /// TODO: Append tmpArray to WorBlogQueue
                        
                        
                        while(WorkBlogQueue.sharedInstance.workBlogQueue.count > 10){
                            print("WorkBlogQueue noch voll")
                        }
                        let workBlog = WorkBlog(id: String(workBlogID), value: tmpArray)
                        
                        ++workBlogID
                        
                        workBlogQueue.put(workBlog)
                        
                        currentArray += tmpArray
                        tmpArray.removeAll()
                        
                    }
                }
            }
            currentArray += tmpArray
            return currentArray
        }
        
        var result = [String]()
        
        
        for var index = 0; index < 9; ++index{
            if result.count > 5000 {
                
            }
            if(index == 0){
                print("Generate passwords with lenght: \(index+1) and \(index+2)")
                result = appendToArrayFirstTime(charArray, toAppend: charArray)
            }
            else{
                print("Generate passwords with lenght: \(index+2)")
                result = generateWorkBlogs(result, toAppend: charArray)
            }
        }
        
    }
    
    //Convert a workBlog to a String for a getWorkMessage
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
    
    /**
    Get and check a new workBlog of the WorkBlogQueue for a getWorkMessage
    - Compare if a workBlog isn't in process by a worker
    - Get a free workBlog and set inProcessBy = workerID of the workBlog
    */
    func getAndCheckNewWorkBlog(workerID:String) -> WorkBlog?{
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        let workerQueue = WorkerQueue.sharedInstance
        
        for workBlog in workBlogQueue.workBlogQueue{
            
            //WorkBlog isn't in process by a worker
            if(workBlog.inProcessBy == "Not in process"){
                
                workBlog.inProcessBy = workerID
                return workBlog
            }
            else if(workBlog.inProcessBy != "Not in process"){
                //Check if the worker of the workBlog is still active
                if(workerQueue.getWorkerByID(workBlog.inProcessBy)?.status == .Inactive){
                    workBlog.inProcessBy = workerID
                    return workBlog
                }
            }
            
        }
        return nil
    }
    
    func stopMasterOperation(notification:NSNotification) {
        run = false
    }
}

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return 0.stride(to: self.count, by:subSize).map { startIndex in
            let endIndex = startIndex.advancedBy(subSize, limit: self.count)
            return Array(self[startIndex..<endIndex])
        }
    }
}
