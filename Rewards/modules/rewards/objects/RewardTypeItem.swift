//
//  RewardTypeItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class RewardTypeItem: NSObject
{
    public var id = 0;
    public var reward = 0;
    
    public var title = "";
    public var desc = "";
    public var type = "";
    
    public var data = "";
    public var actions = "";
    public var available = 0;
    public var order = 0;
    
    public var titleAttr: NSMutableAttributedString! = nil
    public var descAttr: NSMutableAttributedString! = nil
    
    public override init()
    {
        self.id = 0;
        self.reward = 0;
        
        self.title = "";
        self.desc = "";
        self.type = "";
        
        self.data = "";
        self.actions = "";
        self.available = 0;
        
        self.order = 0;
        
        titleAttr = nil;
        descAttr = nil;
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0;
        self.reward     = (json!["reward"] as? Int) ?? 0;
        
        self.title      = (json!["title"] as? String) ?? "";
        self.desc       = (json!["desc"] as? String) ?? "";
        self.type       = (json!["type"] as? String) ?? "";
        
        self.data       = (json!["data"] as? String) ?? "";
        self.actions    = (json!["actions"] as? String) ?? "";
        
        self.available  = (json!["available"] as? Int) ?? 0;
        self.order      = (json!["order"] as? Int) ?? 0;
        
        return true;
    }
}
