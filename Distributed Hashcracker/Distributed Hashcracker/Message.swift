//
//  Message.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 22.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

enum MessageType {
    case Basic
    case Extended
}

enum MessagesHeader {
    case setupConfig
    case newWorkBlog
    case newClientRegistration
    case hitTargetHash
    case finishedWork
    case stillAlive
    case alive
}

protocol Message {
    var status:MessagesHeader { get set }
    var type:MessageType { get set }
    
    func jsonObject() -> JSONObject //[String:AnyObject]
}

class BasicMessage:Message {
    var status:MessagesHeader
    var type:MessageType = .Basic
    var value:String
    
    init(status:MessagesHeader, value:String) {
        self.status = status
        self.value = value
    }
    
    func jsonObject() -> [String:AnyObject] {
        return ["status":String(status), "value":String(value)]
    }
}

class ExtendedMessage:Message {
    var status:MessagesHeader
    var type:MessageType = .Extended
    var values:[String:String]
    
    init(status:MessagesHeader, values:[String:String]) {
        self.status = status
        self.values = values
    }
    
    func jsonObject() -> [String:AnyObject] {
        let jsonValues = try! NSJSONSerialization.dataWithJSONObject(values, options: NSJSONWritingOptions(rawValue: 0))
        let valuesJSONString = NSString(data: jsonValues, encoding: NSUTF8StringEncoding)
        return ["status":String(status), "value":valuesJSONString as! String]
    }
}