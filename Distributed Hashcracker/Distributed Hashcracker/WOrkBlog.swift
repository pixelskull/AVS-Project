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
    var value:[String]
    
    init(id:String, value:[String]){
        self.id = id
        self.value = value
        
    }
    
    func getID() -> String{
        return id
    }
    
    
    func getValue() -> [String]{
        return value
    }
    
    func setValue(newValue:[String]){
        value = newValue
    }
    
    
}