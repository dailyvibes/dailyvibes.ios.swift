//
//  DVNoteViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVNoteViewModel: Codable {
    var uuid: UUID
    var title: String?
    var content: String?
    var version: Int = 0
    var versionId: UUID?
    var versionPrevId: UUID?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var archivedAt: Date?
    var isPublic: Bool = false
    var isFavourite: Bool = false
    var dvTodoItemTaskViewModelUUID: UUID?
    
    init(uuid: UUID, title: String?, content: String?, createdAt: Date, updatedAt: Date, completedAt: Date?, archivedAt: Date?, dvTodoItemTaskViewModelUUID: UUID?) {
        self.uuid = uuid
        self.title = title
        self.content = content
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.archivedAt = archivedAt
        self.dvTodoItemTaskViewModelUUID = dvTodoItemTaskViewModelUUID
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case content
        case version
        case versionId
        case versionPrevId
        case createdAt
        case updatedAt
        case completedAt
        case archivedAt
        case isPublic
        case isFavourite
        case dvTodoItemTaskViewModelUUID
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.title = try values.decode(String.self, forKey: .title)
        self.content = try values.decode(String.self, forKey: .content)
        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        self.completedAt = try values.decode(Date.self, forKey: .completedAt)
        self.archivedAt = try values.decode(Date.self, forKey: .archivedAt)
        self.completedAt = try values.decode(Date.self, forKey: .completedAt)
        self.archivedAt = try values.decode(Date.self, forKey: .archivedAt)
        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
        self.isFavourite = try values.decode(Bool.self, forKey: .isFavourite)
        self.dvTodoItemTaskViewModelUUID = try values.decodeIfPresent(UUID.self, forKey: .dvTodoItemTaskViewModelUUID)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(version, forKey: .version)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(archivedAt, forKey: .archivedAt)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(isFavourite, forKey: .isFavourite)
        try container.encode(dvTodoItemTaskViewModelUUID, forKey: .dvTodoItemTaskViewModelUUID)
    }
}

extension DVNoteViewModel {
    static func fromCoreData(note: DailyVibesNote) -> DVNoteViewModel {
        var converted: DVNoteViewModel?
        note.managedObjectContext?.performAndWait {
            converted = DVNoteViewModel.init(uuid: note.uuid!, title: note.title, content: note.content, createdAt: note.createdAt!, updatedAt: note.updatedAt!, completedAt: note.completedAt, archivedAt: note.archivedAt, dvTodoItemTaskViewModelUUID: nil)
        }
        return converted!
    }
    
    static func makeEmpty() -> DVNoteViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        return DVNoteViewModel.init(uuid: fallbackString!, title: emptyString, content: emptyString, createdAt: curDate, updatedAt: curDate, completedAt: nil, archivedAt: nil, dvTodoItemTaskViewModelUUID: nil)
    }
}
