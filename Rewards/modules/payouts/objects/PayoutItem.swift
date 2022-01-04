//
//  PayoutItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class PayoutItem: NSObject
{
    public var  id = 0;
    
    public var  title = "";
    public var  type = ""
    
    public var  name = "";
    public var  account = "";
    
    public var  points = 0
    public var  amount = Double(0)

    public var  stamp = ""
    public var  status = 0
    
    public var  datetime = ""
    
    public override init()
    {
        self.id         = 0;
        self.title   = "";
        self.type       = "";
        
        self.name       = "";
        self.account    = "";
        
        self.points     = 0;
        self.amount     = 0;
        
        self.stamp      = "";
        
        self.status     = 1;
        
        self.datetime   = "";
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        
        self.title      = (json!["title"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""
        
        self.name       = (json!["name"] as? String) ?? ""
        self.account    = (json!["account"] as? String) ?? ""

        self.points     = (json!["points"] as? Int) ?? 0
        self.amount     = (json!["amount"] as? Double) ?? 0

        self.stamp      = (json!["stamp"] as? String) ?? ""

        self.status     = (json!["status"] as? Int) ?? 0
        
        self.datetime   = DateTime.datetimeLong(DateTime.datetimeStamp(self.stamp));

        return true;
    }

    
    public func getStatus() -> String
    {
        switch (status)
        {
        case -2:
            return "Rejected";
            
        case -1:
            return "Cancelled";
            
        case 0:
            return "Pending";
            
        case 1:
            return "Paid";
            
        default:
            return "Unknown";
        }
    }
    
    public func getColor() -> UIColor
    {
        switch (status)
        {
        case -2:
            return Rewards.colorAlert;
            
        case -1:
            return Rewards.colorClaimed;
            
        case 0:
            return Rewards.colorAsh;
            
        case 1:
            return UIColor.green;
            
        default:
            return UIColor.white
        }
    }
}
