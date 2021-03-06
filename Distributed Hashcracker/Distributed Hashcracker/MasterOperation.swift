//
//  MasterOperation.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 19.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return 0.stride(to: self.count, by:subSize).map { startIndex in
            let endIndex = startIndex.advancedBy(subSize, limit: self.count)
            return Array(self[startIndex..<endIndex])
        }
    }
}

class MasterOperation:MasterWorkerOperation {
    
    let semaphore = dispatch_semaphore_create(1)
    var targetHash:String   = ""
    var selectedAlgorithm:String = ""
    var startTimePasswordCrack: NSDate = NSDate()
    var generateLoopRun = true
    var countOfSendStillAliveMessages:Int = 0
    var sendStillAliveMessage = false
    var timer:NSTimer = NSTimer()
    
    private override init() {
        super.init()
        
        notificationCenter.addObserver(self,
            selector: #selector(self.stopMasterOperation(_:)),
            name: Constants.NCValues.stopMaster,
            object: nil)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0,
            target: self,
            selector: #selector(self.sendStillAlive),
            userInfo: nil,
            repeats: true)
        sendStillAliveMessage = true
        
    }
    
    convenience init(targetHash:String, selectedAlgorithm:String) {
        self.init()
        self.targetHash = targetHash
        self.selectedAlgorithm = selectedAlgorithm
    }
    
    override func main() {
        let queue = dispatch_queue_create("\(Constants.queueID).WorkerQueue", nil)
        let highPriority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_set_target_queue(queue, highPriority)
        
        dispatch_async(queue) {
            self.generateNewWorkBlog()
        }
        
        runloop: while true {
            guard run == true else { break runloop }
            
            if let message = getMessageFromQueue() {
                switch message.type {
                case .Basic:
                    decideWhatToDoBasicMessage(message as! BasicMessage)
                    break
                case .Extended:
                    decideWhatToDoExtendedMessage(message as! ExtendedMessage)
                    break
                }
            }
        }
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
        case MessagesHeader.alive:
            alive(message)
            break
        default:
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
        case MessagesHeader.finishedWork:
            finishedWork(message)
            break
        default:
            break
        }
    }
    
    /** Send a stillAliveMessage in a specific time intervall
    - Send the stillAliveMessage two times and wait for aliveMessages from the workers
    - At each third time the master checks which workers are still alive
    */
    func sendStillAlive() {
        guard self.sendStillAliveMessage else {
            timer.invalidate()
            return
        }
        let queue = dispatch_queue_create("\(Constants.queueID).stillAlive", nil)
        
        dispatch_async(queue) {
            var logUpdateText:String
            switch self.countOfSendStillAliveMessages{
            case 0:
                logUpdateText = "asked if worker still alive"
                self.countOfSendStillAliveMessages += 1
                break
            case 1:
                logUpdateText = "asked if worker still alive"
                self.countOfSendStillAliveMessages += 1
                break
            case 2:
                //Check active worker
                self.checkActiveWorker()
                logUpdateText = "Checked which workers are still alive and asked again"
                self.countOfSendStillAliveMessages = 0
                break
            default:
                logUpdateText = "asked if worker still alive"
                self.countOfSendStillAliveMessages = 0
            }
            self.notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: BasicMessage(status: .stillAlive, value: ""))
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: logUpdateText)
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
        let queue = dispatch_queue_create("\(Constants.queueID).newClient", nil)
        
        dispatch_async(queue) {
            // Start time of the password crack
            self.startTimePasswordCrack = NSDate()
            let workerQueue = WorkerQueue.sharedInstance

            let workerID:String = message.value
            guard let worker = workerQueue.getWorkerByID(workerID) else {
                let newWorker = Worker(id: workerID, status: .Aktive)
                workerQueue.put(newWorker)
                
                //Send setupConfigurationMessage
                let setupConfigMessageValues: [String:String] = ["algorithm": self.selectedAlgorithm,
                    "target": self.targetHash,
                    "worker_id":workerID]
                self.notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                    object: ExtendedMessage(status: MessagesHeader.setupConfig, values: setupConfigMessageValues))
                return
            }
            guard worker.status == .Inactive else { return }
            workerQueue.updateWorkerByID(worker.id, status: .Aktive)
        }
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
        let queue = dispatch_queue_create("\(Constants.queueID).hitTarget", nil)
        
        dispatch_async(queue) {
            //Endtime of the passwordCrack
            let endTimeMeasurement = NSDate();
            // <<<<< Time difference in seconds (double)
            let timeIntervalPasswordCrack: Double = endTimeMeasurement.timeIntervalSinceDate(self.startTimePasswordCrack);
            let hash = message.values["hash"]
            let password = message.values["password"]
            //let time_needed = message.values["time_needed"]
            let worker_id = message.values["worker_id"]
            
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Password is cracked!")
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Hash of the password: " + hash!)
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Password: " + password!)
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Time needed: " + String(timeIntervalPasswordCrack))
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "By worker: " + worker_id!)
            
            // stops other worker
            self.notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: BasicMessage(status: .stopWork, value: ""))
            self.notificationCenter.postNotificationName(Constants.NCValues.stopMaster, object: nil)
        }
    }
    
    /**
     Reaction of the server on a finishedWorkMessage ->
     - create a new target password blog
     - sending a newWorkBlogMessage to the client which send the finishedWorkMessage
     precondition = finishedWorkMessage from a client
     postcondition = newWorkBlogMessage was send to a client
     */
    func finishedWork(message:ExtendedMessage){
        let queue = dispatch_queue_create("\(Constants.queueID).finishedWork", nil)
        
        dispatch_async(queue) {
            let workBlogQueue = WorkBlogQueue.sharedInstance
            let workerID = message.values["worker_id"]
            let workBlogID = message.values["workBlog_id"]
            
//            print("finishedWork - WorkerID: \(workerID) und WorkBlogID: \(workBlogID)")
            
//            print("WorkBlogQueueLängeVorRemove: \(workBlogQueue.workBlogQueue.count)")
            //Try to remove the workBlog from the workBlogQueue by the worker how processed the workBlog
            
            _ = workBlogQueue.removeWorkBlogByWorkBlogID(workBlogID!)
            
//            if(resultRemoveWorkBlog == nil){
//                print("WorkBlog wurde nicht gelöscht - WorkBlogID \(workBlogID) nicht gefunden!")
//            }
//            else{
//                print("WorkBlog wurde gelöscht - WorkBlogID \(workBlogID)")
//            }
//            print("WorkBlogQueueLängeNachRemove: \(workBlogQueue.workBlogQueue.count)")
            
            //Wait until the workBlogQueue got new entries
            //while workBlogQueue.getWorkBlogQueueCount() == 0 {sleep(1)}
            waitLoop: while(workBlogQueue.getWorkBlogQueueCount() == 0){
                guard self.generateLoopRun == true else { break waitLoop }
            }
            
            if(workBlogQueue.workBlogQueue.count > 0){
                
                //let newWorkBlog = convertWorkBlogArrayToString(workBlogQueue.getFirstWorkBlog()!.value)
                
                //Check if there is a workBlog in the WorkBlogQueue that is free to compute by a worker
                
                var nextWorkBlog:WorkBlog? = nil
                
                while nextWorkBlog == nil{
                    nextWorkBlog = self.getAndCheckNewWorkBlog(workerID!)
                }
                
//                print("Workblog from Password: \(nextWorkBlog!.value.first) to \(nextWorkBlog!.value.last)")
                
                //Convert the newWorkBlog into a String
//                let newWorkBlog = self.convertWorkBlogArrayToString(nextWorkBlog!.value)
                //Send setupConfigurationMessage
                let newWorkBlogMessageValues: [String:String] = ["worker_id": workerID!, "workBlog_id": nextWorkBlog!.id, "hashes": nextWorkBlog!.value]
                self.notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                    object: ExtendedMessage(status: MessagesHeader.newWorkBlog, values: newWorkBlogMessageValues))
            }
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
        let queue = dispatch_queue_create("\(Constants.queueID).hashesPerTime", nil)
        
        dispatch_async(queue) {
            let hash_count = message.values["hash_count"]
            let time_needed = message.values["time_needed"]
            let worker_id = message.values["worker_id"]
            
            //calculate the hashes per second
            let hashesPerSecond:Double = Double(hash_count!)! / Double(time_needed!)!
        
            //Round hashesPerSecond with two decimal places
            let roudedHashesPerSecond:Double = Double(round(100*hashesPerSecond)/100)
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "The worker: \(worker_id) generates and compares \(roudedHashesPerSecond) per second")
            
            self.notificationCenter.postNotificationName(Constants.NCValues.updateChartView,
                                                         object: message)
        }
    }
    
    /**
     Reaction of the server on a aliveMessage ->
     - keep the worker in the workerQueue and the Worker.status = .Aktive
     precondition = aliveMessage with the worker_id from a client
     postcondition = client stays in the workerQueue
     */
    func alive(message:BasicMessage){
        print("alive")
        let queue = dispatch_queue_create("\(Constants.queueID).alive", nil)
        
        dispatch_async(queue) {
            let workerQueue = WorkerQueue.sharedInstance
            let workerID:String = message.value

            //Put the Worker in the activeWorkerQueue if its not jet in the activeWorkerQueue
            if workerQueue.getActiveWorker(workerID) == nil {
                //Put the worker in the activeWorkerQueue
        
                let worker = workerQueue.getWorkerByID(workerID)!

                workerQueue.putActiveWorker(worker)
            }
        }
    }
    
    /*
    Helper functions
    */
    
    func getMessageFromQueue() -> Message? { return messageQueue.get() }
    
    /**
     Backgroundoperation for generating new WorkBlogs
     - Generate new Workblocks with a specific lenght 
     - Generate and save so many WorkBlogs in the cache like workers are in the workerQueue
     precondition = a worker has been registrated by the master
     */
    func generateNewWorkBlog() {
        let strategies:[AttackStrategy] = [DictionaryAttack(), BruteForceAttack()]
        _ = strategies.map { $0.fillWorkBlogQueue() }
    }
    
    /**
     Convert a workBlog to a String for a getWorkMessage
     
     - parameter workBlog: Workblog (Array of Hashes )
     - returns: String representation of Workblog
     */
    func convertWorkBlogArrayToString(workBlog:[String]) -> String{
        return workBlog.joinWithSeparator(",")
    }
    
    /**
    Get and check a new workBlog of the WorkBlogQueue for a getWorkMessage
    - Compare if a workBlog isn't in process by a worker
    - Get a free workBlog and set inProcessBy = workerID of the workBlog
    */
    func getAndCheckNewWorkBlog(workerID:String) -> WorkBlog?{
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
//        let workerQueue = WorkerQueue.sharedInstance
//        print("workblogqueue.count: \(workBlogQueue.workBlogQueue.count)")
        
        //Check if there is a free WorkBlog (inProcessBy == "Not in process")
        let newWorkBlog = workBlogQueue.updateAndGetWorkBlog(workerID)
        
        //Free workBlog available and return this workBlog
        if(newWorkBlog != nil){
            return newWorkBlog
        }
        else{
            return nil
        }
    }
    
    /**
     Check which of the worker in the workerQueue is still alive
     - Worker is in the activeWorkerQueue -> leave Worker.status = .Active
     - Worker isn't in the activeWorkerQueue -> set Worker.status = .Inactive and check the WorkBlogQueue if there is a WorkBlog inProcess by the inactive worker -> set the WorkBlog.inProcessBy = "Not in process"
     */
    func checkActiveWorker(){
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        let workerQueue = WorkerQueue.sharedInstance
        
        _ = workerQueue.workerQueueLens.get(workerQueue.workerQueue).map { worker in
            // Check if the worker contains in the activeWorkerQueue
            if(workerQueue.activeWorkerQueueLens.get(workerQueue.activeWorkerQueue).contains({ $0.id == worker.id }) == false){
                // If worker isn't in the activeWorkerQueue -> set worker.status = .Inactive
                //worker.status = .Inactive
                
                //Update the status of the worker to .Inactive
                workerQueue.updateWorkerByID(worker.id, status: .Inactive)
                
                //Check if there is a WorkBlog in the WorkBlogQueue which is "inProcessBy" the inactive Worker
                workBlogQueue.updateAllWorkBlogFromInactiveWorker(worker.id)
            }

        }
        //Remove all worker from the activeWorkerQueue
        workerQueue.activeWorkerQueue.removeAll()
    }

    
    /**
     stops the MasterOperation with Notification
     
     - parameter notification: stopMaster Notifivation
     */
    func stopMasterOperation(notification:NSNotification) {
        run = false
        sendStillAliveMessage = false
        notificationCenter.postNotificationName(Constants.NCValues.stopWorkBlog, object: nil)
        notificationCenter.postNotificationName(Constants.NCValues.toggleStartButton, object: nil)
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object: "MasterOperation stopped")
    }
}

