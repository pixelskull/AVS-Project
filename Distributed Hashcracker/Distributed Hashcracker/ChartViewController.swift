//
//  ChartViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa
import Charts

struct HashValue {
    var time:NSDate
    var hashes:Int
}

class ChartViewController: NSViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "update", userInfo: nil, repeats: true)
//        let notificationName = Constants.NCValues.addHashValue
//        notificationCenter.addObserver(self, selector: "addHashChartValues:", name: notificationName, object: nil)
    }
}
