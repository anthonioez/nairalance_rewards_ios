//
//  Prefs.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation

public class Prefs
{
    static let KEY_DEVICE_ID            = "device_id"
    static let KEY_RUN_COUNT            = "run_count";
    static let KEY_LAST_DEV             = "last_dev";
    static let KEY_AD_COUNT             = "ad_count"

    static let KEY_API_HASH             = "api_hash";
    static let KEY_API_TOKEN            = "api_token";
    
    static let KEY_USER_ID              = "user_id"
    static let KEY_USER_EMAIL           = "user_name"
    static let KEY_USER_NAME            = "user_email"
    static let KEY_USER_THUMB           = "user_thumb"
    static let KEY_USER_PHONE           = "user_phone"
    static let KEY_USER_REWARDS         = "user_rewards"
    static let KEY_USER_RANKING         = "user_ranking"
    
    static let KEY_PUSH_STATUS          = "push_status"
    static let KEY_PUSH_SOUND           = "push_sound"
    static let KEY_PUSH_VIBRATE         = "push_vibrate"
    
    static let KEY_PROFILE_STAMP        = "profile_stamp"
    
    static let KEY_PUSH_TOKEN           = "push_token"
    static let KEY_PUSH_TOKEN_SENT      = "push_token_sent"
    static let KEY_PUSH_TOKEN_LAST      = "push_token_last"

    static let KEY_LAST_FEEDBACK        = "last_feedback"
    
    static var userID: String
    {
        get
        {
            return Defaults.getString(KEY_USER_ID, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_ID, value: value)
        }
    }
    
    static var userName: String
    {
        get
        {
            return Defaults.getString(KEY_USER_NAME, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_NAME, value: value)
        }
    }
    
    static var userPhone: String
    {
        get
        {
            return Defaults.getString(KEY_USER_PHONE, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_PHONE, value: value)
        }
    }
    
    static var userThumb: String
    {
        get
        {
            return Defaults.getString(KEY_USER_THUMB, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_THUMB, value: value)
        }
    }
    
    static var userEmail: String
    {
        get
        {
            return Defaults.getString(KEY_USER_EMAIL, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_EMAIL, value: value)
        }
    }
    
    static var deviceID: String
    {
        get
        {
            return Defaults.getString(KEY_DEVICE_ID, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_DEVICE_ID, value: value)
        }
    }
    
    static public var runCount: Int
    {
        get
        {
            return Defaults.getInt(KEY_RUN_COUNT, defValue: 0);
        }
        set(value)
        {
            Defaults.setInt(KEY_RUN_COUNT, value: value)
        }
    }
    
    static var apiHash: String
    {
        get
        {
            return Defaults.getString(KEY_API_HASH, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_API_HASH, value: value)
        }
    }
    
    static var apiToken: String
    {
        get
        {
            return Defaults.getString(KEY_API_TOKEN, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_API_TOKEN, value: value)
        }
    }
    
    static var lastDev: Double
    {
        get
        {
            return Defaults.getDouble(KEY_LAST_DEV, defValue: 0);
        }
        set(value)
        {
            Defaults.setDouble(KEY_LAST_DEV, value: value)
        }
    }


    static var adCoun: Int
    {
        get
        {
            return Defaults.getInt(KEY_AD_COUNT, defValue: 0);
        }
        set(value)
        {
            Defaults.setInt(KEY_AD_COUNT, value: value)
        }
    }
    
    static var thumbUrl: String
    {
        get
        {
            return Defaults.getString(KEY_USER_THUMB, defValue: "");
        }
        set(value)
        {
            Defaults.setString(KEY_USER_THUMB, value: value)
        }
    }

    //MARK: Push
    static var pushStatus: Bool
    {
        get
        {
            return Defaults.getBool(KEY_PUSH_STATUS, defValue: true);
        }
        set(value)
        {
            Defaults.setBool(KEY_PUSH_STATUS, value: value)
        }
    }
    
    static var getPushVibrate: Bool
    {
        get
        {
            return Defaults.getBool(KEY_PUSH_VIBRATE, defValue: true);
        }
        set(value)
        {
            Defaults.setBool(KEY_PUSH_VIBRATE, value: value)
        }
    }
    
    static var pushSound: Bool
    {
        get
        {
            return Defaults.getBool(KEY_PUSH_SOUND, defValue: true);
        }
        set(value)
        {
            Defaults.setBool(KEY_PUSH_SOUND, value: value)
        }
    }

    static var pushVibrate: Bool
    {
        get
        {
            return Defaults.getBool(KEY_PUSH_VIBRATE, defValue: true);
        }
        set(value)
        {
            Defaults.setBool(KEY_PUSH_VIBRATE, value: value)
        }
    }

    static var pushTokenSent: Bool
    {
        get
        {
            return Defaults.getBool(KEY_PUSH_TOKEN_SENT, defValue: false);
        }
        set(value)
        {
            Defaults.setBool(KEY_PUSH_TOKEN_SENT, value: value)
        }
    }
    
    static var pushTokenLast: Double
    {
        get
        {
            return Defaults.getDouble(KEY_PUSH_TOKEN_LAST, defValue: 0);
        }
        set(value)
        {
            Defaults.setDouble(KEY_PUSH_TOKEN_LAST, value: value)
        }
    }
    
    static var pushToken: String
    {
        get
        {
            return Defaults.getString(KEY_PUSH_TOKEN, defValue: "");
        }
        set(value)
        {            
            Defaults.setString(KEY_PUSH_TOKEN, value: value)
        }
    }
    
    
    static var userRanking: Int
    {
        get
        {
            return Defaults.getInt(KEY_USER_RANKING, defValue: -1);
        }
        set(value)
        {
            Defaults.setInt(KEY_USER_RANKING, value: value)
        }
    }

    static var userRewards: Int
    {
        get
        {
            return Defaults.getInt(KEY_USER_REWARDS, defValue: 0);
        }
        set(value)
        {
            Defaults.setInt(KEY_USER_REWARDS, value: value)
        }
    }
    
    static var profileStamp: Int
    {
        get
        {
            return Defaults.getInt(KEY_PROFILE_STAMP, defValue: 0);
        }
        set(value)
        {
            Defaults.setInt(KEY_PROFILE_STAMP, value: value)
        }
    }
    
    static var lastFeedback: Int
    {
        get
        {
            return Defaults.getInt(KEY_LAST_FEEDBACK, defValue: 0);
        }
        set(value)
        {
            Defaults.setInt(KEY_LAST_FEEDBACK, value: value)
        }
    }
}
