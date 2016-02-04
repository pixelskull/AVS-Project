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
    
    let host: String = "localhost"
    let port: Int = 3000
    let socket: WebSocket
    
    var run:Bool = true
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let messageQueue = MessageQueue.sharedInstance
    
    override init() {
        socket = WebSocket(url: NSURL(string: "ws://\(host):\(port)")!)
        socket.headers["Sec-WebSocket-Protocol"] = "distributed_hashcracker_protocol"
        
        super.init()
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
            socket.writeString("dummy message")
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
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func stop(notification:NSNotification) {
        run = false
    }
    
    deinit {}
}
