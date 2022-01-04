//
//  CashoutRateItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class CashoutRateItem: NSObject
{
    public var id = 0;
    
    public var info = "";
    public var type = "";
    
    public var points = 0;
    public var amount = Double(0);

    public override init()
    {
        self.id = 0;
    
        self.info   = "";
        self.type      = "";
        
        self.amount    = 0;
        self.points    = 0;
    }

    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        self.info       = (json!["info"] as? String) ?? ""
        self.type       = (json!["type"] as? String) ?? ""
    
        self.points     = (json!["points"] as? Int) ?? 0
        self.amount     = (json!["amount"] as? Double) ?? 0
        return true;
    }

}
