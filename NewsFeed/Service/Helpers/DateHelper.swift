//
//  DateHelper.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/19/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import DateTools

class DateHelper: NSObject {
    
    static func timeAgo(date: NSDate?) -> String {
        if date == nil {
            return DateToolsLocalizedStrings("Just now")
        }
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = date?.earlierDate(now)
        let latest = (earliest == date) ? now : date
        
        let upToHours = NSCalendarUnit.Second.rawValue | NSCalendarUnit.Minute.rawValue | NSCalendarUnit.Hour.rawValue
        let difference = calendar.components(NSCalendarUnit(rawValue: upToHours), fromDate: earliest!, toDate: latest!, options: .WrapComponents)
        
        if difference.hour < 24 && date?.day() == now.day() {
            return NSDate().timeAgoSinceDate(date ?? NSDate(), numericDates: false, numericTimes: false)
        } else {
            if date!.isYesterday() {
                return DateToolsLocalizedStrings("Yesterday") + " " + date!.formattedDateWithFormat("hh:mm a")
            } else {
                if date?.year() == now.year() {
                    return date!.formattedDateWithFormat("MM-dd hh:mm a")
                } else {
                    return date!.formattedDateWithFormat("yyyy-MM-dd hh:mm a")
                }
            }
        }
    }
    
    static func DateToolsLocalizedStrings(key: String) -> String {
        let bundle = NSBundle(path: (NSBundle(forClass: DTError.self).resourcePath?.stringByAppendingString("/DateTools.bundle"))!)
        return NSLocalizedString(key, tableName: "DateTools", bundle: bundle!, value: "刚刚", comment: "")
    }
}
