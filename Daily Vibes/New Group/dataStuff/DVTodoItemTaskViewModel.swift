//
//  DVTodoItemTaskViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

//
//The simplest way to make a type codable is to declare its properties using types that are already Codable. These types include standard library types like String, Int, and Double; and Foundation types like Date, Data, and URL. Any type whose properties are codable automatically conforms to Codable just by declaring that conformance.
//

import UIKit

struct DVTodoItemTaskViewModel: Codable {
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
        self.tags = [DVTagViewModel]()
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case versionId
        case versionPrevId
        case version
        case todoItemText
        case createdAt
        case updatedAt
        case duedateAt
        case completedAt
        case archivedAt
        case isCompleted
        case isArchived
        case isNew
        case isPublic
        case isFavourite
        case isRemindable
        case tags
        case list
        case note
    }
    
    //    let uuid: UUID
    //    var versionId: UUID?
    //    var versionPrevId: UUID?
    //    var version: Int64
    //    var todoItemText: String
    //    var createdAt: Date
    //    var updatedAt: Date
    //    var duedateAt: Date?
    //    var completedAt: Date?
    //    var archivedAt: Date?
    //    var isCompleted: Bool
    //    var isArchived: Bool
    //    var isNew: Bool
    //    var isPublic: Bool
    //    var isFavourite: Bool
    //    var isRemindable: Bool?
    //    var tags: [DVTagViewModel]?
    //    var list: DVListViewModel?
    //    var note: DVNoteViewModel?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.versionId = try values.decodeIfPresent(UUID.self, forKey: .versionId)
        self.versionPrevId = try values.decodeIfPresent(UUID.self, forKey: .versionPrevId)
        self.version = try values.decode(Int64.self, forKey: .version)
        self.todoItemText = try values.decode(String.self, forKey: .todoItemText)
        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        self.duedateAt = try values.decodeIfPresent(Date.self, forKey: .duedateAt)
        self.completedAt = try values.decodeIfPresent(Date.self, forKey: .completedAt)
        self.archivedAt = try values.decodeIfPresent(Date.self, forKey: .archivedAt)
        self.isCompleted = try values.decode(Bool.self, forKey: .isCompleted)
        self.isArchived = try values.decode(Bool.self, forKey: .isArchived)
        self.isNew = try values.decode(Bool.self, forKey: .isNew)
        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
        self.isFavourite = try values.decode(Bool.self, forKey: .isFavourite)
        self.isRemindable = try values.decodeIfPresent(Bool.self, forKey: .isRemindable)
        self.tags = try values.decodeIfPresent([DVTagViewModel].self, forKey: .tags)
        self.list = try values.decodeIfPresent(DVListViewModel.self, forKey: .list)
        self.note = try values.decodeIfPresent(DVNoteViewModel.self, forKey: .note)
    }
    
    //    let uuid: UUID
    //    var versionId: UUID?
    //    var versionPrevId: UUID?
    //    var version: Int64
    //    var todoItemText: String
    //    var createdAt: Date
    //    var updatedAt: Date
    //    var duedateAt: Date?
    //    var completedAt: Date?
    //    var archivedAt: Date?
    //    var isCompleted: Bool
    //    var isArchived: Bool
    //    var isNew: Bool
    //    var isPublic: Bool
    //    var isFavourite: Bool
    //    var isRemindable: Bool?
    //    var tags: [DVTagViewModel]?
    //    var list: DVListViewModel?
    //    var note: DVNoteViewModel?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(versionId ?? nil, forKey: .versionId)
        try container.encode(versionPrevId ?? nil, forKey: .versionPrevId)
        try container.encode(version, forKey: .version)
        try container.encode(todoItemText, forKey: .todoItemText)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(duedateAt ?? nil, forKey: .duedateAt)
        try container.encode(completedAt ?? nil, forKey: .completedAt)
        try container.encode(archivedAt ?? nil, forKey: .archivedAt)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encode(isNew, forKey: .isNew)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(isFavourite, forKey: .isFavourite)
        try container.encode(isRemindable, forKey: .isRemindable)
        
        if let _tags = tags {
            var tagsArray = container.nestedContainer(keyedBy: DVTagViewModel.CodingKeys.self, forKey: .tags)
            
            try _tags.forEach {
                try tagsArray.encode($0.uuid, forKey: .uuid)
                try tagsArray.encode($0.label, forKey: .label)
                try tagsArray.encode($0.version, forKey: .version)
                try tagsArray.encode($0.versionId, forKey: .versionId)
                try tagsArray.encode($0.versionPrevId, forKey: .versionPrevId)
                try tagsArray.encode($0.createdAt, forKey: .createdAt)
                try tagsArray.encode($0.updatedAt, forKey: .updatedAt)
                try tagsArray.encode($0.isArchived, forKey: .isArchived)
                try tagsArray.encode($0.isPublic, forKey: .isPublic)
                try tagsArray.encode($0.colourRepresentation, forKey: .colourRepresentation)
                try tagsArray.encode($0.emoji, forKey: .emoji)
                try tagsArray.encode($0.active, forKey: .active)
                try tagsArray.encode($0.completed, forKey: .completed)
                try tagsArray.encode($0.tagged, forKey: .tagged)
            }
        }
        
        //        try container.encode(self.tags, forKey: .tags)
        try container.encode(list, forKey: .list)
        try container.encode(note, forKey: .note)
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

//var tags: [DVTagViewModel]?
//var list: DVListViewModel?
//var note: DVNoteViewModel?

extension DVTodoItemTaskViewModel {
    func encodedString() -> String {
        let dateFormatter = DateFormatter()
        var encodedString = ""
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if isCompleted {
            encodedString.append("[X] ")
            if let dateCompletedAt = completedAt {
                let completedDate = dateFormatter.string(from: dateCompletedAt)
                encodedString.append("\(completedDate) ")
            }
        } else {
            encodedString.append("[ ] ")
        }
        
        let createdDate = dateFormatter.string(from: createdAt)
        encodedString.append("\(createdDate) ")
        
        encodedString.append("\(todoItemText) ")
        
        if let project = list, let title = project.title {
            encodedString.append("+\(title) ")
        }
        
        if let tagList = tags, tagList.count > 0 {
            for tag in tagList {
                encodedString.append("#\(tag.label) ")
            }
        }
        
        if let dueDate = duedateAt {
            let encodedDueDate = dateFormatter.string(from: dueDate)
            encodedString.append("due:\(encodedDueDate)")
        }

        return encodedString
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
            if let hasNote = todoItem.notes {
                converted?.note = DVNoteViewModel.fromCoreData(note: hasNote)
            }
            if let hasList = todoItem.list {
                converted?.list = DVListViewModel.fromCoreData(list: hasList)
            }
        }
        return converted!
    }
    
    static func makeEmpty() -> DVTodoItemTaskViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        var result =  DVTodoItemTaskViewModel.init(uuid: fallbackString!, versionId: nil, versionPrevId: nil, version: nil, todoItemText: emptyString, createdAt: curDate, updatedAt: curDate, duedateAt: nil, completedAt: nil, archivedAt: nil, completed: false, isArchived: false, isNew: true, isPublic: false, isFavourite: false, isRemindable: false)
        
        result.tags = [DVTagViewModel]()
        
        return result
    }
}
