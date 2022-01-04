//
//  HomeItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class HomeItem: NSObject
{
    public var username = "";
    public var thumb = "";
    public var rewards = 0;
    public var ranking = 0;
    
    public var items = [RewardTypeItem]();
    
    public override init()
    {
        username    = "";
        thumb       = "";
        
        ranking     = 0;
        rewards     = 0;
        
        items       = [RewardTypeItem]();
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.username   = (json!["username"] as? String) ?? ""
        self.thumb      = (json!["thumb"] as? String) ?? ""
    
        self.ranking    = (json!["ranking"] as? Int) ?? -1
        self.rewards    = (json!["rewards"] as? Int) ?? 0
    
        self.items      = [RewardTypeItem]();

        let list        = (json!["list"] as? [Any]) ?? []
        for entry in list
        {
            let item = RewardTypeItem();
            if(item.copyJSON(json: entry as? [String: Any]))
            {
                if(item.type == "admob")
                {
                    if(!item.data.isEmpty)
                    {
                        Rewards.admobIdRewarded = item.data;
                    }
                    item.available = 0;
                }
            
                items.append(item);
            }
        }
        
        return true;
    }

}
