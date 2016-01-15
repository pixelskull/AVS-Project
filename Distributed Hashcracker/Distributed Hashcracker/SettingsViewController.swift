//
//  ViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 08.12.15.
//  Copyright © 2015 Pascal Schönthier. All rights reserved.
//

import Cocoa
import Starscream

class SettingsViewController: NSViewController {

    @IBOutlet weak var isManager: NSButton!
    @IBOutlet var serverAdressField: NSTextField!
    @IBOutlet var passwordField: NSTextField!
    @IBOutlet var hashAlgorithmSelected: NSPopUpButton!
    
    let socket = WebSocket(url: NSURL(string: "http://localhost:3000/")!)
    
    
    @IBAction func isServerButtonPressed(sender: NSButton) {
        if sender.state == 1 {
            serverAdressField.stringValue = "127.0.0.1"
            serverAdressField.enabled = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("updateLog", object: "this Mac is now Master")
        } else {
            serverAdressField.stringValue = ""
            serverAdressField.enabled = true
            
            NSNotificationCenter.defaultCenter().postNotificationName("updateLog", object: "this Mac is now Worker")
        }
        
        // TODO: Setup Server
    }
    
    
    @IBAction func StartButtonPressed(sender: NSButton) {
        
        let socket = WebSocket(url: NSURL(string: "ws://localhost:3000")!)
        
        socket.headers["Sec-WebSocket-Protocol"] = "echo-protocol"
        
        //websocketDidConnect
        socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: NSError?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
        }
        //websocketDidReceiveData
        socket.onData = { (data: NSData) in
            print("got some data: \(data.length)")
        }
        //you could do onPong as well.
        socket.connect()
        print("socketConnection")
        if socket.isConnected {
            socket.writeString("test Foo")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

