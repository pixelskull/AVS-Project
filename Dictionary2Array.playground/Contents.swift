//Dictionary Attack in Arrays zu 1000 Passwoertern schreiben und in Worker Queue packen

//Dictionary Attack in Arrays zu 1000 Passwoertern schreiben und in Worker Queue packen

import Cocoa

let path = "PasswordDictionary.txt"
var rawStandards = NSArray(contentsOfFile: path)

let passwords = String(NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent(path))

print(path)

//do {
//    let passwords = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//}
//catch {/* error handling here */}



//let text = String(contentsOfFile:file, encoding: NSUTF8StringEncoding, error: nil)
//for index in 0...999 {
//
//}