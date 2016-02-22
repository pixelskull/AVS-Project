//
//  ServerAddress.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 04.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class ServerIP {
    let ip:String
    
    init(address:String) {
        ip = address
    }
    
    func isLocalHost() -> Bool {
        switch ip {
        case "localhost", "127.0.0.1", "::1":
            return true
        default:
            return false
        }
    }
    
    func isIPV4() -> Bool {
        let ipParts = ip.componentsSeparatedByString(".")
        if ipParts.count == 4 {
            return true
        }
        return false
    }
    
    func isIPV6() -> Bool {
        if !self.isIPV4() {
            if let _ = ip.rangeOfString(":") {
                return true
            }
        }
        return false
    }
}
