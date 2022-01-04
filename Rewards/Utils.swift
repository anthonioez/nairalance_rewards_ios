//
//  Utils.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SystemConfiguration

public class Utils: NSObject
{
    static let TAG : String = "Utils"
    
    public static func formatPoints(_ points: Int) -> String
    {
        return "\(points)";  //TODO format points
    }
    
    public static func formatRanking(_ ranking: Int) -> String
    {
        return ranking == -1 ? "-" : "\(ranking)";
    }

    public static func networkActivity(_ show: Bool)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
    
    public static func isOnline() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    public static func version() -> String
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "";
    }
    
    
    public static func isValidEmail(_ input: String) -> Bool
    {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: input)
    }
    
    public static func isValidPhone(_ input: String) -> Bool
    {
        let phoneRegEx =  "^\\d{10}$"
        
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: input)
    }
    
    public static func isValidName(_ input: String) -> Bool
    {
        let nameRegEx = "^[a-zA-Z0-9\\s\\.]+$"
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: input)
    }
    
    public static func isValidPassword(_ input: String) -> Bool
    {
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#(),.<>/:;\\-_=+|])[A-Za-z\\d$@$!%*?&#(),.<>/:;\\-_=+|]{8,}";
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: input)
    }
    
    static func openUrl(url: String)
    {
        openUrl(url: URL(string: url)!)
    }
    
    static func openUrl(url: URL)
    {
        UIApplication.shared.openURL(url)
    }
    

    static func getInt(_ input: String) -> Int
    {
        if let d = Int(input)
        {
            return d
        }
        else
        {
            return 0
        }
    }
    
    static func formatMoney(_ amount: Double) -> String
    {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_NG")
        formatter.numberStyle = .currency
        if let formattedTipAmount = formatter.string(from: amount as NSNumber)
        {
            return formattedTipAmount
        }
        else
        {
            return String(format: "%@₦ %.2f", amount < 0 ? "-" : "", abs(amount))
        }
    }
}
