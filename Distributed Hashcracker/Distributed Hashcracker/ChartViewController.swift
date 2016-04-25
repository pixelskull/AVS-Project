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

    let semaphore = dispatch_semaphore_create(1)

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        chart.frame = view.frame
        chart.drawGridBackgroundEnabled = false
        view.addSubview(chart)
        
        setupNotificationObserver()
        setupChart()
        
        NSTimer.scheduledTimerWithTimeInterval(0.3,
                                               target: self,
                                               selector: #selector(self.updateChart),
                                               userInfo: nil,
                                               repeats: true)

    }
    
    func setupNotificationObserver() {
        notificationCenter.addObserver(self,
                                       selector: #selector(self.updateBarChart(_:)),
                                       name: Constants.NCValues.updateChartView,
                                       object: nil)
    }
    
    func updateBarChart(notification:AnyObject?) {
        print("updateBarChart")
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let n = notification else { return }
            print(notification)
            if let message = n.object as? ExtendedMessage {
                print("notification is ExtendedMessage")
                
                let hashes = Double(message.values["hash_count"]!)
                let time_needed = Double(message.values["time_needed"]!)
                let worker_id = message.values["worker_id"]!
                
                let workerLabel = worker_id.characters.split{ $0 == "." }.map{ String($0) }.first
                
                let executionFunction:(String, Double, Double) -> Void?
                let xValsForWorker = self.chart.data!.xVals.filter({$0 == workerLabel})
                switch xValsForWorker.count {
                case 0:
                    executionFunction = self.appendNewDataSetForWorker
                    break
                default:
                    executionFunction = self.editExistingDataSetForWorker
                    break
                }
                executionFunction(workerLabel!, hashes!, time_needed!)
                
            }

        }
        
    }
    
    func appendNewDataSetForWorker(workerLabel: String, hashes:Double, time_needed:Double) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        guard let data = chart.data else { return }
        
        let newDataPoint = BarChartDataEntry(value: (hashes / time_needed), xIndex: data.xVals.count)
        let existingDataSet = data.getDataSetByIndex(0) as! BarChartDataSet
        existingDataSet.addEntry(newDataPoint)
        let existingDataLabels  = data.xVals
        chart.data = BarChartData(xVals: (existingDataLabels + [workerLabel] as [String?]), dataSet: existingDataSet)
        dispatch_semaphore_signal(semaphore)
    }
    
    func editExistingDataSetForWorker(workerLabel:String, hashes:Double, time_needed:Double) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        guard let data = chart.data else { return }
        
        let dataSet = data.getDataSetByIndex(0) as! BarChartDataSet
        
        if let entryIndex = data.xVals.indexOf({ $0 == workerLabel }) {
            dataSet.entryForXIndex(entryIndex)?.value = (hashes / time_needed)
        } else {
            print("no entry found...")
        }
        dispatch_semaphore_signal(semaphore)
    }
    
    func updateChart() {
        self.chart.data?.notifyDataChanged()
        self.chart.barData?.notifyDataChanged()
        self.chart.notifyDataSetChanged()
    }
    
    func setupChart() {
        let dataSet = BarChartDataSet(yVals: [], label: "hashes per second")
        dataSet.colors = ChartColorTemplates.joyful()

        chart.data = BarChartData(xVals: [String](), dataSet: dataSet)
        chart.descriptionText = ""
        
        chart.rightAxis.enabled = false
        chart.leftAxis.customAxisMin = 0
        chart.leftAxis.customAxisMax = 25000
        
    }
}
