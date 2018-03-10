//
//  Date+Extension.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-02.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

/*
 https://d.pr/UiGCXq
 */

import Foundation

extension Date {
    func startTime() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endTime() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startTime())!
    }
    
    func weekDayNumber() -> String? {
        return "\(Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0)"
    }
    func weekNumberOfYear() -> String? {
        return "\(Calendar.current.dateComponents([.weekOfYear], from: self).weekOfYear ?? 0)"
    }
    func monthNumberOfYear() -> String? {
        return "\(Calendar.current.dateComponents([.month], from: self).month ?? 0)"
    }
    func yearDayNumber() -> String? {
        return "\(Calendar.current.dateComponents([.weekday], from: self).yearForWeekOfYear ?? 0)"
    }
    func yearNumber() -> String? {
        return "\(Calendar.current.dateComponents([.year], from: self).year ?? 0)"
    }
    
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
    
    func makeDayPredicate(dateField date:String) -> NSPredicate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        return NSPredicate(format: "%@ >= %@ AND %@ =< %@", argumentArray: [date, startDate!, date, endDate!])
    }
    
    /// Returns a Date with the specified days added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var targetDay: Date
        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
        return targetDay
    }
    
    /// Returns a Date with the specified days subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let inverseYears = -1 * years
        let inverseMonths = -1 * months
        let inverseDays = -1 * days
        let inverseHours = -1 * hours
        let inverseMinutes = -1 * minutes
        let inverseSeconds = -1 * seconds
        return add(years: inverseYears, months: inverseMonths, days: inverseDays, hours: inverseHours, minutes: inverseMinutes, seconds: inverseSeconds)
    }
    
    /*
     * https://d.pr/Dr2H7
     */
    
//    static func localToUTC(date:String, fromFormat: String, toFormat: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = fromFormat
//        dateFormatter.calendar = NSCalendar.current
//        dateFormatter.timeZone = TimeZone.current
//
//        let dt = dateFormatter.date(from: date)
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        dateFormatter.dateFormat = toFormat
//
//        return dateFormatter.string(from: dt!)
//    }
    
    static func UTCToLocal(___date:String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
//        dateFormatter.date(from: ___date)
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = ""
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        let result = dateFormatter.date(from: date)
        
        return dateFormatter.date(from: ___date)!
    }
    
    var sectionIdentifier: String {
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
}
