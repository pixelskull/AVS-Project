//
//  Worker.swift
//  Distributed Hashcracker
//
//  Created by Multitouch on 11.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class Worker{
    
    enum Status {
        case Aktive
        case Inactive
    }
    
    let id:String
    var status:Status
    
    var algorithm:String?
    var target:String?
    
    init(id:String, status:Status){
        self.id = id
        self.status = status
    }
    
    /**
     checks if given WorkerID ist equal with own WorkerID
     
     - parameter workerID: workerID to check (from Message)
     
     - returns: true if workerID ist equal to own id
     */
    func checkWorkerID(workerID:String) -> Bool {
        return id == workerID ? true : false
    }
}