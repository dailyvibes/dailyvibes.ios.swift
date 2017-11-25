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
    
//    @NSManaged var completedAtEmotion: String?
//    @NSManaged var createdAtEmotion: String?
//    @NSManaged var tags: String?
//    @NSManaged var todoItemText: String?
//    @NSManaged var updatedAtEmotion: String?
//    @NSManaged var completed: Boolean?
//    @NSManaged var isAchieved: Boolean?
//    @NSManaged var isNew: Boolean?
//    @NSManaged var isPublic: Boolean?
//    @NSManaged var completedAt: Date?
//    @NSManaged var updatedAt: Date?
//    @NSManaged var id: UUID?
    
    class func createTodoItem(in context: NSManagedObjectContext) -> TodoItem {
//        if id != nil {
//            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", id! as CVarArg)
//
//            do {
//                let matches = try context.fetch(request)
//                if matches.count > 0 {
//                    // assert 'sanity': if condition false ... then print message and interrupt program
//                    assert(matches.count == 1, "TodoItem.findOrCreateTweet -- database inconsistency")
//                    return matches[0]
//                }
//            } catch {
//                throw error
//            }
//        }
        
        let todoItem = TodoItem(context: context)
        todoItem.id = UUID.init()
        todoItem.createdAt = Date()
        todoItem.updatedAt = Date()
        return todoItem
    }
    
    // MARK: markCompleted() function
    func markCompleted() {
        if !isNew {
            completed = true
            completedAt = Date()
            updatedAt = Date()
        }
    }
}
