//
//  WebSocketClient.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 15.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//
import Foundation
import Starscream

class WebSocketBackgroundOperation:NSOperation, WebSocketDelegate {

    var socket: WebSocket
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    let jsonParser = MessageParser()
   
    
    init(host:String = "localhost", port:Int = 3000) {
        
        print("----"+host+"---")
        socket = WebSocket(url: NSURL(string: "ws://\(host):\(port)")!)
        socket.headers["Sec-WebSocket-Protocol"] = "distributed_hashcracker_protocol"
        
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
            
            //sleep(5)
            
            /*
            let newWorkBlog: [String:String] = ["Value1":"Test", "Value2":"Blub", "Value3":"Bla"]
            let hitTargetHash: [String:String] = ["Value1":"hash", "Value2":"password", "Value3":"time"]
            let setupConfig: [String:String] = ["algorith":"MD5", "target":"test", "worker_id":"Worker_1"]
            */
            /*
            let newWorkBlog2: [String:String] = ["Value1":"Bla", "Value2":"Bli", "Value3":"Blu"]
            */

            //Test send alive message

//            let jsonStringFinishedWork = jsonParser.createJSONStringFromMessage(BasicMessage(status: .finishedWork, value: "I have done my work"))
//            socket.writeString(jsonStringFinishedWork!)
//            
//            sleep(5)
//            
//            let jsonStringNewClient = jsonParser.createJSONStringFromMessage(BasicMessage(status: .newClientRegistration, value: "pip04.local"))
//            socket.writeString(jsonStringNewClient!)
//
//            
//            sleep(5)
            
//            let jsonStringAlive = jsonParser.createJSONStringFromMessage(BasicMessage(status: .alive, value: "Are you alive"))
//            socket.writeString(jsonStringAlive!)
//
            
//
//            let jsonStringNewClient = jsonParser.createJSONStringFromMessage(BasicMessage(status: .newClientRegistration, value: "pip03.local"))
//            socket.writeString(jsonStringNewClient!)
//            
//            let jsonStringStillAlive = jsonParser.createJSONStringFromMessage(BasicMessage(status: .stillAlive, value: "true"))
//            socket.writeString(jsonStringStillAlive!)
//            
//            let jsonStringSetupConfig = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: .setupConfig, values: setupConfig))
//            socket.writeString(jsonStringSetupConfig!)
//            
//            let jsonStringNewWorkBlog = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: .newWorkBlog, values: newWorkBlog))
//            socket.writeString(jsonStringNewWorkBlog!)
//            
//            let jsonStringHitTargetHash = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: .hitTargetHash, values: hitTargetHash))
//            socket.writeString(jsonStringHitTargetHash!)
            
            /*
            let jsonStringNewWorkBlog2 = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: MessagesHeader.newWorkBlog, values: newWorkBlog2))
            socket.writeString(jsonStringNewWorkBlog2!)
            */
            

            sleep(10)
        }
        run = true
    }
    
    func connect() { socket.connect() }
    
    func websocketDidConnect(socket: WebSocket) { print("websocket is connected") }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func sendMessage(notification:NSNotification) {
        
        guard let message = notification.object as? Message else { return }

        let messageObject = message.jsonObject()

        for (key, value) in (messageObject) {
            	print("WSBO sendMessage -> Dictionary key \(key) -  Dictionary value \(value)")
        }
        
        let jsonStringSendMessage = jsonParser.createJSONStringFromMessage(message)
        socket.writeString(jsonStringSendMessage!)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("got some data: \(data.length)")
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if let newMessage = jsonParser.createMessageFromJSONString(dataString) {
            messageQueue.put(newMessage)
        }
    }
    

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        
        /*ToDo: Überprüfen ob die Message für Client (worker_id from message == NSHost.currentHost().name! && Message.status == message for worker) oder für Server (isManager.state == NSOnState && Message.status == message for master) relevant ist
        */

        if let newMessage = jsonParser.createMessageFromJSONString(text) {
            messageQueue.put(newMessage)
        } else {
            print("failed to parse: \(text)")
        }
    }
//    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
//        print("got some text: \(text)")
//        if let newMessage = jsonParser.createMessageFromJSONString(text) {
//            messageQueue.put(newMessage)
//        }
//    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
    deinit {}
}
