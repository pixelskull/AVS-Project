//
//  dictionaryReader.swift
//  Distributed Hashcracker
//
//  Created by Dennis Jaeger on 02.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class DictionaryAttack{

    var dictionaryWorker = [String]()
    var index = 0
    
    func dictionaryToArray(fileName: String) -> [String]? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") else {
            return nil
        }
    
        do {
            let passwords = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            return passwords.componentsSeparatedByString("\n")
        } catch _ as NSError {
        return nil
        }
    }
    
    func fillDictionary(passwords:[String]){
            for block in passwords.splitBy(1000){
                dictionaryWorker.append(passwords[index])
                index+=1
                WorkBlogQueue.sharedInstance.put(WorkBlog(id: String(index), value: block))
            }
    }
}