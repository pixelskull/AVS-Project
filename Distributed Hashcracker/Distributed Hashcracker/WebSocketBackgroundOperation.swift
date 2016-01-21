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
    var socket: WebSocket
    
    var run:Bool = true
    
    static let sharedInstance = WebSocketBackgroundOperation()
    
    override init() {
        socket = WebSocket(url: NSURL(string: "ws://\(host):\(port)")!)
        socket.headers["Sec-WebSocket-Protocol"] = "distributed_hashcracker_protocol"
        
        super.init()
        socket.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stop:", name: "stopWebSocketOperation", object: nil)
    }
    
    override func main() {
        connect()
        while run {
            socket.writeString("foo")
            sleep(1)
        }
    }
    
    
    func connect() {
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
        socket.writePing(NSData())
    }
    
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
