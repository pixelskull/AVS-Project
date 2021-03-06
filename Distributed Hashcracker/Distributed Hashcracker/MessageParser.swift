//
//  MessageParser.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 01.02.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation

typealias JSONObject = [String:AnyObject]

class MessageParser {
    
    /**
     creates MessageObject(conforms to Message-Protocol) version of JSON-String
     - parameter jsonString: Stringversion of JSONObject
     - returns: Message-Object (.Extended or .Basic)
    */
    func createMessageFromJSONString(jsonString:String) -> Message? {
        if let jsonData = stringToJSONObject(jsonString) {
            return createMessageFromJSON(jsonData)
        } else {
            return nil
        }
    }
    
    /**
     creates String from MessageObject(conforms to Message-Protocol) 
     - parameter message: Object that conforms to Message-Protocol
     - returns: String if Message is valid JSON else nil
    */
    func createJSONStringFromMessage(message: Message) -> String? {
        return createJSONString(message.jsonObject())
    }

    private func createMessageFromJSON(jsonObject:JSONObject) -> Message? {
        let messageType = findMessageTypeFromJSON(jsonObject)
        
        switch messageType {
        case .Basic:
            if let basic = jsonObjectToBasicMessage(jsonObject) {
                return basic
            } else { return nil }
        case .Extended:
            if let extended = jsonObjectToExtendedMessage(jsonObject) {
                return extended
            } else { return nil }
        }
    }
    
    /**
     takes an Object and trys to convert this Object to JSON in String representation
     
     - parameter object:        Object to convert
     - parameter prettyPrinted: prettify the Output (true if wanted)
     
     - returns: JSON Object in String representation or nil if not possible
     */
    private func createJSONString(object:AnyObject, prettyPrinted:Bool = false) -> String? {
        let options:NSJSONWritingOptions = prettyPrinted ? .PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        guard NSJSONSerialization.isValidJSONObject(object) else { return nil }
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(object, options: options)
            if let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return jsonString as String
            }
        } catch {
            print("error while creating JSONString")
        }
        return nil
    }
    
    /**
     takes an JSON Object and returns the Type of the Message .Basic or .Extended
     
     - parameter json: JSON Object to check
     
     - returns: type of the given Message (.Basic or .Extended)
     */
    private func findMessageTypeFromJSON(json:JSONObject) -> MessageType {
        switch json["status"] as! String {
        case
        String(MessagesHeader.alive),
        String(MessagesHeader.stillAlive),
        String(MessagesHeader.newClientRegistration),
        String(MessagesHeader.stopWork):
            return MessageType.Basic
        default:
            return MessageType.Extended
        }
    }
    
    /**
     takes string representation of Message and evaluates which MessageHeader it has
     
     - parameter string: Message in String representation
     
     - returns: Value of MessageHeader
     */
    private func getMessageHeaderFromString(string:String) -> MessagesHeader? {
        switch string {
        case "setupConfig":
            return MessagesHeader.setupConfig
        case "newWorkBlog":
            return MessagesHeader.newWorkBlog
        case "newClientRegistration":
            return MessagesHeader.newClientRegistration
        case "hitTargetHash":
            return MessagesHeader.hitTargetHash
        case "finishedWork":
            return MessagesHeader.finishedWork
        case "hashesPerTime":
            return MessagesHeader.hashesPerTime
        case "stillAlive":
            return MessagesHeader.stillAlive
        case "alive":
            return MessagesHeader.alive
        case "stopWork":
            return MessagesHeader.stopWork
        default:
            return nil
        }
    }
    
    /**
     takes an JSON and trys to create a BasicMessage from contents
     
     - parameter jsonObject: JSONObject representation of Message
     
     - returns: BasicMessage representation of JSONObject or nil 
     */
    private func jsonObjectToBasicMessage(jsonObject:JSONObject) -> BasicMessage? {
        let status = jsonObject["status"] as! String
        let value = jsonObject["value"] as! String
        
        guard status != "" else { return nil }
        
        if let messageHeader = getMessageHeaderFromString(status) {
            return BasicMessage(status: messageHeader, value: value)
        } else {
            return nil
        }
    }
    
    /**
     takes an JSONObject and trys to create a ExtendedMessage from contents
     
     - parameter jsonObject: JSONObject representation of Message
     
     - returns: ExtendedMessage representation of JSONObject or nil
     */
    private func jsonObjectToExtendedMessage(jsonObject:JSONObject) -> ExtendedMessage? {
        let status = jsonObject["status"] as! String
        let valuesString = jsonObject["value"] as! String
        let values:[String:String]
        
        do {
            values = try NSJSONSerialization.JSONObjectWithData(valuesString.dataUsingEncoding(NSUTF8StringEncoding)!,
                options: NSJSONReadingOptions(rawValue: 0)) as! [String:String]
        } catch {
            return nil
        }
        if let messageHeader = getMessageHeaderFromString(status) {
            return ExtendedMessage(status: messageHeader, values: values)
        } else {
            return nil
        }
    }
    
    /**
     simple wrapper that transforms a String to NSData (inverse of dataToString())
     - parameter string: the String to transform 
     - returns: NSData version of given String
    */
    private func stringToData(string:String) -> NSData {
        return string.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    /**
     simple wrapper that transforms a String to JSONObject
     - parameter string: the String to transform
     - returns: JSONObject version of given String
     */
    private func stringToJSONObject(string:String) -> JSONObject? {
        if let jsonObject = try! NSJSONSerialization.JSONObjectWithData(stringToData(string),
            options: NSJSONReadingOptions(rawValue: 0)) as? JSONObject {
                return jsonObject
        } else {
            return nil
        }
    }
    
    /**
     simple wrapper that transforms NSData to String (inverse of stringToData())
     - parameter data: data to convert to String 
     - returns: String version of given NSData
    */
    private func dataToString(data:NSData) -> String {
        return String(data: data, encoding: NSUTF8StringEncoding)!
    }
}