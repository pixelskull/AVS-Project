//Dictionary Attack in Arrays zu 1000 Passwoertern schreiben und in Worker Queue packen

import Cocoa

let path = "/Users/denjae/sciebo/Studium/AVS/AVS-Project/PasswordDictionary.txt"
do{
    let file = String(contentsOfFile: path, encoding: UTF8 , error: nil)
    print(file)
}


//let text = String(contentsOfFile:file, encoding: NSUTF8StringEncoding, error: nil)
//for index in 0...999 {
//
//}