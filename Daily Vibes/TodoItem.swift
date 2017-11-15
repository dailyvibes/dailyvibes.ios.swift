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
    
//    // MARK: Properties
//    var id: UUID
//    var todoItemText: String
//    var tags: [String]?
//    var completed: Bool
//    var createdAt: Date
//    var createdAtEmotion: String?
//    var updatedAt: Date
//    var updatedAtEmotion: String?
//    var completedAt: Date?
//    var completedAtEmotion: String?
//
//    // MARK: Initialization
//    init?(todoItemText: String, tags: [String]?) {
//
//        // Should fail if the todoItemText is empty
//        guard !todoItemText.isEmpty else {
//            return nil
//        }
//        self.id = UUID.init()
//        self.todoItemText = todoItemText
//        self.tags = tags
//        self.completed = false
//        self.createdAt = Date()
//        self.updatedAt = Date()
//    }
//
//    convenience init?(todoItemText: String, tags: [String]?, completed: Bool) {
//        self.init(todoItemText: todoItemText, tags: tags)
//        self.completed = completed
//    }
    
    // MARK: markCompleted() function
    func markCompleted() {
        if !isNew {
            completed = true
            completedAt = Date()
            updatedAt = Date()
        }
    }
}
