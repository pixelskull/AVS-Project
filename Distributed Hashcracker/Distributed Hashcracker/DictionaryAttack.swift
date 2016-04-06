//
//  dictionaryReader.swift
//  Distributed Hashcracker
//
//  Created by Dennis Jaeger on 02.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class DictionaryAttack:NSObject, AttackStrategy {

    var passwords:[String]? //  = [String]()
    var index = 0
    
    override init() {
        super.init()
        self.passwords = self.dictionaryToArray("PasswordDictionary")
    }
    
    private func dictionaryToArray(fileName: String) -> [String]? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") else { return nil }
        do {
            let passwords = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            return passwords.componentsSeparatedByString("\n")
        } catch {
            return nil
        }
    }
    
    func fillWorkBlogQueue(){
        guard let passwords = passwords else { return }
            
        _ = passwords.splitBy(10000).map{ block in
            index+=1
            WorkBlogQueue.sharedInstance.put(WorkBlog(id: "D\(index)", value: block))
        }
    }
}