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
    
    init(id:String, status:Status){
        self.id = id
        self.status = status
    }
}