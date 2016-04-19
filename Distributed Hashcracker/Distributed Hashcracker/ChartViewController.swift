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
    let notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        chart.frame = view.frame
        chart.drawGridBackgroundEnabled = false
        view.addSubview(chart)
        
        setupNotificationObserver()
        setupChart()
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
        print(notification)
        if let message = n.object as? ExtendedMessage {
            print("notification is ExtendedMessage")
            
            let hashes = Double(message.values["hash_count"]!)
            let time_needed = Double(message.values["time_needed"]!)
            let worker_id = message.values["worker_id"]!
            
            let workerLabel = worker_id.characters.split{ $0 == "." }.map{ String($0) }.first
            
            let executionFunction:(String, Double, Double) -> Void?
            let xValsForWorker = chart.data!.xVals.filter({$0 == workerLabel})
            switch xValsForWorker.count {
            case 0:
                executionFunction = appendNewDataSetForWorker
                break
            default:
                executionFunction = editExistingDataSetForWorker
                break
            }
            executionFunction(workerLabel!, hashes!, time_needed!)
            
            //Update chart view
            chart.notifyDataSetChanged()
            chart.data?.notifyDataChanged()
            chart.barData?.notifyDataChanged()
            
//            chart.layer?.setNeedsDisplay()
//            chart.animate(yAxisDuration: 0.1)
//            chart.animate(yAxisDuration: 0.1)
        }
    }
    
    func appendNewDataSetForWorker(workerLabel: String, hashes:Double, time_needed:Double) {
        print("appendNewData")
        guard let data = chart.data else { return }
        
        let newDataPoint = BarChartDataEntry(value: (hashes / time_needed), xIndex: data.xVals.count)
//        let newDataSet = BarChartDataSet(yVals: [newDataPoint], label: "hashes per second")
//        newDataSet.colors = ChartColorTemplates.joyful()
        let existingDataSet = data.getDataSetByIndex(0) as! BarChartDataSet
        existingDataSet.addEntry(newDataPoint)
        chart.data = BarChartData(xVals: [workerLabel], dataSet: existingDataSet)
        print("data Appended")
    }
    
    func editExistingDataSetForWorker(workerLabel:String, hashes:Double, time_needed:Double) {
        print("editExistingData")
        guard let data = chart.data else { return }
        
        let dataSet = data.getDataSetByIndex(0) as! BarChartDataSet
        
        let entryIndex = data.xVals.indexOf { $0 == workerLabel}!
        dataSet.removeEntry(xIndex: entryIndex)
        dataSet.addEntry(BarChartDataEntry(value: (hashes / time_needed), xIndex: entryIndex))
        
        print("data edited")
    }
    
    func setupChart() {
        let dataSet = BarChartDataSet(yVals: [], label: "hashes per second")
        dataSet.colors = ChartColorTemplates.joyful()
        chart.data = BarChartData(xVals: [nil], dataSet: dataSet)
        chart.descriptionText = ""
    }
}
