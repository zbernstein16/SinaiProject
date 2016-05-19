//
//  NSCalendar+Dates.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/5/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import Foundation

extension NSCalendar {
    /**
     Returns a tuple containing the start and end dates for the week that the
     specified date falls in.
     */
    func weekDatesForDate(date: NSDate) -> (start: NSDate, end: NSDate) {
        var interval: NSTimeInterval = 0
        var start: NSDate?
        rangeOfUnit(.WeekOfYear, startDate: &start, interval: &interval, forDate: date)
        let end = start!.dateByAddingTimeInterval(interval)
        
        return (start!, end)
    }
}
extension NSDate {
    
    
    class func monthDayYearStringFromNSDate(date:NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        return dateFormatter.stringFromDate(date)
    }
    class func dateComponentsFromMonthDayYearString(string:String) -> NSDateComponents
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let date:NSDate = dateFormatter.dateFromString(string)!
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day], fromDate: date)
        return components
    }
    
}