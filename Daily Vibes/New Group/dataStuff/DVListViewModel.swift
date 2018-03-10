//
//  DVListViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVListViewModel: Codable {

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
    
    var listItemCountCompleted: Int = 0
    var listItemCountTotal: Int = 0
    
    init(uuid: UUID, createdAt: Date, updatedAt: Date, duedateAt: Date?, completedAt: Date?, archivedAt: Date?, title: String?, titleDescription: String?, emoji: String?, color: String?, isDVDefault: Bool?, listItemCountCompleted: Int? = 0, listItemCountTotal: Int? = 0) {
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
        self.listItemCountTotal = listItemCountTotal ?? 0
        self.listItemCountCompleted = listItemCountCompleted ?? 0
    }
    
    enum DVListViewModelCodingKeys: String, CodingKey {
        case uuid
        case version
        case versionId
        case versionPrevId
        case createdAt
        case updatedAt
        case duedateAt
        case completedAt
        case archivedAt
        case title
        case titleDescription
        case emoji
        case color
        case isFavourite
        case isListVisible
        case isPublic
        case isDVDefault
        case listItems
        case listItemCountCompleted
        case listItemCountTotal
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: DVListViewModelCodingKeys.self)
        
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.version = try values.decode(Int.self, forKey: .version)
        self.versionId = try values.decode(UUID.self, forKey: .versionId)
        self.versionPrevId = try values.decode(UUID.self, forKey: .versionPrevId)
        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        self.duedateAt = try values.decode(Date.self, forKey: .duedateAt)
        self.completedAt = try values.decode(Date.self, forKey: .completedAt)
        self.archivedAt = try values.decode(Date.self, forKey: .archivedAt)
        self.title = try values.decode(String.self, forKey: .title)
        self.titleDescription = try values.decode(String.self, forKey: .titleDescription)
        self.emoji = try values.decode(String.self, forKey: .emoji)
        self.color = try values.decode(String.self, forKey: .color)
        self.isFavourite = try values.decode(Bool.self, forKey: .isFavourite)
        self.isListVisible = try values.decode(Bool.self, forKey: .isListVisible)
        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
        self.isDVDefault = try values.decode(Bool.self, forKey: .isDVDefault)
        self.listItems = try values.decode([DVTodoItemTaskViewModel].self, forKey: .listItems)
        self.listItemCountCompleted = try values.decode(Int.self, forKey: .listItemCountCompleted)
        self.listItemCountTotal = try values.decode(Int.self, forKey: .listItemCountTotal)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DVListViewModelCodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(version, forKey: .version)
        try container.encode(versionId, forKey: .versionId)
        try container.encode(versionPrevId, forKey: .versionPrevId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(duedateAt, forKey: .duedateAt)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(archivedAt, forKey: .archivedAt)
        try container.encode(title, forKey: .title)
        try container.encode(titleDescription, forKey: .titleDescription)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(color, forKey: .color)
        try container.encode(isFavourite, forKey: .isFavourite)
        try container.encode(isListVisible, forKey: .isListVisible)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(isDVDefault, forKey: .isDVDefault)
        
        var listArray = container.nestedUnkeyedContainer(forKey: .listItems)
        
        try listItems?.forEach {
            try listArray.encode($0)
        }
        
//        try container.encode(listItems, forKey: .listItems)
        try container.encode(listItemCountCompleted, forKey: .listItemCountCompleted)
        try container.encode(listItemCountTotal, forKey: .listItemCountTotal)
    }
}

extension DVListViewModel {
    static func fromCoreData(list: DailyVibesList) -> DVListViewModel {
        var converted: DVListViewModel?
//        var _listItemCountCompleted: Int = 0
//        var _listItemCountTotal: Int = 0
//
//        if let _listItems = list.listItems, _listItems.count > 0 {
//            let listItems = _listItems.allObjects as! [TodoItem]
//
//            let completedOnly = listItems.filter { task in task.completed == true }
//
//            _listItemCountCompleted = completedOnly.count
//            _listItemCountTotal = listItems.count
//        } else {
//            _listItemCountCompleted = 0
//            _listItemCountTotal = 0
//        }
        
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
        var result = makeEmpty()
        result.uuid = list.uuid
        result.title = list.title
        result.titleDescription = list.titleDescription
        result.color = list.color
        result.emoji = list.emoji
        result.isFavourite = list.isFavourite
        result.isPublic = list.isPublic
        result.isListVisible = list.isListVisible
        result.isDVDefault = list.isDVDefault
        
//        if let listItems = list.listItems, listItems.count > 0 {
//            let completedOnly = listItems.filter { listeItem in listeItem.isCompleted == true }
//            result.listItemCountCompleted = completedOnly.count
//            result.listItemCountTotal = listItems.count
//        } else {
//            result.listItemCountCompleted = 0
//            result.listItemCountTotal = 0
//        }
        
        return result
    }
}
