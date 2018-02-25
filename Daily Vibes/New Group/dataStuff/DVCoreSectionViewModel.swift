//
//  DVCoreSectionViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DVCoreSectionViewModel: NSObject {
    var filterStatus: DVSectionVMStatus
    
    var sectionIdentifier: String
    var indexTitle: String?
    var _sectionCount: Int
    
    var position: IndexPath?
//    var objects: [DVTodoItemTaskViewModel] {
//        didSet {
//            allObjects = objects.map { todoItem in todoItem }
//            completedObjects = objects.filter { todotaskItem in todotaskItem.isCompleted }
//            upcomingObjects = objects.filter { todotaskItem in !todotaskItem.isCompleted }
//        }
//    }
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
//        self.objects = [DVTodoItemTaskViewModel]()
        self.allObjects = [DVTodoItemTaskViewModel]()
        self.completedObjects = [DVTodoItemTaskViewModel]()
        self.upcomingObjects = [DVTodoItemTaskViewModel]()
        self.filterStatus = .all
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
    
    func switchDVTodoItemTask(viewModel vm:DVTodoItemTaskViewModel, at indexPath: IndexPath) -> () {
        switch filterStatus {
        case .all:
            allObjects[indexPath.row] = vm
        case .completed:
            completedObjects[indexPath.row] = vm
        case .upcoming:
            upcomingObjects[indexPath.row] = vm
        }
    }
    
    func removeDVTodoItemTask(at indexPath:IndexPath) -> DVTodoItemTaskViewModel {
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
