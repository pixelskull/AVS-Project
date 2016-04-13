//
//  ChartViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa
import Charts


class ChartViewController: NSViewController, ChartViewDelegate {
    
    let chart = BarChartView()
    let data = [1.0, 7.0, 3.0, 5.0, 3.0, 4.0, 2.0]
    
    let notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        chart.frame = view.frame
        chart.drawGridBackgroundEnabled = false
        view.addSubview(chart)
        
        setupNotificationObserver()
        
        setChartData(data)
    }
    
    func setupNotificationObserver() {
        notificationCenter.addObserver(self,
                                       selector: #selector(self.updateBarChart(_:)),
                                       name: Constants.NCValues.updateChartView,
                                       object: nil)
    }
    
    func updateBarChart(notification:AnyObject?) {
        print("updateBarChart")
        guard let n = notification else { return }
        if n is ExtendedMessage {
            let hashes = n.values["hash_count"]
            let time_needed = n.values["time_needed"]
            let worker_id = n.values["worker_id"]
            
            print(hashes)
            print(time_needed)
            print(worker_id)
        }
    }
    
    func setChartData(data:[Double]) {
        var ydata = [ChartDataEntry]()
        for i in 0..<data.count {
            ydata.append(BarChartDataEntry(value: data[i], xIndex: i))
        }
        
        let dataSet = BarChartDataSet(yVals: ydata, label: "hashes per second")
        let chartData = BarChartData(xVals: ["pip1", "pip2", "pip3", "pip4", "pip5", "pip6", "pip7"], dataSet: dataSet)
        
        dataSet.colors = ChartColorTemplates.joyful() // thx Bob Ross
        dataSet.highlightAlpha = 0.5
        
        
        chart.data = chartData
    }
}
