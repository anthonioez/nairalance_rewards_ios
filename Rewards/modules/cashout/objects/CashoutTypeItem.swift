//
//  CashoutTypeItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 10/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class CashoutTypeItem: NSObject
{
    public var id = 0;
    
    public var provider = "";
    public var type = "";
    
    public var name = "";
    public var account = ""
    
    public override init()
    {
        self.id = 0;
        
        self.provider   = "";
        self.type       = "";
        
        self.name       = "";
        self.account    = "";
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        self.provider   = (json!["provider"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""
        
        self.name       = (json!["name"] as? String) ?? ""
        self.account    = (json!["account"] as? String) ?? ""
        return true;
    }
    
}
