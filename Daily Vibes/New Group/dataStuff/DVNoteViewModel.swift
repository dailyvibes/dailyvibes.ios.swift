//
//  DVNoteViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DVNoteViewModel: NSObject {
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
    
    var attachedTo: DVTodoItemTaskViewModel?
    
    init(uuid: UUID, title: String?, content: String?, createdAt: Date, updatedAt: Date, completedAt: Date?, archivedAt: Date?) {
        self.uuid = uuid
        self.title = title
        self.content = content
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.archivedAt = archivedAt
    }
}

extension DVNoteViewModel {
    static func fromCoreData(note: DailyVibesNote) -> DVNoteViewModel {
        var converted: DVNoteViewModel?
        note.managedObjectContext?.performAndWait {
            converted = DVNoteViewModel.init(uuid: note.uuid!, title: note.title, content: note.content, createdAt: note.createdAt!, updatedAt: note.updatedAt!, completedAt: note.completedAt, archivedAt: note.archivedAt)
        }
        return converted!
    }
    
    static func makeEmpty() -> DVNoteViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        return DVNoteViewModel.init(uuid: fallbackString!, title: emptyString, content: emptyString, createdAt: curDate, updatedAt: curDate, completedAt: nil, archivedAt: nil)
    }
}
