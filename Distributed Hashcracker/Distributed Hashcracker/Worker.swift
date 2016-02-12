//
//  Worker.swift
//  Distributed Hashcracker
//
//  Created by Multitouch on 11.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class Worker{
    
    let id:String
    var status:String
    
    init(id:String, status:String){
        self.id = id
        self.status = status
    
    }
    
    func getID() -> String{
        return id
    }
    
    func getStatus() -> String{
        return status
    }
    
    func setStatus(newStatus:String){
        status = newStatus
    }
    
    
}