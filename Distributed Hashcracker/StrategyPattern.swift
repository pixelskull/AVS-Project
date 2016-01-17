//
//  StrategyPattern.swift
//  Distributed Hashcracker
//
//  Created by Multitouch on 08.01.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

protocol HashAlgorith {
    
    func hash(string string: String) -> String
    
}

class HashMD5: HashAlgorith {
    
    func hash(string string: String) -> String {
        print("MD5-Hash")
        
            var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
            if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                CC_MD5(data.bytes, CC_LONG(data.length), &digest)
            }
            
            var digestHex = ""
            for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                digestHex += String(format: "%02hhx", digest[index])
            }
            
            return digestHex
        
        
    }
    
}


class HashSHA: HashAlgorith {
    
    func hash(string string: String) -> String {
        print("SHA-128-Hash")
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
    
}

class HashSHA256: HashAlgorith {
    
    func hash(string string: String) -> String {
        print("SHA-256-Hash")
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
    
}



// Use the behaviour

//class SomeViewWithAButton: NSViewController {
//    
//    @IBOutlet weak var aButton: UIButton!
//    
//    var hashAlgorith: HashAlgorith?
//    
//    @IBAction func generateHash(sender: AnyObject) {
//        hashAlgorith?.hash()
//    }
//    
//}
//
//var hashAlgorith: HashAlgorith = HashMD5()
//
//let algo = SomeViewWithAButton()
//algo.hashAlgorith = hashAlgorith
//
//algo.generateHash(NSObject())
//
//hashAlgorith = HashSHA()
//algo.hashAlgorith = hashAlgorith
//
//algo.generateHash(NSObject())