//
//  WebSocketClient.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 15.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//
import Foundation
import Starscream

class WebSocketBackgroundOperation:NSOperation,  WebSocketDelegate {

    var socket: WebSocket
    
    var master: Bool = true
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
   
    init(host:String = "localhost", port:Int = 3000, master:Bool) {
        socket = WebSocket(url: NSURL(string: "ws://\(host):\(port)")!)
        socket.headers["Sec-WebSocket-Protocol"] = "distributed_hashcracker_protocol"
        self.master = master
        super.init()
        socket.delegate = self
        
        let stopWSNotificationName = Constants.NCValues.stopWebSocket
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: stopWSNotificationName,
            object: nil)
        let sendMessageNotificationName = Constants.NCValues.sendMessage
        notificationCenter.addObserver(self,
            selector: "sendMessage:",
            name: sendMessageNotificationName,
            object: nil)
    }
    
    override func main() {
        connect()
        runloop: while true {
            if run == false { break runloop }

            sleep(1)
        }
        run = true
    }
    
    func connect() { socket.connect() }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    
        if(master == false){
            let workerID = NSHost.currentHost().name!
            
            notificationCenter.postNotificationName(Constants.NCValues.sendMessage,
                object: BasicMessage(status: MessagesHeader.newClientRegistration, value: workerID))
            let worker = Worker(id: workerID, status: .Aktive)
            
            let workerQueue = WorkerQueue.sharedInstance
            workerQueue.put(worker)
            
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func sendMessage(notification:NSNotification) {
        guard let message = notification.object as? Message else { return }
        let jsonStringSendMessage = jsonParser.createJSONStringFromMessage(message)
        socket.writeString(jsonStringSendMessage!)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if let newMessage = jsonParser.createMessageFromJSONString(dataString) {
            messageQueue.put(newMessage)
        }
    }
    

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if let newMessage = jsonParser.createMessageFromJSONString(text) {
            messageQueue.put(newMessage)
        } else {
            print("failed to parse message: \(text)")
        }
    }

    
    func stop(notification:NSNotification) {
        run = false
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object: "WorkerOperation stopped")
    }
    
    deinit {}
}
