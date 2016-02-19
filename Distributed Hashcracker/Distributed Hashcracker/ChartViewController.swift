//
//  ChartViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa
import PlotKit

struct HashValue {
    var time:NSDate
    var hashes:Int
}

class ChartViewController: NSViewController {
    
    var values:[String:[Point]] = [String:[Point]]()
    let startTime = NSDate().timeIntervalSince1970
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    var const = 0.0
    var plotView:PlotView = PlotView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        plotView = setupPlotView()
        self.view.addSubview(plotView)
        
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "update", userInfo: nil, repeats: true)
        let notificationName = Constants.notificationCenterValues.addHashValue
        notificationCenter.addObserver(self, selector: "addHashChartValues:", name: notificationName, object: nil)
    }
    
    func setupPlotView() -> PlotView {
        let plotView = PlotView()
        
        plotView.frame = self.view.frame
        
        var yaxis = Axis(orientation: .Vertical, ticks: .Distance(100.0))
        yaxis.labelAttributes = [NSForegroundColorAttributeName:NSColor.blackColor()]
        
        var xaxis = Axis(orientation: .Horizontal, ticks: .Distance(1.0))
        xaxis.labelAttributes = [NSForegroundColorAttributeName:NSColor.blackColor()]
        
        plotView.addAxis(yaxis)
        plotView.addAxis(xaxis)
        
        return plotView
    }
    
    
    func update() {
        let keys = values.keys.map{ $0 } as [String]
        
        for key in keys {
            let points = PointSet(points: values[key]!)
            plotView.addPointSet(points)
        }
        
    }
    
    func foo() {
        let points = PointSet()
        
        points.pointType = .Disk(radius: 1.0)
        points.lineColor = NSColor.blackColor()
    }
    
//    func increment() {
//        const += 1
//        values.append(Point(x: const, y: const*const))
//    }
    
    
    func addHashChartValues(notification:NSNotification?) {
        if let notification = notification {
            let value:HashValue = notification.object as! HashValue
            let time = value.time.timeIntervalSince1970 - startTime
            values["worker1"]!.append(Point(x: time, y: Double(value.hashes)))
        }
    }
}
