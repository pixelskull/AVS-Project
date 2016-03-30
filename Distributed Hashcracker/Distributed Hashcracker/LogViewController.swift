//
//  LogViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 21.12.15.
//  Copyright © 2015 Pascal Schönthier. All rights reserved.
//

import Cocoa

typealias LogView = NSTextView

class LogViewController: NSViewController {
    
    @IBOutlet var logTextView: LogView! {
        didSet { // scroll to end
            let textViewStringLength = logViewLens.get(logTextView).characters.count
            let range:NSRange = NSMakeRange(textViewStringLength, 0)
            logTextView.scrollRangeToVisible(range)
        }
    }
    let logViewLens = Lens<LogView, String>(
        get: { (textView:LogView) in
            textView.string!
        },
        set: { (newValue:String, logView:LogView) in
            logView.string! += newValue
            return logView
        }
    )
    let semaphore = dispatch_semaphore_create(1)
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.editable = false
        logTextView = logViewLens.set("Application started \n", logTextView)
        let notificationName = Constants.NCValues.updateLog
        notificationCenter.addObserver(self, selector: #selector(self.updateLogTextField(_:)), name: notificationName, object: nil)
    }
    
    func updateLogTextField(notification:AnyObject?) {
        
        guard let message = notification!.object else {
            dispatch_async(dispatch_get_main_queue()) {
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
                self.logTextView = self.logViewLens.set("unrecognized message send \n", self.logTextView)
                dispatch_semaphore_signal(self.semaphore)
            }
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            self.logTextView = self.logViewLens.set("\(message!)\n", self.logTextView)
            dispatch_semaphore_signal(self.semaphore)
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChartView" {
            dispatch_async(dispatch_get_main_queue()) {
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
                self.logTextView = self.logViewLens.set("showing ChartView \n", self.logTextView)
                dispatch_semaphore_signal(self.semaphore)
            }
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

