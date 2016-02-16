//
//  ChartViewController.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 10.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Cocoa

class ChartViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let lineChart = LineChart()
        lineChart.addLine([5.0,4.0,3.0,2.0])
        
        view.addSubview(lineChart)
        print(view)
//        view.setNeedsDisplayInRect(view.frame)
//        view.addSubview(lineChart, positioned: .Above, relativeTo: view)
        
//        if let lineChart:LineChart = dummyLayer as? LineChart {
//            let data: [CGFloat] = [3.0, 4.0, 9.0, 11.0, 13.0, 15.0]
//            lineChart.datasets += [ LineChart.Dataset(label: "My Data", data: data) ]
//        } else {
//            print("not working Chart")
//        }
    }
    
}
