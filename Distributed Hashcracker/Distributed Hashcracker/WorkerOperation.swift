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
    
    var message: Message?
    
    var algorithm:String = ""
    var target:String = ""
    var worker_id:String = ""
    
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
            
            message = getMessageFromQueue()
            
            if message != nil{
                
                print("WorkerOperation message from queue message type",message?.type)
                
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
    
    /**
    Reaction of the server on a newClientRegistrationMessage ->  
     - adding a new Worker to the WorkerQueue
     - sending a setupConfigMessage to the new Worker
    precondition = newClientRegistrationMessage of a new client with his IP
    postcondition = setupConfigMessage with the selected hash algorithm, the target hash and the worker_id was send to the new client
    */
    func newClientRegistration(){
        print("newClientRegistration")
        
        
        let workerIP = "192.168.192.1"
        let workerQueue = WorkerQueue.sharedInstance
        
        //let settingsViewController = SettingsViewController()
        
        let workerQueueLenght = workerQueue.workerQueue.count + 1
        
        print("WorkerQueueLenght: \(workerQueue.workerQueue.count)")
        
        let workerID = "Worker_" + String(workerQueueLenght)
        
        print("WorkerID: " + workerID)
        
        let newWorker = Worker(id: workerID, ip: workerIP, status: .Aktive)
        
        workerQueue.put(newWorker)

        print("WorkerQueueLenght after input Worker: \(workerQueue.workerQueue.count)")
        
        //print("SelectedHashAlgorithm: \(settingsViewController.hashAlgorithmSelected.titleOfSelectedItem)")
        /*
        print("targetHash: \(settingsViewController.hashedPassword)")
        
        
        let setupConfigMessageValues: [String:String] = ["algorithm":settingsViewController.hashAlgorithmSelected.titleOfSelectedItem!, "target":settingsViewController.hashedPassword, "worker_id":workerID]
        
        webSocketBackgroundOperation.socket.write
        (ExtendedMessage(status: MessagesHeader.setupConfig, values: setupConfigMessageValues))
        */
    }
    
    /**
     Reaction of the server on a finishedWorkMessage ->
     - create a new target password blog
     - sending a newWorkBlogMessage to the client which send the finishedWorkMessage
     precondition = finishedWorkMessage from a client
     postcondition = newWorkBlogMessage was send to a client
     */
    func finishedWork(){
        print("finishedWork")
    }
    
    /**
     Reaction of a client on a stillAliveMessage ->
     - send a aliveMessage with his own worker_id
     precondition = stillAliveMessage from the server
     postcondition = aliveMessage was send to the server
     */
    func stillAlive(){
        print("stillAlive")
        
        let messageObject = message?.jsonObject()
        
        let messageValue:String = messageObject!["value"] as! String
        
        print("stillAlive message value: " + messageValue)
        
        //webSocket.sendMessage(BasicMessage(status: MessagesHeader.alive, value: "worker_id"))
        
    }
    
    /**
     Reaction of the server on a aliveMessage ->
     - keep the worker in the workerQueue and the Worker.status = .Aktive
     precondition = aliveMessage with the worker_id from a client
     postcondition = client stays in the workerQueue
     */
    func alive(){
        print("alive")
        
        //webSocket.sendMessage(BasicMessage(status: MessagesHeader.stillAlive, value: "worker_id"))

    }
    
    /**
     Reaction of a client on a setupConfigMessage ->
     - save the selected hash algorithm, the target hash and the worker_id
     precondition = setupConfigMessage with values : {algorithm, target, worker_id}
     postcondition = client has send a finishedWorkMessage to the server
     */
    func setupConfig(){
        print("setupConfig")
        
        algorithm = "MD5"
        target = "test"
        worker_id = "Worker_1"
        
        let messageObject = message?.jsonObject()
        
        print("Algorithm: \(algorithm) Target: \(target) Worker_ID: \(worker_id)")
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
            /*
            if(key == "value"){
            algorithm = value["algorithm"] as! String
            target = value["target"] as! String
            worker_id = value["worker_id"] as! String
            
            print("Algorithm: \(algorithm) Target: \(target) Worker_ID: \(worker_id)")
            }
            */
        }

        newWorkBlog()
        
        //webSocket.sendMessage(BasicMessage(status: MessagesHeader.finishedWork, value: "worker_id"))
        
    }
    
    /**
     Reaction of a client on a newWorkBlogMessage ->
     - client calculats hash values of the array with the new target passwords and checks if the target hash was found
     precondition = newWorkBlogMessage with a array of the new target passwords
     postcondition = calculated and checked hash values -> if(target hash was hit){send hitTargetHashMessage with the hash, the password, the time needed and the worker_id to the server} else {send finishedWorkMessage with the worker_id to the server}
     */
    func newWorkBlog(){
        print("newWorkBlog")
        
        let passwordArray:[String] = ["Bla", "blub", "test"]
        
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
            //webSocket.sendMessage(ExtendedMessage(status: MessagesHeader.hitTargetHash, values: "values"))
            print("Found the searched password -> hitTargetHashMessage was send")
        }
        else{
            //webSocket.sendMessage(BasicMessage(status: MessagesHeader.finishedWork, value: "worker_id"))
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
    func hitTargetHash(){
        print("hitTargetHash")
        
        let messageObject = message?.jsonObject()
        
        for (key, value) in (messageObject)! {
            print("Dictionary key \(key) -  Dictionary value \(value)")
        }

    }
    
    func compareHash(hashAlgorithm: HashAlgorithm, passwordArray:[String], hashedPassword: String) -> Bool{
        
        for password in passwordArray{
            
            let hashedPasswordFromArray = hashAlgorithm.hash(string: password)
            
            if(hashedPasswordFromArray == hashedPassword){
                print("Found the searched password! \(hashedPasswordFromArray) == \(hashedPassword) -> Password = \(password) (\(target))")
                return true
            }
            else{
                print("\(password) isn't the searched password")
            }
        }
        
        return false
        
    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
}
