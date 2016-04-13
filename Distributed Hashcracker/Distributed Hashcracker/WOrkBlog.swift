//
//  Worker.swift
//  Distributed Hashcracker
//
//  Created by Multitouch on 11.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class WorkBlog{
    
    let id:String
    //    var ip:String
    var value:String
    var inProcessBy:String
    
    
    init(id:String, value:String, inProcessBy:String = "Not in process"){
        self.id = id
        self.value = value
        self.inProcessBy = inProcessBy
    }
    
}