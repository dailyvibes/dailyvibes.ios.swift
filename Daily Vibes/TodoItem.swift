//
//  TodoItem.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TodoItem: NSManagedObject {
    
    // isArchived - archive vs delete
    // isFavourite - bookmarks/pins in the future
    // isPublic - when public API - can external people see it
    // version - update during each edit
    
    class func createTodoItem(in context: NSManagedObjectContext) -> TodoItem {
        let todoItem = TodoItem(context: context)
        todoItem.id = UUID.init()
        todoItem.createdAt = Date()
        todoItem.updatedAt = Date()
        
        // fill in misc date data
        guard fillInOnCreateDateData(for: todoItem) else {
            fatalError("fillInOnCreateDateData should not fail")
        }
        
        return todoItem
    }
    
    private class func fillInOnCreateDateData(for todoItem:TodoItem) -> Bool {
        // fill in createAtAttributes
        todoItem.createdAtWeekDayNumber = Int32((todoItem.createdAt?.weekDayNumber())!)!
        todoItem.createdAtWeekNumber = Int32((todoItem.createdAt?.weekNumberOfYear())!)!
        todoItem.createdAtYearNumber = Int32((todoItem.createdAt?.yearNumber())!)!
        todoItem.createdAtMonthNumber = Int32((todoItem.createdAt?.monthNumberOfYear())!)!
        todoItem.createdAtYearDayNumber = Int32((todoItem.createdAt?.yearDayNumber())!)!
        // fill in updatedAtAttributes
        todoItem.updatedAtWeekDayNumber = Int32((todoItem.updatedAt?.weekDayNumber())!)!
        todoItem.updatedAtWeekNumber = Int32((todoItem.updatedAt?.weekNumberOfYear())!)!
        todoItem.updatedAtYearNumber = Int32((todoItem.updatedAt?.yearNumber())!)!
        todoItem.updatedAtMonthNumber = Int32((todoItem.updatedAt?.monthNumberOfYear())!)!
        todoItem.updatedAtYearDayNumber = Int32((todoItem.updatedAt?.yearDayNumber())!)!
        return true
    }
    
    func markCompleted() {
        if !isNew {
            completed = true
            completedAt = Date()
            updatedAt = Date()
            guard fillInCompletedDateAttributes() && fillInUpdatedDateAttributes() else {
                fatalError("fillInCompletedDateAttributes and fillInUpdatedDateAttributes should not throw an error")
            }
        }
    }
    
    func archive() -> Bool {
        if isArchived != true {
            isArchived = true
            archivedAt = Date()
            updatedAt = Date()
            guard fillInArchivedDateAttributes() && fillInUpdatedDateAttributes() else {
                fatalError("fillInArchivedDateAttributes and fillInUpdatedDateAttributes should not throw an error")
            }
            return true
        } else {
            return false
        }
    }
    
    private func fillInUpdatedDateAttributes() -> Bool {
        updatedAtWeekDayNumber = Int32((updatedAt?.weekDayNumber())!)!
        updatedAtWeekNumber = Int32((updatedAt?.weekNumberOfYear())!)!
        updatedAtYearNumber = Int32((updatedAt?.yearNumber())!)!
        updatedAtMonthNumber = Int32((updatedAt?.monthNumberOfYear())!)!
        updatedAtYearDayNumber = Int32((updatedAt?.yearDayNumber())!)!
        return true
    }
    
    private func fillInCompletedDateAttributes() -> Bool {
        completedAtWeekDayNumber = Int32((completedAt?.weekDayNumber())!)!
        completedAtWeekNumber = Int32((completedAt?.weekNumberOfYear())!)!
        completedAtYearNumber = Int32((completedAt?.yearNumber())!)!
        completedAtMonthNumber = Int32((completedAt?.monthNumberOfYear())!)!
        completedAtYearDayNumber = Int32((completedAt?.yearDayNumber())!)!
        return true
    }
    
    private func fillInArchivedDateAttributes() -> Bool {
        archivedAtWeekDayNumber = Int32((archivedAt?.weekDayNumber())!)!
        archivedAtWeekNumber = Int32((archivedAt?.weekNumberOfYear())!)!
        archivedAtYearNumber = Int32((archivedAt?.yearNumber())!)!
        archivedAtMonthNumber = Int32((archivedAt?.monthNumberOfYear())!)!
        archivedAtYearDayNumber = Int32((archivedAt?.yearDayNumber())!)!
        return true
    }
}

extension Date {
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
}
