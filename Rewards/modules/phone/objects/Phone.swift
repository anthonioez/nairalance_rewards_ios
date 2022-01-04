//
//  Phone.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class Phone: NSObject
{
    public static let EVENT_SIGNIN     = "rewards_signin";
    public static let EVENT_VERIFY     = "rewards_verify";

    static func isValid(_ input: String) -> Bool
    {
        if( (input.hasPrefix("0") && input.length() == 11) || (!input.hasPrefix("0") && input.length() == 10) )
        {
            return true
        }
        
        return false;
    }
}
