//
//  Message.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 22.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

/**
 types of Messages for better parsing
 
 - Basic:    simple Message with status and one value entry
 - Extended: complex Message with status and more than one value
 */
enum MessageType {
    case Basic
    case Extended
}

/**
 Headers for Distributed HashCracker Protocol
 
 - setupConfig:           MessageType for sending needed Information to Worker
 - newWorkBlog:           MessageType with new Workblog for Worker
 - newClientRegistration: MessageType for registration of new Client
 - hitTargetHash:         MessageType to send success of Worker
 - finishedWork:          MessageType to get more Work from Master
 - hashesPerTime:         MessageType to inform Master of worker workload
 - stillAlive:            MessageType to ask Workers if still active
 - alive:                 MessageType to answer Master that worker is still alive
 - stopWork:              MessageType to stop Worker when targetHash was found
 */
enum MessagesHeader {
    case setupConfig
    case newWorkBlog
    case newClientRegistration
    case hitTargetHash
    case finishedWork
    case hashesPerTime
    case stillAlive
    case alive
    case stopWork
}

protocol Message {
    var status:MessagesHeader { get set }
    var type:MessageType { get set }
    
    func jsonObject() -> JSONObject
}

class BasicMessage:Message {
    var status:MessagesHeader
    var type:MessageType = .Basic
    var value:String
    
    init(status:MessagesHeader, value:String) {
        self.status = status
        self.value = value
    }
    
    func jsonObject() -> JSONObject {
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
    
    func jsonObject() -> JSONObject {
        let jsonValues = try! NSJSONSerialization.dataWithJSONObject(values, options: NSJSONWritingOptions(rawValue: 0))
        let valuesJSONString = NSString(data: jsonValues, encoding: NSUTF8StringEncoding)
        return ["status":String(status), "value":valuesJSONString as! String]
    }
}