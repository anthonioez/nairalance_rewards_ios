//
//  RankingItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class RankingItem: NSObject
{
    public var id = 0;
    
    public var username = "";
    public var image = "";
    
    public var ranking = 0;
    public var rewards = 0;

    public override init()
    {
        self.id = 0;
    
        self.username   = "";
        self.image      = "";
        
        self.ranking    = 0;
        self.rewards    = 0;
    }

    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0
        self.username   = (json!["username"] as? String) ?? ""
        self.image      = (json!["image"] as? String) ?? ""
    
        self.ranking    = (json!["ranking"] as? Int) ?? -1
        self.rewards    = (json!["rewards"] as? Int) ?? 0
        return true;
    }

}
