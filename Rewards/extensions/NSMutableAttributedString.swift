//
//  NSMutableAttributedString.swift
//
//  Created by Anthonio Ez on 12/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    public func find(_ textToFind:String) -> NSRange!
    {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound
        {
            return foundRange;
        }
        return nil
    }
    
    public func addLink(_ textToFind:String, linkURL:String) -> Bool
    {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound
        {
            self.addAttribute(NSAttributedStringKey.link, value: linkURL, range: foundRange)
            
            return true
        }
        return false
    }
    
    public func addFont(_ textToFind:String, font: UIFont) -> Bool
    {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound
        {
            self.addAttribute(NSAttributedStringKey.font, value: font, range: foundRange);
            
            return true
        }
        return false
    }
    
    public func addColor(_ textToFind:String, color: UIColor) -> Bool
    {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound
        {
            self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: foundRange);
            
            return true
        }
        return false
    }
    
    public func addUnderline(_ textToFind:String) -> Bool
    {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound
        {
            self.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: foundRange)
            return true
        }
        return false
    }
}
