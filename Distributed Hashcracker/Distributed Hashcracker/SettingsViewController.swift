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
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    let queue = NSOperationQueue()
    
    
    private func prepareMasterInterface() {
        serverAdressField.stringValue = "127.0.0.1"
        serverAdressField.enabled = false
        passwordField.enabled = true
        
        notificationCenter.postNotificationName("updateLog", object: "this Mac is now Master")
    }
    
    private func prepareWorkerInterface() {
        serverAdressField.stringValue = ""
        serverAdressField.enabled = true
        passwordField.enabled = false
        
        notificationCenter.postNotificationName("updateLog", object: "this Mac is now Worker")
    }
    
    private func startBackgroundOperation() {
        let backgroundOperation = WebSocketBackgroundOperation()
        queue.addOperation(backgroundOperation)
        backgroundOperation.completionBlock = { print("operation finished") }
    }
    
    @IBAction func isServerButtonPressed(sender: NSButton) {
        sender.state == NSOnState ? prepareMasterInterface() : prepareWorkerInterface()
    }
    
    
    @IBAction func StartButtonPressed(sender: NSButton) {
        if sender.state == NSOnState {
            startBackgroundOperation()
        } else {
            notificationCenter.postNotificationName("stopWebSocketOperation", object: nil)
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

