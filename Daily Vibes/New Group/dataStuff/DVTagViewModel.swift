//
//  DVTagViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVTagViewModel: Codable {
    var uuid: UUID
    var label: String
    var version: Int?
    var versionId: UUID?
    var versionPrevId: UUID?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool = false
    var isPublic: Bool = false
    var colourRepresentation: String?
    var emoji: String?
    var active: Int = 0
    var completed: Int = 0
    var tagged: [DVTodoItemTaskViewModel]
    
    init(uuid: UUID, label:String, createdAt:Date, updatedAt: Date) {
        self.uuid = uuid
        self.label = label
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagged = [DVTodoItemTaskViewModel]()
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case label
        case version
        case versionId
        case versionPrevId
        case createdAt
        case updatedAt
        case isArchived
        case isPublic
        case colourRepresentation
        case emoji
        case active
        case completed
        case tagged
    }
    
    enum TaggedCodingKeys: String, CodingKey {
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.label = try values.decode(String.self, forKey: .label)
        self.version = try values.decode(Int.self, forKey: .version)
        self.versionId = try values.decode(UUID.self, forKey: .versionId)
        self.versionPrevId = try values.decode(UUID.self, forKey: .versionPrevId)
        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        self.isArchived = try values.decode(Bool.self, forKey: .isArchived)
        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
        self.colourRepresentation = try values.decode(String.self, forKey: .colourRepresentation)
        self.emoji = try values.decode(String.self, forKey: .emoji)
        self.active = try values.decode(Int.self, forKey: .active)
        self.completed = try values.decode(Int.self, forKey: .completed)
        
//        let tagged = try values.nestedContainer(keyedBy: TaggedKeys.self, forKey: .tagged)
        
        self.tagged = try values.decode([DVTodoItemTaskViewModel].self, forKey: .tagged)
//        self.tagged = try [DVTodoItemTaskViewModel(from: decoder)]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(label, forKey: .label)
        try container.encode(version, forKey: .version)
        try container.encode(versionId, forKey: .versionId)
        try container.encode(versionPrevId, forKey: .versionPrevId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(colourRepresentation, forKey: .colourRepresentation)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(active, forKey: .active)
        try container.encode(completed, forKey: .completed)
        
        var taggedArray = container.nestedContainer(keyedBy: TaggedCodingKeys.self, forKey: .tagged)
        
        try tagged.forEach {
            try taggedArray.encode($0.uuid, forKey: .uuid)
            try taggedArray.encode($0.version, forKey: .version)
            try taggedArray.encode($0.versionId, forKey: .versionId)
            try taggedArray.encode($0.versionPrevId, forKey: .versionPrevId)
            try taggedArray.encode($0.todoItemText, forKey: .todoItemText)
            try taggedArray.encode($0.createdAt, forKey: .createdAt)
            try taggedArray.encode($0.updatedAt, forKey: .updatedAt)
            try taggedArray.encode($0.duedateAt, forKey: .duedateAt)
            try taggedArray.encode($0.completedAt, forKey: .completedAt)
            try taggedArray.encode($0.archivedAt, forKey: .archivedAt)
            try taggedArray.encode($0.isCompleted, forKey: .isCompleted)
            try taggedArray.encode($0.isArchived, forKey: .isArchived)
            try taggedArray.encode($0.isNew, forKey: .isNew)
            try taggedArray.encode($0.isPublic, forKey: .isPublic)
            try taggedArray.encode($0.isFavourite, forKey: .isFavourite)
            try taggedArray.encode($0.isRemindable, forKey: .isRemindable)
            try taggedArray.encode($0.tags, forKey: .tags)
            try taggedArray.encode($0.list, forKey: .list)
            try taggedArray.encode($0.note, forKey: .note)
        }
        
//        try container.encode(tagged, forKey: .tagged)
    }
}

extension DVTagViewModel {
    static func fromCoreData(tag: Tag) -> DVTagViewModel {
        var converted: DVTagViewModel?
        tag.managedObjectContext?.performAndWait {
            converted = DVTagViewModel.init(uuid: tag.uuid!, label: tag.label!, createdAt: tag.createdAt!, updatedAt: tag.updatedAt!)
        }
        return converted!
    }
}

extension DVTagViewModel {
    static func copyWithoutTagged(tag: DVTagViewModel) -> DVTagViewModel {
        return DVTagViewModel.init(uuid: tag.uuid, label: tag.label, createdAt: tag.createdAt, updatedAt: tag.updatedAt)
    }
}
