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

    @IBOutlet var isManager: NSButton!
    @IBOutlet var serverAdressField: NSTextField!
    @IBOutlet var passwordField: NSTextField!
    @IBOutlet var hashAlgorithmSelected: NSPopUpButton!
    @IBOutlet var startStopButton: NSButton!
    
    var hashedPassword: String = ""
    var hashAlgorithm: HashAlgorithm?
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let queue = NSOperationQueue()
    var task = NSTask()
    
    var socket:WebSocket?
    
    private func prepareMasterInterface() {
        serverAdressField.enabled = false
        passwordField.enabled = true
        hashAlgorithmSelected.enabled = true
        
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "this Mac is now Master")
        
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
        
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "this Mac is now Worker")
    }
    
    private func startWorkerBackgroundOperation() {
        let workerOperation = WorkerOperation()
        workerOperation.completionBlock = {
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "WorkerOperation finished")
        }
        startBackgroundOperation(workerOperation)
        
    }
    
    
    private func startMasterBackgroundOperation() {
        let masterOperation = MasterOperation(targetHash: hashedPassword, selectedAlgorithm: String(hashAlgorithmSelected.titleOfSelectedItem))
        masterOperation.completionBlock = {
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "MasterOperation finished")
        }
        startBackgroundOperation(masterOperation)
    }
    
    private func startWebsocketBackgroundOperation() {
        let host:String
        if serverAdressField.stringValue.containsString(",") {
            host = serverAdressField.stringValue.componentsSeparatedByString(", ").first!
        } else {
            host = serverAdressField.stringValue
        }
        
        let webSocketOperation:WebSocketBackgroundOperation
        
        if(isManager.state == NSOnState){
            webSocketOperation = WebSocketBackgroundOperation(host: host, master: true)
        } else{
            webSocketOperation = WebSocketBackgroundOperation(host: host, master: false)
        }
        webSocketOperation.completionBlock = {
            self.notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "WebsocketOperation finished")
        }
        startBackgroundOperation(webSocketOperation)
    }
    
    private func startBackgroundOperation(operation:NSOperation) {
        queue.addOperation(operation)
    }
    
    @IBAction func isServerButtonPressed(sender: NSButton) {
        sender.state == NSOnState ? prepareMasterInterface() : prepareWorkerInterface()
    }
    
    
    @IBAction func StartButtonPressed(sender: NSButton) {
        if sender.state == NSOnState {
            
            var hashAlgorithm: HashAlgorithm?
            notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Selected Hash-Algorithm: " + hashAlgorithmSelected.titleOfSelectedItem!)
            
            switch hashAlgorithmSelected.titleOfSelectedItem!{
            case "MD5":
                hashAlgorithm = HashMD5()
                hashedPassword = hashAlgorithm!.hash(string: passwordField.stringValue)
            case "SHA-128":
                hashAlgorithm = HashSHA()
                hashedPassword = hashAlgorithm!.hash(string: passwordField.stringValue)
            case "SHA-256":
                hashAlgorithm = HashSHA256()
                hashedPassword = hashAlgorithm!.hash(string: passwordField.stringValue)
            default:
                hashedPassword = "Password not successfully hashed"
                break
            }
            
            notificationCenter.postNotificationName(Constants.NCValues.updateLog,
                object: "Hash of the password: " + hashedPassword)
            
            if isManager.state == NSOnState {
                if task.running {
                    task.terminate()
                    task.waitUntilExit()
                }
                
                let resourcePath = NSBundle.mainBundle().resourcePath!
                let serverPath = resourcePath+"/node_server/server.js"
                let launchPath = "/usr/local/bin/node"
                
                task = NSTask.launchedTaskWithLaunchPath(launchPath, arguments: [serverPath])
                sleep(2)
                
                startMasterBackgroundOperation()
            } else { startWorkerBackgroundOperation() }
            
            
            startWebsocketBackgroundOperation()
    
            
        } else {
            notificationCenter.postNotificationName(Constants.NCValues.stopWebSocket,
                object: nil)
            if isManager.state == NSOnState {
                notificationCenter.postNotificationName(Constants.NCValues.stopMaster,
                    object: nil)
            } else {
                notificationCenter.postNotificationName(Constants.NCValues.stopWorker,
                    object: nil)
            }
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
        
        notificationCenter.addObserver(self,
            selector: "stopServerTask:",
            name: Constants.NCValues.stopServer,
            object: nil)
        
        notificationCenter.addObserver(self,
            selector: "toggleStartStopButton:",
            name: Constants.NCValues.toggleStartButton,
            object: nil)
    }
    
    
    func stopServerTask(notification:NSNotification) {
        notificationCenter.postNotificationName(Constants.NCValues.updateLog,
            object: "terminating server task")
        task.terminate()
        task.waitUntilExit()
    }
    
    func toggleStartStopButton(notification:NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.startStopButton.state = NSOffState
            self.view.needsDisplay = true
            self.view.display()
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

