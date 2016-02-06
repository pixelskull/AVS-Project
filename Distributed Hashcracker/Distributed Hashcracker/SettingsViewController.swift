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
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let queue = NSOperationQueue()
    let task = NSTask()
    
    private func prepareMasterInterface() {
        serverAdressField.enabled = false
        passwordField.enabled = true
        hashAlgorithmSelected.enabled = true
        
        notificationCenter.postNotificationName("updateLog", object: "this Mac is now Master")
        
        let hostName = NSHost.currentHost().name
        if hostName!.characters.count <= 40 {
            serverAdressField.stringValue = hostName!
        } else {
            let validIPs = getValidIPs(NSHost.currentHost().addresses, show_ipV6: false)
            for ip in validIPs {
                serverAdressField.stringValue += ip + ", "
            }
        }
    }
    
    private func prepareWorkerInterface() {
        serverAdressField.stringValue = ""
        serverAdressField.enabled = true
        passwordField.enabled = false
        hashAlgorithmSelected.enabled = false
        
        notificationCenter.postNotificationName("updateLog", object: "this Mac is now Worker")
    }
    
    private func startBackgroundOperation() {
        let host:String
        if serverAdressField.stringValue.containsString(",") {
//            let firstIP = serverAdressField.stringValue.componentsSeparatedByString(",").first!
            host = "127.0.0.1"
        } else {
            host = serverAdressField.stringValue
        }
        
        let backgroundOperation = WebSocketBackgroundOperation(host: host)
        queue.addOperation(backgroundOperation)
        backgroundOperation.completionBlock = { print("operation finished") }
    }
    
    @IBAction func isServerButtonPressed(sender: NSButton) {
        sender.state == NSOnState ? prepareMasterInterface() : prepareWorkerInterface()
    }
    
    
    @IBAction func StartButtonPressed(sender: NSButton) {
        if sender.state == NSOnState {
            
            var hashAlgorith: HashAlgorith?
            NSNotificationCenter.defaultCenter().postNotificationName("updateLog", object: "Selected Hash-Algorithm: " + hashAlgorithmSelected.titleOfSelectedItem!)
            
            var hashedPassword: String = ""
            switch hashAlgorithmSelected.titleOfSelectedItem!{
            case "MD5":
                hashAlgorith = HashMD5()
                hashedPassword = hashAlgorith!.hash(string: passwordField.stringValue)
            case "SHA-128":
                hashAlgorith = HashSHA()
                hashedPassword = hashAlgorith!.hash(string: passwordField.stringValue)
            case "SHA-256":
                hashAlgorith = HashSHA256()
                hashedPassword = hashAlgorith!.hash(string: passwordField.stringValue)
            default:
                hashedPassword = "Password not successfully hashed"
                break
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("updateLog", object: "Hash of the password: " + hashedPassword)
            
            if isManager.state == NSOnState {
                let resourcePath = NSBundle.mainBundle().resourcePath!
                task.arguments = [resourcePath+"/node_server/server.js"]
                task.launchPath = "/usr/local/bin/node"
                task.launch()
                sleep(1)
            }
            startBackgroundOperation()
        } else {
            notificationCenter.postNotificationName("stopWebSocketOperation", object: nil)
        }
    }
    
    func getValidIPs(addresses:[String], show_ipV4:Bool = true, show_ipV6:Bool = true) -> [String] {
        return addresses.filter({ address -> Bool in
            let sAddress = ServerIP(address: address)
            
            if !sAddress.isLocalHost() {
                if sAddress.isIPV4() && show_ipV4{
                    return true
                } else if sAddress.isIPV6() && show_ipV6 {
                    return true
                }
            }
            return false
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.enabled = false
        hashAlgorithmSelected.enabled = false
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    deinit {
        task.terminate()
    }
}

