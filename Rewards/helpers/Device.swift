//
//  Device.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

class Device
{
    static var EVENT_REGISTER   = "devices_register";
    static var EVENT_CONNECT    = "devices_connect";
    static var EVENT_TOKEN      = "devices_token"
    
    static func updateCheck(_ controller: UIViewController, message: String, update: Int, resume: (() -> Void)?, pause: (() -> Void)?)
    {
        if(update == -2)
        {
            let msg = message.length() == 0 ? "Rewards is under maintenance. Please check back later." : message;
            Device.openMaintain(msg)
        }
        else
        {
            let msg = message.length() == 0 ? "A new version of this app is available!" : message;            
            if(update == 1)
            {
                let alertController: UIAlertController  = UIAlertController(title: Rewards.appName, message: msg, preferredStyle: .alert );
                
                let actionContinue : UIAlertAction = UIAlertAction(title: "Continue", style: .default, handler: { (action:UIAlertAction!) in
                    alertController.dismiss(animated: true, completion: nil)
                    
                    if(resume != nil)
                    {
                        resume!()
                    }
                    
                })
                
                let actionUpdate : UIAlertAction = UIAlertAction(title: "Update Now", style: .default, handler: { (action:UIAlertAction!) in
                    alertController.dismiss(animated: true, completion: nil)
                    
                    
                    if(pause != nil)
                    {
                        pause!()
                    }
                })
                
                alertController.addAction(actionContinue)
                alertController.addAction(actionUpdate)
                
                controller.present(alertController, animated: true, completion: nil)
            }
            else if(update == 2)
            {
                Device.openUpdate(msg)
            }
            else
            {
                if(resume != nil)
                {
                    resume!()
                }
            }
        }
    }
    
    static func shouldToken() -> Bool
    {
        return (!Prefs.apiHash.isEmpty && !Prefs.pushToken.isEmpty && !Prefs.pushTokenSent && (DateTime.currentTimeMillis() - Prefs.pushTokenLast > 30000));  //30 secs
    }
    
    static func shouldHome() -> Bool
    {
        let last : Double = Prefs.lastDev;
        let hash : String = Prefs.apiHash;
        
        //if last device is > 1 day
        return (hash.length() == 0 || last == 0 || (DateTime.currentTimeMillis() - last) > 24*3600*1000);
    }
    
    static func screenSize() -> (width: Int, height: Int)
    {
        let screen: UIScreen = UIScreen.main
        
        let width = (Int)(screen.bounds.size.width * screen.scale)
        let height = (Int)(screen.bounds.size.height * screen.scale);
        
        
        return (width, height)
    }
    
    static func tag() -> String
    {
        if let id = UIDevice.current.identifierForVendor
        {
            return id.uuidString;
        }
        else
        {
            return ""
        }
    }
    
    static func country() -> String
    {
        if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        {
            if let name = carrier.isoCountryCode
            {
                return name;
            }
        }
        return ""
    }
    
    static func network() -> String
    {
        if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        {
            if let name = carrier.carrierName
            {
                return String(format: "%@ (%@/%@)", name, carrier.mobileCountryCode ?? "", carrier.mobileNetworkCode ?? "")
            }
        }
        return ""
    }
    
    static func model() -> String
    {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        var str = NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)! as String
        str = str.trimmingCharacters(in: CharacterSet.controlCharacters)
        return str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    static func node() -> String
    {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        var str = NSString(bytes: &sysinfo.nodename, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)! as String
        str = str.trimmingCharacters(in: CharacterSet.controlCharacters)
        return str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    static func openMaintain(_ message: String)
    {
        AppDelegate.setControllers([StopViewController.instance(message, false)], animated: true);
    }
    
    static func openUpdate(_ message: String)
    {
        AppDelegate.setControllers([StopViewController.instance(message, true)], animated: true);
    }
}
