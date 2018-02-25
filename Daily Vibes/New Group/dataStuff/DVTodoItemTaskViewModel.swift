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
    
    var versionId: UUID?
    var versionPrevId: UUID?
    var version: Int64
    
    var todoItemText: String
    
    var createdAt: Date
    var updatedAt: Date
    var duedateAt: Date?
    var completedAt: Date?
    var archivedAt: Date?
    
    var isCompleted: Bool
    var isArchived: Bool
    var isNew: Bool
    var isPublic: Bool
    var isFavourite: Bool
    var isRemindable: Bool?
    
    var tags: [DVTagViewModel]?
    var list: DVListViewModel?
    var note: DVNoteViewModel?
    
    init(uuid:UUID, versionId:UUID?, versionPrevId: UUID?, version:Int64?, todoItemText:String, createdAt:Date, updatedAt:Date, duedateAt:Date?, completedAt:Date?, archivedAt:Date?, completed:Bool?, isArchived:Bool?, isNew:Bool?, isPublic:Bool?, isFavourite:Bool?, isRemindable: Bool? = false) {
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
        self.isRemindable = isRemindable ?? false
    }
    
    func tagsContains(tag: DVTagViewModel) -> Bool {
        var found = false
        
        if let hasTags = tags, hasTags.count > 0 {
            for _tag in hasTags {
                if _tag.uuid == tag.uuid {
                    found = true
                    break
                }
            }
        }
        
        return found
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
                                                     isFavourite: todoItem.isFavourite,
                                                     isRemindable: todoItem.isRemindable)
        }
        return converted!
    }
    
    static func makeEmpty() -> DVTodoItemTaskViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        let result =  DVTodoItemTaskViewModel.init(uuid: fallbackString!, versionId: nil, versionPrevId: nil, version: nil, todoItemText: emptyString, createdAt: curDate, updatedAt: curDate, duedateAt: nil, completedAt: nil, archivedAt: nil, completed: false, isArchived: false, isNew: true, isPublic: false, isFavourite: false, isRemindable: false)
        
        result.tags = [DVTagViewModel]()

        return result
    }
}
