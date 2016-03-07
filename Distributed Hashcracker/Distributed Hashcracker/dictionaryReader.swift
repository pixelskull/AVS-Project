//
//  dictionaryReader.swift
//  Distributed Hashcracker
//
//  Created by Dennis Jaeger on 02.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

class DictionaryAttack{

    func dictionaryToWorkerQueue(fileName: String) -> [String]? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") else {
            return nil
        }
    
        do {
            let content = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            return content.componentsSeparatedByString("\n")
        } catch _ as NSError {
        return nil
        }
    }





}