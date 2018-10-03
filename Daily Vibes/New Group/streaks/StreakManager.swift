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
    // MARK: - Properties
    private let persistentContainer: NSPersistentContainer!
    private lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    // MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        guard let container = (UIApplication.shared.delegate as? AppDelegate)?.store else {
            fatalError("Cannot get shared delegate")
        }
        self.init(container: container.persistentContainer)
    }
    
    // TODO: FIX THIS
    // MARK: January 13 2018 - FIX THIS
    // MARK: Process a streak given a todo
    func process(item _todoItem: TodoItem?) -> Bool {
        // make sure the todo is a todo and it is completed
        
        // TODO; Figure out why this fails
        // it fails on todoItem.completed
        
//        <Daily_Vibes.TodoItem: 0x600000282580> (entity: TodoItem; id: 0xd000000000080000 <x-coredata://E76A675E-B5CF-4510-8EBF-EAAB12A88D28/TodoItem/p2> ; data: {
//        archivedAt = nil;
//        color = nil;
//        completed = 0;
//        completedAt = nil;
//        completedAtEmotion = nil;
//        createdAt = "2018-01-07 22:13:47 +0000";
//        createdAtEmotion = nil;
//        duedateAt = "2018-01-08 04:59:59 +0000";
//        id = "(...not nil..)";
//        isArchived = 0;
//        isFavourite = 0;
//        isNew = 1;
//        isPublic = 0;
//        list = nil;
//        notes = nil;
//        streak = nil;
//        tags =     (
//        "0xd000000000080004 <x-coredata://E76A675E-B5CF-4510-8EBF-EAAB12A88D28/Tag/p2>"
//        );
//        todoItemText = "Apple\nhttps://www.apple.com/";
//        updatedAt = "2018-01-07 22:13:47 +0000";
//        updatedAtEmotion = nil;
//        version = 0;
//        versionId = nil;
//        versionPrevId = nil;
//        })

        guard let todoItem = _todoItem else { fatalError("not unwrapped") }
        guard todoItem.completed else { fatalError("to-do should be completed") }
        
        let streaks = fetchAll()
        let streaksCount = streaks.count
        var _streak: Streak?
        
        if streaksCount > 0 {
            // find the top most streak (first)
            for streak in streaks {
                if _streak == nil {
                    if !streak.isCompleted && streak.completedAt == nil {
                        _streak = streak
                    }
                } else {
                    break
                }
            }
            
            guard let streak = _streak as Streak? else { return false }
            guard let streakCreatedAtDate = streak.createdAt as Date? else { return false }
            
            // relative to today
            let streakIsToday = Calendar.current.isDateInToday(streakCreatedAtDate)
            let streakWasYesterday = Calendar.current.isDateInYesterday(streakCreatedAtDate)
            
            if streakIsToday {
                return updateAndSaveTodaysStreak(todoItem, streak)
            } else if streakWasYesterday {
                // pull yesterdays streak
                return processTodaysStreakWithYesterday(streak, todoItem)
            } else {
                return processNewStreak(streak, todoItem)
            }
        } else {
            return createAndSaveBrandNewStreak(todoItem)
        }
    }
    
    // MARK: FetchAll
    func fetchAll() -> [Streak] {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
        request.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: false)]
        let results = try? persistentContainer.viewContext.fetch(request) as! [Streak]
        return results ?? [Streak]()
    }
    
    // MARK: Fetch by date
    func fetchBy(date:Date) -> Streak {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
//        request.predicate = NSPredicate(format"createdAt == %@", date)
        request.predicate = NSPredicate.init(format: "createdAt == %@", date as NSDate)
        let result = try? persistentContainer.viewContext.fetch(request).first as! Streak
        return result ?? Streak()
    }
    
    fileprivate func updateAndSaveTodaysStreak(_ todoItem: TodoItem?, _ streak: Streak) -> Bool {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        // add current todo to the streak
        if !streak.isCompleted {
            if let _todoItem = todoItem, _todoItem.completed {
                do {
                    streak.setValue(_todoItem.completedAt, forKey: "updatedAt")
                    streak.setValue(streak.tasksCompletedToday + Int64(1), forKey: "tasksCompletedToday")
                    streak.setValue(streak.tasksCompletedTotal + Int64(1), forKey: "tasksCompletedTotal")
                    streak.addToTodos(_todoItem)
                    
                    try context.save()
                    return true
                } catch {
                    fatalError("should not happen on streak.addToTodos")
                }
            } else {
                fatalError("should not be here")
            }
        } else {
            fatalError("should not happen on streak.addToTodos")
        }
    }
    
    fileprivate func processTodaysStreakWithYesterday(_ streak: Streak, _ todoItem: TodoItem?) -> Bool {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        // create a new streak
        // check to see if recordDaysInARow =< currentDaysInARow
        // if it is
        // set recordDaysInARow = currentDaysInARow
        // set currentStreakDay to 1
        // else
        //                        fatalError("this should not happen")
        // add current todo to the streak
        if !streak.isCompleted {
            if let _todoItem = todoItem, _todoItem.completed {
                do {
                    guard let _newStreak = processNeibouringStreak(neighbour: streak, for: _todoItem.completedAt!, isConsecutive: true) else {
                        fatalError("failure in processNewStreak")
                    }
                    _newStreak.addToTodos(todoItem!)
                    
                    try context.save()
                    return true
                } catch {
                    fatalError("should not fail on streaks.addToTods")
                }
            } else {
                fatalError("should not fail on streaks.addToTods")
            }
        } else {
            fatalError("should not fail on streaks.addToTods")
        }
    }
    
    fileprivate func processNewStreak(_ streak: Streak, _ todoItem: TodoItem?) -> Bool {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        // time to create a new streak (ie - not yesterday, not today)
        
        // set recordDaysInARow = 1 ... nope ..
        // to previous record
        // set currentStreakDay to 1
        //
        // add current todo to the streak
        if !streak.isCompleted {
            if let _todoItem = todoItem, _todoItem.completed {
                do {
                    guard let _newStreak = processNeibouringStreak(neighbour: streak, for: _todoItem.completedAt!, isConsecutive: false) else {
                        fatalError("failure in processNewStreak")
                    }
                    
                    _newStreak.addToTodos(_todoItem)
                    
                    try context.save()
                    return true
                } catch {
                    fatalError("should not fail on streaks.addToTods")
                }
            } else {
                fatalError("should not fail on streaks.addToTods")
            }
        } else {
            fatalError("should not fail on streaks.addToTods")
        }
    }
    
//    private func save() {
//        if backgroundContext.hasChanges {
//            do {
//                try backgroundContext.save()
//            } catch {
//                print("Save error \(error)")
//                fatalError("should be saved")
//            }
//        }
//        
//    }
    
    func processNeibouringStreak(neighbour streak:Streak, for date: Date, isConsecutive consecutive: Bool = false) -> Streak? {
        let ctx = persistentContainer.viewContext as NSManagedObjectContext
        
        let newStreak = Streak(context: ctx)
        
        let timeNow = date
        let _one = Int64(1)
        
        let currentDaysInARow: Int64 = consecutive ? streak.currentDaysInARow + _one : _one
//        let recordDaysInARow: Int64 = streak.recordDaysInARow + _one
        let recordDaysInARow: Int64 = consecutive ? streak.recordDaysInARow + _one : streak.recordDaysInARow
        let tasksCompletedInTotal: Int64 = streak.tasksCompletedTotal + _one
        let isCompleted: Bool = !consecutive
        
        streak.setValue(isCompleted, forKey: "isCompleted")
        streak.setValue(timeNow, forKey: "completedAt")
        streak.setValue(timeNow, forKey: "updatedAt")
        streak.setValue(newStreak, forKey: "next")
        
        newStreak.setValue(streak, forKey: "prev")
        newStreak.setValue(UUID.init(), forKey: "uuid")
        newStreak.setValue(timeNow, forKey: "createdAt")
        newStreak.setValue(timeNow, forKey: "updatedAt")
        newStreak.setValue(_one, forKey: "tasksCompletedToday")
        newStreak.setValue(currentDaysInARow, forKey: "currentDaysInARow")
        newStreak.setValue(recordDaysInARow, forKey: "recordDaysInARow")
        newStreak.setValue(tasksCompletedInTotal, forKey: "tasksCompletedTotal")
        
        return newStreak
    }
    
    fileprivate func createAndSaveBrandNewStreak(_ todoItem: TodoItem) -> Bool {
        guard todoItem.completed else { fatalError("should be a completed to-do") }
        guard let _ = createNewStreak(from: todoItem) else { fatalError("should have created a new streak using the to-do") }
        let ctx = persistentContainer.viewContext as NSManagedObjectContext
        
        do {
            try ctx.save()
            return true
        } catch {
            NSLog("Error: \(error)")
            NSLog("could not save context with a brand new streak in processBrandNewStreak")
            fatalError("should not eveer get here")
        }
    }
    
    private func createNewStreak(from todoItem:TodoItem) -> Streak? {
        let ctx = persistentContainer.viewContext as NSManagedObjectContext
        guard let streak = NSEntityDescription.insertNewObject(forEntityName: "Streak", into: ctx) as? Streak else { return nil }
        
        let _one = Int64(1)
        
        streak.setValue(UUID.init(), forKey: "uuid")
        streak.setValue(todoItem.completedAt, forKey: "createdAt")
        streak.setValue(todoItem.completedAt, forKey: "updatedAt")
        streak.setValue(_one, forKey: "currentDaysInARow")
        streak.setValue(_one, forKey: "recordDaysInARow")
        streak.setValue(_one, forKey: "tasksCompletedToday")
        streak.setValue(_one, forKey: "tasksCompletedTotal")
        streak.addToTodos(todoItem)
        
        return streak
    }
}
