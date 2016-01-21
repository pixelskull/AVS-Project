//
//  LogViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.12.15.
//  Copyright © 2015 Pascal Schönthier. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController {
    
    @IBOutlet var logTextField: NSTextField!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextField.stringValue += "Application started \n"
        notificationCenter.addObserver(self, selector: "updateLogTextField:", name: "updateLog", object: nil)
    }
    
    func updateLogTextField(notification:AnyObject?) {
        guard let message = notification!.object else {
            logTextField.stringValue += "unrecognized message send \n"
            return
        }
        logTextField.stringValue += "\(String(message!))\n"
    }
    
}
