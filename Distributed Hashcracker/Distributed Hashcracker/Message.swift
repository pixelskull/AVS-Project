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

protocol Message {
    var status:String { get set }
    var type:MessageType { get set }
}


class BasicMessage:Message {
    var status:String
    var type:MessageType = .Basic
    var value:String
    
    init(status:String, value:String) {
        self.status = status
        self.value = value
    }
}

class ExtendedMessage:Message {
    var status:String
    var type:MessageType = .Extended
    var values:[String:String]
    
    init(status:String, values:[String:String]) {
        self.status = status
        self.values = values
    }
}
