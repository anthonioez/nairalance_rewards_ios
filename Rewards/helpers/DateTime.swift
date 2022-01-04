//
//  DateTime.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class DateTime: NSObject
{
    static var oneSecond    : Int64 = 1000;
    static var oneMinute    : Int64 = oneSecond * 60;
    static var oneHour      : Int64 = oneMinute * 60;
    static var oneDay       : Int64 = oneHour * 24;
    static var oneMonth     : Int64 = oneDay * 30;
    
    static func timeAgo(_ input: String, prefix: String = "about", suffix: String = "ago") -> String
    {
        return DateTime.millisToLongDHMS(DateTime.currentTimeMillis() - DateTime.datetimeStamp(input)*1000, prefix: prefix, suffix: suffix)
    }
    
    static func timeAgo(_ input: Double, prefix: String = "about", suffix: String = "ago") -> String
    {
        return DateTime.millisToLongDHMS(DateTime.currentTimeMillis() - input*1000, prefix: prefix, suffix: suffix)
    }
    
    static func millisToLongDHMS(_ input: Double, prefix: String = "about", suffix: String = "ago") -> String
    {
        var duration : Int64 = Int64(input)
        
        var month   : Int64 = 0;
        var day     : Int64 = 0;
        var hour    : Int64 = 0;
        var minute  : Int64 = 0;
        var second  : Int64 = 0;
        
        var res = ""
        let suff = (suffix.isEmpty ? "" : " " + suffix);
        let pref = (prefix.isEmpty ? "" : prefix + " ");
        
        if(duration < 0)
        {
            return "";
        }
        else if (duration >= oneSecond)
        {
            month = duration / oneMonth;
            if (month > 0)
            {
                duration -= month * oneMonth;
                res += pref + "\(month) month\(month > 1 ? "s " : " ")"
            }
            else
            {
                day = duration / oneDay;
                if (day > 0)
                {
                    duration -= day * oneDay;
                    res += "\(day) day\(day > 1 ? "s " : " ")"
                }
                
                hour = duration / oneHour;
                if (hour > 0)
                {
                    duration -= hour * oneHour;
                    res += "\(hour) hr\(hour > 1 ? "s " : " ")"
                }
                
                minute = duration / oneMinute;
                if (minute > 0 && day == 0)
                {
                    duration -= minute * oneMinute;
                    res += "\(minute) min\(minute > 1 ? "s " : " ")"
                    
                    //res.append(minute).append(" min").append(minute > 1 ? "s " : " ");
                }
                
                second = duration / oneSecond;
                if (second > 0 && day == 0 && hour == 0 && minute == 0)
                {
                    res += "\(second) sec\(second > 1 ? "s " : " ")"
                }
            }
            if(!res.trim().isEmpty)
            {
                res = res.trim() + suff;
            }
            
            return res
        }
        else
        {
            return "0 seconds" + suff
        }
    }
    
    static func formatDurationMillis(_ input: Int) -> String
    {
        let totalSecs = input / 1000;
        
        return formatDuration(totalSecs);
    }
    
    static func formatDuration(_ totalSecs: Int) -> String
    {
        let hours = totalSecs / 3600;
        let minutes = (totalSecs % 3600) / 60;
        let seconds = totalSecs % 60;
        
        if(hours > 0)
        {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds);
        }
        else
        {
            return String(format: "%02d:%02d", minutes, seconds);
        }
    }
    
    static func currentTimeMillis() -> TimeInterval
    {
        return Date().timeIntervalSince1970 * 1000
    }
    
    static func localStamp(_ stamp: Double) -> Double
    {
        let offset = NSTimeZone.local.secondsFromGMT()
        let time = stamp + Double(offset)
        
        return time
    }
    
    static func utcStamp(_ stamp: Double) -> Double
    {
        let offset = NSTimeZone.local.secondsFromGMT()
        let time = stamp - Double(offset)
        
        return time
    }
    
    static func datetimeStamp(_ input: String) -> Double
    {
        var stamp = input.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "");
        
        if let idx = stamp.index(of: ".")
        {
            stamp = String(stamp[...idx]).replacingOccurrences(of: ".", with: "");
            //stamp = stamp.substring(to: idx);
        }
        stamp = stamp.trim();
        
        if(stamp.length() > 0)
        {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if let date = formatter.date(from: stamp)
            {
                let dt = date.timeIntervalSince1970
                return dt;
            }
        }
        
        return 0;
    }
    
    static func dateShort(_ stamp: Double) -> String
    {
        let date = Date(timeIntervalSince1970: stamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }
    
    
    static func dateLong(_ stamp: Double) -> String
    {
        let date = Date(timeIntervalSince1970: stamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }
    
    static func timeShort(_ stamp: Double) -> String
    {
        let date = Date(timeIntervalSince1970: stamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }
    
    static func datetimeLong(_ stamp: Double) -> String
    {
        let date = Date(timeIntervalSince1970: stamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }
    
    static func parseDate(_ input: String) -> Date!
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if(!input.isEmpty)
        {
            let date = dateFormatter.date(from: input)!
            return date;
        }
        return nil;
    }
    
    static func stringDate(_ date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent;
        return dateFormatter.string(from: date)
    }
    
}
