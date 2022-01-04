//
//  RewardItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class RewardItem: NSObject
{
    public var  id = 0;
    
    public var  title = "";
    public var  desc = "";
    public var  type = ""

    public var  image = ""
    public var  link = ""
    public var  data = ""
    
    public var  expiry = "";
    
    public override init()
    {
        self.id = 0;
        
        self.title = "";
        self.desc = "";
        self.type = "";
        
        self.image = "";
        self.link = "";
        self.data = "";
        
        self.expiry = "";
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        
        self.title      = (json!["title"] as? String) ?? ""
        self.desc       = (json!["desc"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""
        
        self.image      = (json!["image"] as? String) ?? ""
        self.link       = (json!["link"] as? String) ?? ""
        self.data       = (json!["data"] as? String) ?? ""

        self.expiry     = (json!["expiry"] as? String) ?? ""
        
        //self.datetime   = DateTime.datetimeLong(DateTime.datetimeStamp(self.expiry));

        return true;
    }
}
