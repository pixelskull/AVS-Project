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
    
    let queue = NSOperationQueue()
    
    
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
        if sender.state == NSOnState {
            let backgroundOperation = WebSocketBackgroundOperation()
            queue.addOperation(backgroundOperation)
            //        backgroundOperation.threadPriority = 0
            backgroundOperation.completionBlock = {
                print("operation finished")
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("stopWebSocketOperation", object: nil)
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

