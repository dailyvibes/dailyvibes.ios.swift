//
//  TodoItemSettingsData.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-25.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import Foundation
import CoreData
import UIKit

fileprivate class TagsData {
    // used to hold the data for the screen...
    // no point in saving the data if someone clicks cancel
    var uuid: UUID?
    var string: String?
    var createdAt: Date?
    var updatedAt: Date?
    var completedAt: Date?
    var archivedAt: Date?
    var isNew: Bool = true
    var isCompleted: Bool = false
    var isArchived: Bool = false
    
    var dev_hasDateCreatedAt: Bool = false
    var dev_dateCreatedAt: Date?
    var dev_hasDateCompletedAt: Bool = false
    var dev_dateCompletedAt: Date?
    var dev_hasDateArchivedAt: Bool = false
    var dev_dateArchivedAt: Date?
    
    var createdAtEmotion: String?
    var updatedAtEmotion: String?
    var completedAtEmotion: String?
    
    init(dataFor todoItem:TodoItem?) {
        if let todoItem = todoItem as TodoItem? {
            self.uuid = todoItem.id
            self.string = todoItem.todoItemText
            self.createdAt = todoItem.createdAt
            self.updatedAt = todoItem.updatedAt
            self.completedAt = todoItem.completedAt
            self.archivedAt = todoItem.archivedAt
            self.isNew = todoItem.isNew
            self.isCompleted = todoItem.completed
            self.isArchived = todoItem.isArchived
            self.createdAtEmotion = todoItem.createdAtEmotion
            self.updatedAtEmotion = todoItem.updatedAtEmotion
            self.completedAtEmotion = todoItem.completedAtEmotion
        } else {
            self.uuid = UUID.init()
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
    
    /*
     var uuid: UUID?
     var string: String?
     var createdAt: Date?
     var updatedAt: Date?
     var completedAt: Date?
     var archivedAt: Date?
     var isNew: Bool = true
     var isCompleted: Bool = false
     var isArchived: Bool = false
     
     var createdAtEmotion: String?
     var updatedAtEmotion: String?
     var completedAtEmotion: String?
    */
    
    func syncDataWith(todoItem:TodoItem?) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else { return false }
        _todoItem.id = self.uuid
        _todoItem.todoItemText = self.string
        _todoItem.createdAt = self.createdAt
        _todoItem.createdAtEmotion = self.createdAtEmotion
        _todoItem.updatedAt = self.updatedAt
        _todoItem.updatedAtEmotion = self.updatedAtEmotion
        if isCompleted {
            _todoItem.markCompleted()
        }
        _todoItem.completedAtEmotion = self.createdAtEmotion
        _todoItem.isNew = self.isNew
        _todoItem.isArchived = self.isArchived
        _todoItem.archivedAt = self.archivedAt
        return true
    }
}

class TodoItemSettingsData {
    
    private let __todoItem: TodoItem?
    private var tags = [Tag]()
    private var isNew = true
    private let tableView: UITableView?
    private let tagsCellIndexPath = IndexPath(row: 1, section: 0)
    
    private let taskPlaceholderText = NSLocalizedString("What would you like to do?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND What would you like to do? **", comment: "")
    
    private let data: TagsData?
    
    init(for todoItem: TodoItem?,in tableView: UITableView) {
        if let todoItem = todoItem as TodoItem? {
            // existing todo task
            self.data = TagsData(dataFor: todoItem)
            self.__todoItem = todoItem
            self.tableView = tableView
            
            let tagsCounter = todoItem.tagz?.count ?? -1
            
            if tagsCounter > 0 {
                guard let _tags = todoItem.tagz?.allObjects as? [Tag] else {
                    fatalError("there should be tags... since count is more than 0")
                }
                self.tags = _tags
            }
        } else {
            // brand new todo task
            self.__todoItem = nil
            self.tableView = tableView
            self.data = TagsData(dataFor: nil)
        }
    }
    
    fileprivate func processTags(forTodo todoItem:TodoItem?) {
        guard let _todo = todoItem as TodoItem? else {
            fatalError("processTags failure")
        }
        //        fatalError("not implemented yet")
        
        // tags is set on init
        // if there are no tags its empty
        // if there are tags it is not empty
        // via tag controller... if we add a tag, tags increases
        // via tag controller... if we remove a tag, tags decrease
        
        guard let _tagSet = _todo.tagz as NSSet? else {
            fatalError("it is a NSSet... should not fail")
        }
        
        let _tags = tags
        
        if (tags.count > _tagSet.count) {
            // if tags increased
            // go through each item in the list
            for tag in _tags {
                if _tagSet.contains(tag) {
                    // check if tagSet contains it
                    // if it does do nothing
                } else {
                    // if it does  not... add it
                    _todo.addToTagz(tag)
                }
            }
        }
        
        if (tags.count < _tagSet.count) {
            // if tags decreased
            // go through each item in the list
            // have to walk through the tagset instead... if contains do nothing, if it does not... remove it
            
            for tag in _tagSet {
                guard let _tag = tag as? Tag else { fatalError("it should be...") }
                if tags.contains(_tag) {
                    // check if tags contains it
                    // do nothing
                } else {
                    // if it does not... remove it
                    // because we removed it
                    _todo.removeFromTagz(_tag)
                }
            }
            
        }
        
        // not sure about below anymore
        // ideally... set the tags to tagz
        // because this class handles the commands on tagz (addition and removal)
    }
    
    func processSave(in context: NSManagedObjectContext) -> Bool{
        let _todo: TodoItem
        if let _temp = __todoItem as TodoItem? {
//            process a created todo
            _todo = _temp
//            fatalError("todoItem should be already set by processSave")
        } else {
            // create a new todo
            _todo = TodoItem.createTodoItem(in: context)
        }
        
        do {
            guard (data?.syncDataWith(todoItem: _todo))! else {
                fatalError("syncDataWith this should not fail")
            }
            
            // TODO: REMOVE
            
            if let hasDevCreated_createdAt = data?.dev_hasDateCreatedAt, hasDevCreated_createdAt {
//                print("set custom createdAt")
                _todo.createdAt = data?.dev_dateCreatedAt
//                print("set custom createdAt to: \(_todo.createdAt)")
            }
            
            if let hasDevCreated_completedAt = data?.dev_hasDateCompletedAt, hasDevCreated_completedAt {
                print("set custom Completed At")
                _todo.completedAt = data?.dev_dateCompletedAt
            }
            
            if let hasDevCreated_archivedAt = data?.dev_hasDateArchivedAt, hasDevCreated_archivedAt {
                _todo.archivedAt = data?.dev_dateArchivedAt
            }
            
            _todo.updatedAt = Date()
//            processTags()
            processTags(forTodo: _todo)
            _todo.isNew = false
            
            try context.save()
            
            if _todo.completed {
                guard StreakManager.process(item: _todo) else {
                    fatalError("StreakManager should not fail")
                }
            }
            
            return true
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func processCancel(in _context: NSManagedObjectContext) -> Bool {
        if !isNewTodo() {
            _context.rollback()
//            return true
        }
        return true
    }
    
    /*
     needed to delete todos from context on Cancel... changed the way this is done...
    private func removefromTodos(in managedObjectcontext: NSManagedObjectContext) -> Bool {
        guard let todo = todoItem as TodoItem? else {
            fatalError("todoItem should be already set for removefromTodos")
        }
        managedObjectcontext.delete(todo)
        do {
            try managedObjectcontext.save()
            return true
        } catch {
            managedObjectcontext.rollback()
            fatalError("removefromTodos failed")
        }
    }
    */
    
    func addOrRemove(this _tag: Tag) -> Bool {
        if contains(tag: _tag) {
            guard removeFromTags(this: _tag) else {
                fatalError("removeFromTags should not return false")
            }
        } else {
            guard addToTags(this: _tag) else {
                fatalError("addToTags should not return false")
            }
        }
        tableView?.reloadData()
        return true
    }
    
    private func addToTags(this _tag: Tag) -> Bool {
        // adding an element that already exists in tags
        // shouldn't have duplicates because every tag is unique
        if contains(tag: _tag) {
            // do nothing
            fatalError("cannot call this method... it already has it")
        } else {
            tags.append(_tag)
            return true
        }
    }
    
    func tagsCellIndexPath(equals indexPath: IndexPath) -> Bool {
        if indexPath.row == tagsCellIndexPath.row && indexPath.section == tagsCellIndexPath.section {
            return true
        }
        return false
    }
    
    private func removeFromTags(this _tag: Tag) -> Bool {
        // check if it contains the tag
        // you only remove it if it containts it...
        if contains(tag: _tag), let _tagToRemoveIndex = tags.index(of: _tag) {
            tags.remove(at: _tagToRemoveIndex)
            return true
        } else {
            // not sure how this would ever be hit...
            fatalError("not sure how this would ever be hit...")
        }
    }
    
    // MARK: - Helpers
    
    func setCreatedAt(emotion input: String?) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("should be set by now")
//        }
//        _todoItem.createdAtEmotion = input
        data?.createdAtEmotion = input
        return true
    }
    
    func setCompletedAt(emotion input: String?) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("should be set by now")
//        }
//        _todoItem.completedAtEmotion = input
        data?.completedAtEmotion = input
        return true
    }
    
    func setUpdatedAt(emotion input: String?) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("should be set by now")
//        }
//        _todoItem.updatedAtEmotion = input
        data?.updatedAtEmotion = input
        return true
    }
    
    func setTodoCompleted(at date: Date) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("has to be a TodoItem")
//        }
//        _todoItem.completedAt = date
        data?.completedAt = date
        return true
    }
    
    func contains(tag _tag: Tag) -> Bool {
        return tags.contains(_tag)
    }
    
    func holdingAnyTags() -> Bool {
        guard tags.count > 0 else {
            return false
        }
        return true
    }
    
    func isNewTodo() -> Bool {
        //        guard let result = todoItem?.isNew else {
        //            fatalError("isNewTodo")
        //        }
        return data?.isNew ?? true
    }
    
    func getTodoCompletedAt() -> Date? {
//        return todoItem!.completedAt as Date?
        return data?.completedAt
    }
    
    func setTodoText(to input: String) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("todoItem should be set by now")
//        }
//        _todoItem.todoItemText = input
        data?.string = input
        return true
    }
    
    func markCompleted(with emotion: String?) -> Bool {
//        guard let _todoItem = todoItem as TodoItem? else {
//            fatalError("todoItem should be set")
//        }
//        _todoItem.markCompleted()
//        _todoItem.completedAtEmotion = emotion
        data?.isCompleted = true
        data?.completedAtEmotion = emotion
        return true
    }
    
    func getTodoText() -> String {
        
//        return todoItem!.todoItemText ?? ""
        return data?.string ?? ""
    }
    
    func getTodoCompletedEmotion() -> String? {
//        return todoItem!.completedAtEmotion as String?
        return data?.completedAtEmotion ?? "** BROKEN **"
    }
    
    func wasCompleted() -> Bool {
//        return todoItem!.completed
        return data?.isCompleted ?? false
    }
    
    func getTodoPlaceholderText() -> String {
        return taskPlaceholderText
    }
    
    // TODO: REMOVE
    func setCreatedAt(date: Date?) -> Bool {
        data?.dev_hasDateCreatedAt = true
        data?.dev_dateCreatedAt = date
        return true
    }
    
    func setArchivedAt(date: Date?) -> Bool {
        data?.dev_hasDateArchivedAt = true
        data?.dev_dateArchivedAt = date
        return true
    }
    
    func setCompletedAtDate(date: Date?) -> Bool {
        data?.dev_hasDateCompletedAt = true
        data?.dev_dateCompletedAt = date
        return true
    }
}
