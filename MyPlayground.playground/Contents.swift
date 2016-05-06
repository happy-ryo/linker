//: Playground - noun: a place where people can play

import UIKit
import Foundation

extension String {
    func sha256String() -> String {
        let cstr = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let data = NSData(bytes: cstr!, length: countElements(self))
        
        var digest = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        
        CC_SHA256(data.bytes, CC_LONG(data.length), &digest)
        
        var output = NSMutableString(capacity: 64)
        for var i=0; i<32; i++ {
            output.appendFormat("%02x", digest[i])
        }
        
        return output as String
    }
}

var str = "Hello, playground"
str.sha256String()