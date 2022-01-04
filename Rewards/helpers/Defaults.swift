//
//  Defaults.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class Defaults: NSObject
{
    static public func getObject(_ key: String, defValue: AnyObject) -> AnyObject
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.object(forKey: key)! as AnyObject;
        }
    }
    static public func setObject(_ key: String, value: AnyObject)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getBool(_ key: String, defValue: Bool) -> Bool
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.bool(forKey: key);
        }
    }
    static public func setBool(_ key: String, value: Bool)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getInt(_ key: String, defValue: Int) -> Int
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.integer(forKey: key);
        }
    }
    static public func setInt(_ key: String, value: Int)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getDouble(_ key: String, defValue: Double) -> Double
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.double(forKey: key);
        }
    }
    static public func setDouble(_ key: String, value: Double)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getString(_ key: String, defValue: String) -> String
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.string(forKey: key)!;
        }
    }
    
    static public func setString(_ key: String, value: String)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    //MARK:
    static public func getList (_ key: String) -> [String: [String: AnyObject]]!
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return nil
        }
        else
        {
            return defaults.object(forKey: key) as! [String: [String: AnyObject]];
        }
    }
    
    static public func setList (_ key: String, list: [String: [String: AnyObject]])
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(list, forKey: key);
        defaults.synchronize()
    }    
}
