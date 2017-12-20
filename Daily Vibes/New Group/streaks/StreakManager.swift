//
//  StreakManager.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-11.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class StreakManager {
//    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
//    private var fetchedResultsController: NSFetchedResultsController<TodoItem>!
//    private var moc: NSManagedObjectContext?
    
    static func process(item todoItem: TodoItem?) -> Bool {
        let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        let context: NSManagedObjectContext = container!.viewContext
        let streakRequest: NSFetchRequest = Streak.fetchRequest()
        
        // by updatedAt
        // we set updatedAt once a day... on creation THAT IS ALL
        streakRequest.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: false)]
        
        if let streaks = try? context.fetch(streakRequest), let totalCount = streaks.count as Int? {
            
            if totalCount > 0 {
                // first item should be the most recently updated one
                guard let streak = streaks.first as Streak! else {
                    fatalError("this cast should not fail")
                }
                
                // UPDATED AT should NEVER fail because it is always updated
                let streakWasYesterday = Calendar.current.isDateInYesterday(streak.updatedAt!)
                let streakIsToday = Calendar.current.isDateInToday(streak.updatedAt!)
                //            let recordDaysInARow = streak.recordDaysInARow
                //            let currentDaysInARow = streak.currentDaysInARow
                
                if streakIsToday {
                    // add current todo to the streak
                    do {
                        streak.addToTodos(todoItem!)
                        streak.updatedAt = Date()
                        streak.tasksCompletedToday = streak.tasksCompletedToday + 1
                        streak.tasksCompletedTotal = streak.tasksCompletedTotal + 1
                        try context.save()
                        return true
                    } catch {
                        fatalError("should not happen on streak.addToTodos")
                    }
                } else if streakWasYesterday {
                    do {
                        let _newStreak = Streak(context: context)
                        
                        streak.next = _newStreak
                        _newStreak.prev = streak
                        
                        _newStreak.uuid = UUID.init()
                        _newStreak.createdAt = Date()
                        _newStreak.updatedAt = Date()
                        _newStreak.addToTodos(todoItem!)
                        _newStreak.tasksCompletedToday = 1
                        _newStreak.tasksCompletedTotal = streak.tasksCompletedTotal + 1
                        _newStreak.currentDaysInARow = streak.currentDaysInARow + 1
                        
                        if streak.recordDaysInARow <= _newStreak.currentDaysInARow {
                            _newStreak.recordDaysInARow = _newStreak.currentDaysInARow
                        } else {
                            fatalError("this should not happen")
                        }
                        
                        try context.save()
                        return true
                    } catch {
                        fatalError("should not fail on streaks.addToTods")
                    }
                    // create a new streak
                    // check to see if recordDaysInARow =< currentDaysInARow
                    // if it is
                    // set recordDaysInARow = currentDaysInARow
                    // set currentStreakDay to 1
                    // else
                    //                        fatalError("this should not happen")
                    // add current todo to the streak
                } else {
                    // time to create a new streak
                    // set recordDaysInARow = 1 ... nope ..
                    // to previous record
                    // set currentStreakDay to 1
                    //
                    // add current todo to the streak
                    do {
                        let _newStreak = Streak(context: context)
                        
                        streak.next = _newStreak
                        streak.isCompleted = true
                        streak.completedAt = Date()
                        
                        _newStreak.prev = streak
                        
                        _newStreak.uuid = UUID.init()
                        _newStreak.createdAt = Date()
                        _newStreak.updatedAt = Date()
                        _newStreak.addToTodos(todoItem!)
                        _newStreak.currentDaysInARow = 1
                        _newStreak.recordDaysInARow = streak.recordDaysInARow
                        _newStreak.tasksCompletedToday = 1
                        _newStreak.tasksCompletedTotal = streak.tasksCompletedTotal + 1
                        
                        ////
//                        _newStreak.tasksCompletedTotal = streak.tasksCompletedTotal + 1
//                        _newStreak.currentDaysInARow = streak.currentDaysInARow + 1
                        
//                        if streak.recordDaysInARow <= _newStreak.currentDaysInARow {
//                            _newStreak.recordDaysInARow = _newStreak.currentDaysInARow
//                        } else {
//                            fatalError("this should not happen")
//                        }
                        ////
                        
                        try context.save()
                        return true
                    } catch {
                        fatalError("should not fail on streaks.addToTods")
                    }
                }
            } else {
                // no streaks... time to start one
                do {
                    let _newStreak = Streak(context: context)
                    
                    _newStreak.uuid = UUID.init()
                    _newStreak.createdAt = Date()
                    _newStreak.updatedAt = Date()
                    _newStreak.addToTodos(todoItem!)
                    _newStreak.currentDaysInARow = 1
                    _newStreak.recordDaysInARow = 1
                    _newStreak.tasksCompletedToday = 1
                    _newStreak.tasksCompletedTotal = 1
                    
                    try context.save()
                    return true
                } catch {
                    fatalError("should not fail on streaks.addToTods")
                }
                return true
            }
        } else {
            return false
        }
        
    }
    
//    func predicateForDayFromDate(date: Date) -> NSPredicate {
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
//        components.hour = 00
//        components.minute = 00
//        components.second = 00
//        let startDate = calendar.date(from: components)
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//        let endDate = calendar.date(from: components)
//
//        return NSPredicate(format: "YOUR_DATE_FIELD >= %@ AND YOUR_DATE_FIELD =< %@", argumentArray: [startDate!, endDate!])
//    }
}
