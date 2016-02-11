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
        socket = WebSocket(url: NSURL(string: "ws://\(host):\(port)")!)
        
        super.init()
        socket.headers["Sec-WebSocket-Protocol"] = "distributed_hashcracker_protocol"
        socket.delegate = self
        notificationCenter.addObserver(self,
            selector: "stop:",
            name: "stopWebSocketOperation",
            object: nil)
    }
    
    override func main() {
        connect()
        runloop: while true {
            if run == false { break runloop }
            
            let newWorkBlog: [String:String] = ["Value1":"Test", "Value2":"Blub", "Value3":"Bla"]
            let hitTargetHash: [String:String] = ["Value1":"hash", "Value2":"password", "Value3":"time"]
            let setupConfig: [String:String] = ["Value1":"algorith", "Value2":"target hash", "Value3":"worker id"]
            
            //Test send alive message
            let jsonString = jsonParser.createJSONStringFromMessage(BasicMessage(status: MessagesHeader.alive, value: ""))
            socket.writeString(jsonString!)
            
            let jsonStringSetupConfig = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: MessagesHeader.setupConfig, values: setupConfig))
            socket.writeString(jsonStringSetupConfig!)
            
            let jsonStringHitTargetHash = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: MessagesHeader.hitTargetHash, values: hitTargetHash))
            socket.writeString(jsonStringHitTargetHash!)

            let jsonStringNewWorkBlog = jsonParser.createJSONStringFromMessage(ExtendedMessage(status: MessagesHeader.newWorkBlog, values: newWorkBlog))
            socket.writeString(jsonStringNewWorkBlog!)
            
            
            
            let jsonStringStillAlive = jsonParser.createJSONStringFromMessage(BasicMessage(status: MessagesHeader.stillAlive, value: "true"))
            socket.writeString(jsonStringStillAlive!)
            sleep(10)
        }
        run = true
    }
    
    func connect() { socket.connect() }
    
    func websocketDidConnect(socket: WebSocket) { print("websocket is connected") }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
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
        if let newMessage = jsonParser.createMessageFromJSONString(text) {
            messageQueue.put(newMessage)
        }
    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
    deinit {}
}
