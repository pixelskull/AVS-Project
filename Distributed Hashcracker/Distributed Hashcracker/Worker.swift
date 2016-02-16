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
//    var ip:String
    var status:Status
    
    init(id:String, /*ip:String,*/ status:Status){
        self.id = id
//        self.ip = ip
        self.status = status
    
    }
    
    func getID() -> String{
        return id
    }
    
//    func getIP() -> String{
//        return ip
//    }
//    
//    func setIP(newIP:String){
//        ip = newIP
//    }
    
    func getStatus() -> Status{
        return status
    }
    
    func setStatus(newStatus:Status){
        status = newStatus
    }
    
    
}