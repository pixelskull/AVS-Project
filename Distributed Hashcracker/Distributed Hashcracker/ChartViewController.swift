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

class ChartViewController: NSViewController, ChartViewDelegate {
    
    let chart = LineChartView()
    let data = [1.0, 7.0, 3.0, 5.0, 3.0, 4.0, 2.0]

    override func viewDidLoad() {
        super.viewDidLoad()
    
        chart.frame = view.frame
        chart.drawGridBackgroundEnabled = false
        view.addSubview(chart)
        
        setChartData(data)
//        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "update", userInfo: nil, repeats: true)
//        let notificationName = Constants.NCValues.addHashValue
//        notificationCenter.addObserver(self, selector: "addHashChartValues:", name: notificationName, object: nil)
    }
    
    func setChartData(data:[Double]) {
        
        var ydata = [ChartDataEntry]()
        for i in 0..<data.count {
            ydata.append(ChartDataEntry(value: data[i], xIndex: i))
        }
        
        let dataSet = LineChartDataSet(yVals: ydata, label: "computed hashes")
        dataSet.cubicIntensity = 0.2
        dataSet.drawCubicEnabled = true
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 1.0
        dataSet.setColor(NSColor.redColor())
        dataSet.fillColor = NSColor.redColor()
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 0.6
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let chartData = LineChartData(xVals: ["1", "2", "3", "4", "5", "6", "7"], dataSet: dataSet)
        
        chart.data = chartData
    }
}
