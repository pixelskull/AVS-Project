//
//  LogViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.12.15.
//  Copyright © 2015 Pascal Schönthier. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController {
    
    @IBOutlet var logTextView: NSTextView!
   
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.editable = false
        logTextView.string = "Application started \n"
        notificationCenter.addObserver(self, selector: "updateLogTextField:", name: "updateLog", object: nil)
    }
    
    func updateLogTextField(notification:AnyObject?) {
        guard let message = notification!.object else {
            logTextView.string! += "unrecognized message send \n"
            return
        }
        logTextView.string! += "\(String(message!))\n"
        
        // scroll to end
        let textViewStringLength = logTextView.string!.characters.count
        let range:NSRange = NSMakeRange(textViewStringLength, 0)
        logTextView.scrollRangeToVisible(range)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChartView" {
            logTextView.string! += "showing ChartView \n"
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
