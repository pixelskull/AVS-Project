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
            
            //Test send alive message
            let jsonString = jsonParser.createJSONStringFromMessage(BasicMessage(status: MessagesHeader.alive, value: "true"))
            socket.writeString(jsonString!)
            sleep(1)
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
