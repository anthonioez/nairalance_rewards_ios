//
//  ProfileItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 08/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class ProfileItem: NSObject
{
    public var username = "";
    public var phone = "";
    public var email = "";
    public var thumb = "";
    
    public var gender = 0;
    
    public var city = "";
    public var state = "";

    public var passed = false;
    public var flags = 0;
    
    public override init()
    {
        username = "";
        phone = "";
        email = "";
        thumb = "";
        gender = 0;
        
        city = "";
        state = "";
        
        passed = false;
        flags = 0;
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.username   = (json!["username"] as? String) ?? ""
        self.phone      = (json!["phone"] as? String) ?? ""
        self.thumb      = (json!["thumb"] as? String) ?? ""
        self.email      = (json!["email"] as? String) ?? ""

        self.gender     = (json!["gender"] as? Int) ?? -1

        self.city       = (json!["city"] as? String) ?? ""
        self.state      = (json!["state"] as? String) ?? ""
        
        self.passed     = (json!["passed"] as? Bool) ?? false
        self.flags      = (json!["flags"] as? Int) ?? 0

        return true;
    }
    
}
