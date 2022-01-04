//
//  MicinitiEvent.swift
//  Rewards
//
//  Created by Anthonio Ez on 17/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class MicinitiEvent: NSObject
{
    public static let EVENT = "miciniti_event";
    
    static func post(_ event: String, message: String)
    {
        var info = [String : Any]()
        info["event"] = event;
        info["message"] = message;
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MicinitiEvent.EVENT), object: nil, userInfo: info)
    }

}
