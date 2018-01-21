//
//  DVTodoItemTaskViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DVTodoItemTaskViewModel: NSObject {
    let uuid: UUID
    
    let versionId: UUID?
    let versionPrevId: UUID?
    let version: Int64
    
    let todoItemText: String
    
    let createdAt: Date
    let updatedAt: Date
    let duedateAt: Date?
    let completedAt: Date?
    let archivedAt: Date?
    
    let isCompleted: Bool
    let isArchived: Bool
    let isNew: Bool
    let isPublic: Bool
    let isFavourite: Bool
    
    init(uuid:UUID, versionId:UUID?, versionPrevId: UUID?, version:Int64?, todoItemText:String, createdAt:Date, updatedAt:Date, duedateAt:Date?, completedAt:Date?, archivedAt:Date?, completed:Bool?, isArchived:Bool?, isNew:Bool?, isPublic:Bool?, isFavourite:Bool?) {
        self.uuid = uuid
        
        self.versionId = versionId
        self.versionPrevId = versionPrevId
        self.version = version ?? 0
        
        self.todoItemText = todoItemText
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.duedateAt = duedateAt
        self.completedAt = completedAt
        self.archivedAt = archivedAt
        
        self.isCompleted = completed ?? false
        self.isArchived = isArchived ?? false
        self.isNew = isNew ?? false
        self.isPublic = isPublic ?? false
        self.isFavourite = isFavourite ?? false
    }
}

extension DVTodoItemTaskViewModel {
    static func fromCoreData(todoItem: TodoItem) -> DVTodoItemTaskViewModel {
        var converted: DVTodoItemTaskViewModel?
        todoItem.managedObjectContext?.performAndWait {
            converted = DVTodoItemTaskViewModel.init(uuid: todoItem.id!,
                                                     versionId: todoItem.versionId,
                                                     versionPrevId: todoItem.versionPrevId,
                                                     version: todoItem.version,
                                                     todoItemText: todoItem.todoItemText!,
                                                     createdAt: todoItem.createdAt!,
                                                     updatedAt: todoItem.updatedAt!,
                                                     duedateAt: todoItem.duedateAt,
                                                     completedAt: todoItem.completedAt,
                                                     archivedAt: todoItem.archivedAt,
                                                     completed: todoItem.completed,
                                                     isArchived: todoItem.isArchived,
                                                     isNew: todoItem.isNew,
                                                     isPublic: todoItem.isPublic,
                                                     isFavourite: todoItem.isFavourite)
        }
        return converted!
    }
}
