//
//  MasterWorkerOperationProtocol.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 19.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class MasterWorkerOperation:NSOperation {
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
    
    /*
    Universal Message reactions
    */
    
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
}