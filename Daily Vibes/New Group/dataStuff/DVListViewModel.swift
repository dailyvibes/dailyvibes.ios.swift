//
//  DVListViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DVListViewModel: NSObject {

    var uuid: UUID
    
    var version: Int = 0
    var versionId: UUID?
    var versionPrevId: UUID?
    
    var createdAt: Date
    var updatedAt: Date
    var duedateAt: Date?
    var completedAt: Date?
    var archivedAt: Date?
    
    var title: String?
    var titleDescription: String?
    var emoji: String?
    var color: String?
    
    var isFavourite: Bool = false
    var isListVisible: Bool = false
    var isPublic: Bool = false
    var isDVDefault: Bool = false
    
    var listItems: [DVTodoItemTaskViewModel]?
    
    init(uuid: UUID, createdAt: Date, updatedAt: Date, duedateAt: Date?, completedAt: Date?, archivedAt: Date?, title: String?, titleDescription: String?, emoji: String?, color: String?, isDVDefault: Bool?) {
        self.uuid = uuid
        
        self.title = title
        self.titleDescription = titleDescription
        self.emoji = emoji
        self.color = color
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.duedateAt = duedateAt
        self.completedAt = completedAt
        self.archivedAt = archivedAt
        self.isDVDefault = isDVDefault ?? false
        
        self.listItems = [DVTodoItemTaskViewModel]()
    }
    
}

extension DVListViewModel {
    static func fromCoreData(list: DailyVibesList) -> DVListViewModel {
        var converted: DVListViewModel?
        
        list.managedObjectContext?.performAndWait {
            converted = DVListViewModel.init(uuid: list.uuid!, createdAt: list.createdAt!, updatedAt: list.updatedAt!, duedateAt: list.duedateAt, completedAt: list.completedAt, archivedAt: list.archivedAt, title: list.title, titleDescription: list.titleDescription, emoji: list.emoji, color: list.color, isDVDefault: list.isDVDefault)
        }
        
        return converted!
    }
    
    static func makeEmpty() -> DVListViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()

        return DVListViewModel.init(uuid: fallbackString!, createdAt: curDate, updatedAt: curDate, duedateAt: nil, completedAt: nil, archivedAt: nil, title: emptyString, titleDescription: emptyString, emoji: emptyString, color: emptyString, isDVDefault: false)
    }
    
    static func copyWithoutListItems(list: DVListViewModel) -> DVListViewModel {
        let result = makeEmpty()
        result.uuid = list.uuid
        result.title = list.title
        result.titleDescription = list.titleDescription
        result.color = list.color
        result.emoji = list.emoji
        result.isFavourite = list.isFavourite
        result.isPublic = list.isPublic
        result.isListVisible = list.isListVisible
        result.isDVDefault = list.isDVDefault
        return result
    }
}
