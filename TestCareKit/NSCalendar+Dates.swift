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
    
    

    func monthDayYearString() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.stringFromDate(self)
    }
    func hourMinutesString() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(self)
        
    }
    func dateComponents() -> NSDateComponents
    {

        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return components

    }
    class func dateFromComponents(components:NSDateComponents) -> NSDate
    {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        return calendar.dateFromComponents(components)!
    }

}