//
//  BruteforceAttack.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 07.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class BruteForceAttack:NSObject, AttackStrategy {
    
    var generateLoopRun = true
    var workBlogID:Int = 1
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    //Array with characters for the password crack
    let charArray = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
                     "o", "p", "q", "r", "s", "t", "i", "v", "w", "x", "y", "z", "A", "B",
                     "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                     "Q", "R", "S", "T", "I", "V", "W", "X", "Y", "Z", "1", "2", "3", "4",
                     "5", "6", "7", "8", "9", "0"]
    
    override init() {
        super.init()
        notificationCenter.addObserver(self,
            selector: #selector(self.stopWorkBlogGeneration(_:)),
            name: Constants.NCValues.stopWorkBlog,
            object: nil)
    }
    
    //The first WorkBlock includes the passwords with the lenght of one and two characters
    func appendToArrayFirstTime(array:[String], toAppend:[String]) -> [String]{
        var tmpArray:[String] = [String]()
        
        _ = toAppend.map{ char in
            tmpArray += array.map({ return $0 + char })
        }
        
        let firstWorkArray = charArray + tmpArray
        let firstWorkBlog = WorkBlog(id: "B\(workBlogID)", value: firstWorkArray.joinWithSeparator(","))
        workBlogID += 1
        
        let workBlogQueue = WorkBlogQueue.sharedInstance
        workBlogQueue.put(firstWorkBlog)
        
        return tmpArray
    }
    
    //New WorkBlogs with password lenght of 3 till 10 characters
    func generateWorkBlogs(array:[String], toAppend:[String]) -> [String]{
        var currentArray:[String] = [String]()
        var tmpArray = [String]()
        
        _ = toAppend.map{ char in
            _ = array.splitBy(100).map { subset in
                tmpArray += subset.map{ $0 + char }
                if tmpArray.count > 7000 {
                    //Wait with the generating of a new WorkBlock until the WorkBlogQueue isn't full
                    waitLoop: while(WorkBlogQueue.sharedInstance.getWorkBlogQueueCount() > (WorkerQueue.sharedInstance.getWorkerQueueCount()*2)){
                        guard generateLoopRun == true else { break waitLoop }
                    }
                    let workBlog = WorkBlog(id: "B\(workBlogID)", value: tmpArray.joinWithSeparator(","))
                    workBlogID += 1
                    
                    let queue = dispatch_queue_create("\(Constants.queueID).saveWorkBlock", nil)
                    dispatch_async(queue) {
                        let workBlogQueue = WorkBlogQueue.sharedInstance
                        workBlogQueue.put(workBlog)
                    }
                    
                    currentArray += tmpArray
                    tmpArray.removeAll()
                }
            }
        }
        currentArray += tmpArray
        return currentArray
    }
    
    func fillWorkBlogQueue() {
        var result = [String]()
        var index = 0
        generateLoop: while true {
            guard generateLoopRun == true else { break generateLoop }
            if(index == 0){ result = appendToArrayFirstTime(charArray, toAppend: charArray) }
            else{ result = generateWorkBlogs(result, toAppend: charArray) }
            index += 1
        }
    }
    
    func stopWorkBlogGeneration(notification:NSNotification) {
        generateLoopRun = false
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object: "WorkBlog generation stopped")
    }
}