//
//  EarningItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class EarningItem: NSObject
{
    public var  id = 0;
    public var  title = "";
    public var  action = "";
    public var  info = ""
    public var  type = ""
    
    public var  points = 0
    
    public var  stamp = ""
    public var  status = 0
    
    public var  datetime = ""
    
    public override init()
    {
        self.id = 0;
        self.title      = "";
        self.action     = "";
        self.info       = "";
        self.type       = "";
        
        self.points     = 0;
        
        self.stamp      = "";
        
        self.status     = 1;
        
        self.datetime   = "";
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        self.title      = (json!["title"] as? String) ?? ""
        self.action     = (json!["action"] as? String) ?? ""
        self.info       = (json!["info"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""

        self.points     = (json!["points"] as? Int) ?? 0

        self.stamp      = (json!["stamp"] as? String) ?? ""

        self.status     = (json!["status"] as? Int) ?? 0
        
        self.datetime   = DateTime.datetimeLong(DateTime.datetimeStamp(self.stamp));

        return true;
    }

}
