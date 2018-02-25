//
//  DVTagViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DVTagViewModel: NSObject {
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
