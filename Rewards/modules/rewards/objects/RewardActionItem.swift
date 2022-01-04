//
//  RewardActionItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class RewardActionItem: NSObject
{
    public var  id = 0;
    public var  reward = 0;
    
    public var  title = "";
    public var  type = "";
    
    public var  action = "";
    public var  data = "";
    public var  info = "";
    public var  points = 0;
    
    public var  expiry = "";
    public var  claimed = false;
    
    public override init()
    {
        self.id = 0;
        self.reward = 0;
        
        self.title = "";
        self.type = "";
        
        self.action = "";
        self.data = "";
        self.points = 0;
        
        self.expiry = "";
        self.claimed = false;
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        self.reward     = (json!["reward"] as? Int) ?? 0

        self.title      = (json!["title"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""
        
        self.action     = (json!["action"] as? String) ?? ""
        self.data       = (json!["data"] as? String) ?? ""
        self.points     = (json!["points"] as? Index) ?? 0
        
        self.expiry     = (json!["expiry"] as? String) ?? ""
        self.claimed    = (json!["claimed"] as? Bool) ?? false
        
        //self.datetime   = DateTime.datetimeLong(DateTime.datetimeStamp(self.expiry));
        
        return true;
    }
    
}
