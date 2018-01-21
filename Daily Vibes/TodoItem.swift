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
    
    @objc dynamic public var inboxDaySectionIdentifier: String? {
        let currentCalendar = Calendar.current
        self.willAccessValue(forKey: "inboxDaySectionIdentifier")
        var sectionIdentifier = String()
        
        if let date = self.createdAt as Date? {
            let day = currentCalendar.component(.day, from: date)
            let month = currentCalendar.component(.month, from: date)
            let year = currentCalendar.component(.year, from: date)
            
            // Construct integer from year, month, day. Convert to string.
            sectionIdentifier = "\(year * 10000 + month * 100 + day)"
        }
        self.didAccessValue(forKey: "inboxDaySectionIdentifier")
        
        return sectionIdentifier
    }
    
    @objc dynamic public var doneDaySectionIdentifier: String? {
        let currentCalendar = Calendar.current
        self.willAccessValue(forKey: "doneDaySectionIdentifier")
        var sectionIdentifier = String()
        
        if let date = self.completedAt as Date? {
            let day = currentCalendar.component(.day, from: date)
            let month = currentCalendar.component(.month, from: date)
            let year = currentCalendar.component(.year, from: date)
            
            // Construct integer from year, month, day. Convert to string.
            sectionIdentifier = "\(year * 10000 + month * 100 + day)"
        }
        self.didAccessValue(forKey: "doneDaySectionIdentifier")
        
        return sectionIdentifier
    }
    
    @objc dynamic public var archivedDaySectionIdentifier: String? {
        let currentCalendar = Calendar.current
        self.willAccessValue(forKey: "archivedDaySectionIdentifier")
        var sectionIdentifier = String()
        
        if let date = self.archivedAt as Date? {
            let day = currentCalendar.component(.day, from: date)
            let month = currentCalendar.component(.month, from: date)
            let year = currentCalendar.component(.year, from: date)
            
            // Construct integer from year, month, day. Convert to string.
            sectionIdentifier = "\(year * 10000 + month * 100 + day)"
        }
        self.didAccessValue(forKey: "archivedDaySectionIdentifier")
        
        return sectionIdentifier
    }
    
    // isArchived - archive vs delete
    // isFavourite - bookmarks/pins in the future
    // isPublic - when public API - can external people see it
    // version - update during each edit
    
    class func createTodoItem(in context: NSManagedObjectContext) -> TodoItem {
        let todoItem = TodoItem(context: context)
        todoItem.id = UUID.init()
        
        let timeNow = Date()
        todoItem.createdAt = timeNow
        todoItem.updatedAt = timeNow
        todoItem.versionId = UUID.init()
        
        return todoItem
    }
    
    func markCompleted() {
        if !isNew {
            completed = true
            let timeNow = Date()
            
            completedAt = timeNow
            updatedAt = timeNow
            
//            UPDATE VERSION
        }
    }
    
    func archive() -> Bool {
        if isArchived != true {
            isArchived = true
            let timeNow = Date()
            
            archivedAt = timeNow
            updatedAt = timeNow
//            UPDATE VERSION
            return true
        } else {
            return false
        }
    }
}
