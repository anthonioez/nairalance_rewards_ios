//
//  Ad.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Ad: NSObject
{
    public static let SLOT_HOME         = 0b00000001;
    public static let SLOT_REWARDS      = 0b00000010;
    public static let SLOT_EARNINGS     = 0b00000100;
    public static let SLOT_RANKINGS     = 0b00001000;
    public static let SLOT_CASHOUT      = 0b00010000;
    public static let SLOT_PAYOUTS      = 0b00100000;
    public static let SLOT_LISTING      = 0b01000000;
    
    private static let KEY_BANNER_TYPE  = "ad_banner_type"
    private static let KEY_BANNER_SLOTS = "ad_banner_slots"
    
    private static let KEY_INTERS_COUNT = "ad_inters_count"
    private static let KEY_INTERS_LIMIT = "ad_inters_limit"
    private static let KEY_INTERS_TYPE  = "ad_inters_type"
    
    static func parse(_ json: [String : Any])
    {
        let adinters = (json["adinters"] as? Int) ?? 0;
        let ilimit = adinters % 100;
        let itype = adinters / 100
        Defaults.setInt(KEY_INTERS_TYPE, value: itype);
        Defaults.setInt(KEY_INTERS_LIMIT, value: ilimit);

        let adbanner = (json["adbanner"] as? Int) ?? 0;        
        let btype = (adbanner & 0xFF00) >> 8
        let bslots = 0; //TODO (adbanner & 0x00FF)
        Defaults.setInt(KEY_BANNER_TYPE, value: btype);
        Defaults.setInt(KEY_BANNER_SLOTS, value: bslots);
    }
    
    public static func hasSlot(_ slot: Int) -> Bool
    {
        return (Defaults.getInt(KEY_BANNER_SLOTS, defValue: 0) & slot) > 0;
    }
    
    public static func count(_ count: Int)
    {
        var units = Defaults.getInt(KEY_INTERS_COUNT, defValue: 0);
        units += count;
        Defaults.setInt(KEY_INTERS_COUNT, value: units);

        let limit = Defaults.getInt(KEY_INTERS_LIMIT, defValue: 0)
        if(limit > 0 && units >= limit)
        {
            //show();
        }
    }
    
    public static func makePossible()
    {
        Defaults.setInt(KEY_INTERS_COUNT, value: Defaults.getInt(KEY_INTERS_LIMIT, defValue: 0) + Defaults.getInt(KEY_INTERS_COUNT, defValue: 0));
    }
    
    public static func isPossible() -> Bool
    {
        var units = Defaults.getInt(KEY_INTERS_COUNT, defValue: 0);
        units += 1;
        Defaults.setInt(KEY_INTERS_COUNT, value: units);
    
        let limit = Defaults.getInt(KEY_INTERS_LIMIT, defValue: 0)

        print("Ad.isPossible:", units, limit);
        
        if(limit > 0 && units >= limit)
        {
            return true;
        }

        return false;
    }
        
    public static func resetCount()
    {
        let limit = Defaults.getInt(KEY_INTERS_LIMIT, defValue: 0)
        var count = Defaults.getInt(KEY_INTERS_COUNT, defValue: 0)

        if(limit > 0)
        {
            count = count % limit;
        }
        else
        {
            count = 0;
        }
        Defaults.setInt(KEY_INTERS_COUNT, value: count);
    }
    
    public static func admobRequest() -> GADRequest
    {
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ];
        //request.testDevices = [ "fc8e1c32574d065c69ac9c47f983b3a0", kGADSimulatorID ];
        return request;
    }
}
