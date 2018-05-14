//
//  DVCoreSectionViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVCoreSectionViewModel: Codable {
    var filterStatus: DVSectionVMStatus
    var sectionIdentifier: String
    var indexTitle: String?
    var _sectionCount: Int
    var position: IndexPath?
    var allObjects: [DVTodoItemTaskViewModel] {
        didSet {
            completedObjects = allObjects.filter { todoItemTask in todoItemTask.isCompleted }
            upcomingObjects = allObjects.filter { todoItemTask in !todoItemTask.isCompleted }
        }
    }
    var completedObjects: [DVTodoItemTaskViewModel]
    var upcomingObjects: [DVTodoItemTaskViewModel]
    
    init(sectionIdentifier:String, sectionCount:Int, indexTitle: String?) {
        self.sectionIdentifier = sectionIdentifier
        self._sectionCount = sectionCount
        self.indexTitle = indexTitle
        self.allObjects = [DVTodoItemTaskViewModel]()
        self.completedObjects = [DVTodoItemTaskViewModel]()
        self.upcomingObjects = [DVTodoItemTaskViewModel]()
        self.filterStatus = .all
    }
    
    private enum CodingKeys: String, CodingKey {
        case filterStatus
        case sectionIdentifier
        case indexTitle
        case _sectionCount
        case position
        case allObjects
//        case completedObjects
//        case upcomingObjects
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // to figure out the .all after
        self.filterStatus = try values.decode(DVSectionVMStatus.self, forKey: .filterStatus)
        self.sectionIdentifier = try values.decode(String.self, forKey: .sectionIdentifier)
        self.indexTitle = try values.decodeIfPresent(String.self, forKey: .indexTitle)
        self._sectionCount = try values.decode(Int.self, forKey: ._sectionCount)
        self.position = try values.decodeIfPresent(IndexPath.self, forKey: .position)
        self.allObjects = try values.decode([DVTodoItemTaskViewModel].self, forKey: .allObjects)
//        self.completedObjects = try values.decode([DVTodoItemTaskViewModel].self, forKey: .completedObjects)
//        self.upcomingObjects = try values.decode([DVTodoItemTaskViewModel].self, forKey: .upcomingObjects)
        self.completedObjects = allObjects.filter { todoItemTask in todoItemTask.isCompleted }
        self.upcomingObjects = allObjects.filter { todoItemTask in !todoItemTask.isCompleted }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(filterStatus, forKey: .filterStatus)
        try container.encode(sectionIdentifier, forKey: .sectionIdentifier)
        try container.encode(indexTitle, forKey: .indexTitle)
        try container.encode(_sectionCount, forKey: ._sectionCount)
        try container.encode(position, forKey: .position)
        
        var allObjectsArray = container.nestedUnkeyedContainer(forKey: .allObjects)
//        var completedObjectsArray = container.nestedUnkeyedContainer(forKey: .completedObjects)
//        var upcomingObjectsArray = container.nestedUnkeyedContainer(forKey: .upcomingObjects)
        
        try allObjects.forEach {
            try allObjectsArray.encode($0)
        }
        
//        try completedObjects.forEach {
//            try completedObjectsArray.encode($0)
//        }
//        
//        try upcomingObjects.forEach {
//            try upcomingObjectsArray.encode($0)
//        }
        
//        try container.encode(allObjects, forKey: .allObjects)
//        try container.encode(completedObjects, forKey: .completedObjects)
//        try container.encode(upcomingObjects, forKey: .upcomingObjects)
    }
    
    func objects() -> [DVTodoItemTaskViewModel] {
        switch filterStatus {
        case .all:
            return allObjects
        case .completed:
            return completedObjects
        case .upcoming:
            return upcomingObjects
        }
    }
    
    func sectionCount() -> Int {
        switch filterStatus {
        case .all:
            return allObjects.count
        case .completed:
            return completedObjects.count
        case .upcoming:
            return upcomingObjects.count
        }
    }
    
    func object(at indexPath: IndexPath) -> DVTodoItemTaskViewModel {
        switch filterStatus {
        case .all:
            return allObjects[indexPath.row]
        case .completed:
            return completedObjects[indexPath.row]
        case .upcoming:
            return upcomingObjects[indexPath.row]
        }
    }
    
    mutating func switchDVTodoItemTask(viewModel vm:DVTodoItemTaskViewModel, at indexPath: IndexPath) -> () {
        switch filterStatus {
        case .all:
            allObjects[indexPath.row] = vm
        case .completed:
            completedObjects[indexPath.row] = vm
        case .upcoming:
            upcomingObjects[indexPath.row] = vm
        }
    }
    
    mutating func removeDVTodoItemTask(at indexPath:IndexPath) -> DVTodoItemTaskViewModel {
        switch filterStatus {
        case .all:
            return allObjects.remove(at: indexPath.row)
        case .completed:
            return completedObjects.remove(at: indexPath.row)
        case .upcoming:
            return upcomingObjects.remove(at: indexPath.row)
        }
    }
}
