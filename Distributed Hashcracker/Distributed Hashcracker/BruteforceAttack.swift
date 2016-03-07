//
//  BruteforceAttack.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 07.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class BruteForceAttack: AttackStrategy {
    
    var generateLoopRun = true
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    init() {
        notificationCenter.addObserver(self,
            selector: "stopWorkBlogGeneration:",
            name: Constants.NCValues.stopWorkBlog,
            object: nil)
    }
    
    func fillWorkBlogQueue() {
        var workBlogID:Int = 1
        let workBlogQueue = WorkBlogQueue.sharedInstance
        //Array with characters for the password crack
        let charArray = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
            "o", "p", "q", "r", "s", "t", "i", "v", "w", "x", "y", "z", "A", "B",
            "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
            "Q", "R", "S", "T", "I", "V", "W", "X", "Y", "Z", "1", "2", "3", "4",
            "5", "6", "7", "8", "9", "0"]
        
        //The first WorkBlock includes the passwords with the lenght of one and two characters
        func appendToArrayFirstTime(array:[String], toAppend:[String]) -> [String]{
            var tmpArray:[String] = [String]()
            
            for char in toAppend { tmpArray += array.map({ return $0 + char }) }
            
            let firstWorkArray = charArray + tmpArray
            let firstWorkBlog = WorkBlog(id: String(workBlogID), value: firstWorkArray)
            workBlogID += 1
            workBlogQueue.put(firstWorkBlog)
            
            return tmpArray
        }
        
        //New WorkBlogs with password lenght of 3 till 10 characters
        func generateWorkBlogs(array:[String], toAppend:[String]) -> [String]{
            var currentArray:[String] = [String]()
            var tmpArray = [String]()
            for char in toAppend {
                //Split the array toAppend
                for subset in array.splitBy(100) {
                    tmpArray += subset.map{ $0 + char }
                    if tmpArray.count > 5000 {
                        let workerCount = WorkerQueue.sharedInstance.workerQueue.count
                        //Wait with the generating of a new WorkBlock until the WorkBlogQueue isn't full
                        waitLoop: while(WorkBlogQueue.sharedInstance.workBlogQueue.count > workerCount){
                            print("WorkBlogQueue noch voll")
                            guard generateLoopRun == true else { break waitLoop }
                        }
                        let workBlog = WorkBlog(id: String(workBlogID), value: tmpArray)
                        workBlogID += 1
                        workBlogQueue.put(workBlog)
                        
                        currentArray += tmpArray
                        tmpArray.removeAll()
                    }
                }
            }
            currentArray += tmpArray
            return currentArray
        }
        
        var result = [String]()
        var index = 0
        generateLoop: while true { // for var index = 0; index < 9; ++index {
            guard generateLoopRun == true else { break generateLoop }
            if(index == 0){
                print("Generate passwords with lenght: \(index+1) and \(index+2)")
                result = appendToArrayFirstTime(charArray, toAppend: charArray)
            }
            else{
                print("Generate passwords with lenght: \(index+2)")
                result = generateWorkBlogs(result, toAppend: charArray)
            }
            index += 1
        }
    }
    
    func stopWorkBlogGeneration(notification:NSNotification) {
        generateLoopRun = false
        notificationCenter.postNotificationName(Constants.NCValues.updateLog, object: "WorkBlog generation stopped")
    }
}