//
//  Constants.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 19.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

struct Constants {
    
    /// internal notificationnames for use in NotificationCenter
    struct NCValues {
        static let addHashValue  = "newHashValues"
        static let sendMessage   = "sendMessage"
        static let stopServer    = "stopServerTask"
        static let stopMaster    = "stopMaster"
        static let stopWebSocket = "stopWebSocketOperation"
        static let stopWorker    = "stopWorker"
        static let stopWorkBlog  = "stopWorkBlogGeneration"
        static let updateLog     = "updateLog"
        static let toggleStartButton = "toggleStartStopButton"
    }
    
    static let queueID = "de.th-koeln.DistributedHashCracker"
}