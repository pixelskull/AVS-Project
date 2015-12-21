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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextField.stringValue += "Application started"
        // Do view setup here.
    }
    
}
