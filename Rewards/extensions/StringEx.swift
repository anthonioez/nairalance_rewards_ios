//
//  Strings.swift
//  MyFin
//
//  Created by Anthonio Ez on 06/03/2018.
//

import UIKit

extension String
{
    public func trim() -> String!
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func length() -> Int
    {
        return self.count
    }
    
    func firstUppercasing() -> String
    {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func firstUppercased()
    {
        self = self.firstUppercasing()
    }
    
    func substr(start: Int) -> String
    {
        let sIndex = self.index(self.startIndex, offsetBy: start)
        return String(self[sIndex...]);
    }

    func substr(to: Int) -> String
    {
        let tIndex = self.index(self.startIndex, offsetBy: to - 1)
        return String(self[...tIndex]);
    }

    func sha1() -> String
    {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    static func sha1(_ input: String) -> String
    {
        return input.sha1()
    }
    
    static func className(_ aClass: AnyClass) -> String
    {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
}
