//
//  TodoItem.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit

class TodoItem {
    
    // MARK: Properties
    var todoItemText: String
    var tags: [String]?
    var completed: Bool
    var createdAt: Date
    var createdAtEmotion: String?
    var updatedAt: Date
    var updatedAtEmotion: String?
    var completedAt: Date?
    var completedAtEmotion: String?
    
    // MARK: Initialization
    init?(todoItemText: String, tags: [String]?) {
        
        // Should fail if the todoItemText is empty
        guard !todoItemText.isEmpty else {
            return nil
        }
        
        self.todoItemText = todoItemText
        self.tags = tags
        self.completed = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    convenience init?(todoItemText: String, tags: [String]?, completed: Bool) {
        self.init(todoItemText: todoItemText, tags: tags)
        self.completed = completed
    }
    
    // MARK: markCompleted() function
    func markCompleted() {
        completed = true
        completedAt = Date()
        updatedAt = Date()
    }
}
