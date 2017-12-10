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

fileprivate struct Data {
    // used to hold the data for the screen...
    // no point in saving the data if someone clicks cancel
    private var string: String?
    private var createdAt: Date?
    private var updatedAt: Date?
    private var completedAt: Date?
    private var isNew: Bool = true
}

class TodoItemSettingsData {
    
    private let todoItem: TodoItem?
    private var tags = [Tag]()
    private var isNew = true
    private let tableView: UITableView?
    private let tagsCellIndexPath = IndexPath(row: 1, section: 0)
    
    private let taskPlaceholderText = "What would you like to do?"
    
    private let data = Data()
    
    init(for todoItem: TodoItem,in tableView: UITableView) {
        self.todoItem = todoItem
        self.tableView = tableView
        if (todoItem.tagz?.count)! > 0 {
            guard let _tags = todoItem.tagz?.allObjects as? [Tag] else {
                fatalError("there should be tags... since count is more than 0")
            }
            self.tags = _tags
        }
        print("~~~ created todoitemsettingsdata ~~~")
    }
    
    fileprivate func processTags() {
        //        fatalError("not implemented yet")
        
        // tags is set on init
        // if there are no tags its empty
        // if there are tags it is not empty
        // via tag controller... if we add a tag, tags increases
        // via tag controller... if we remove a tag, tags decrease
        
        guard let _todo = self.todoItem as TodoItem? else {
            fatalError("todoItem should be set by now")
        }
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
        guard let _todo = todoItem as TodoItem? else {
            fatalError("todoItem should be already set by processSave")
        }
        
        do {
            _todo.updatedAt = Date()
            processTags()
            _todo.isNew = false
            
            try context.save()
            
            return true
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func processCancel(in _context: NSManagedObjectContext) -> Bool {
        if isNewTodo() {
            return removefromTodos(in: _context)
        } else {
            _context.rollback()
            return true
        }
    }
    
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
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("should be set by now")
        }
        _todoItem.createdAtEmotion = input
        return true
    }
    
    func setCompletedAt(emotion input: String?) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("should be set by now")
        }
        _todoItem.completedAtEmotion = input
        return true
    }
    
    func setUpdatedAt(emotion input: String?) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("should be set by now")
        }
        _todoItem.updatedAtEmotion = input
        return true
    }
    
    func setTodoCompleted(at date: Date) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("has to be a TodoItem")
        }
        _todoItem.completedAt = date
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
        guard let result = todoItem?.isNew else {
            fatalError("isNewTodo")
        }
        return result
    }
    
    func getTodoCompletedAt() -> Date? {
        return todoItem!.completedAt as Date?
    }
    
    func setTodoText(to input: String) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("todoItem should be set by now")
        }
        _todoItem.todoItemText = input
        return true
    }
    
    func markCompleted(with emotion: String?) -> Bool {
        guard let _todoItem = todoItem as TodoItem? else {
            fatalError("todoItem should be set")
        }
        _todoItem.markCompleted()
        _todoItem.completedAtEmotion = emotion
        return true
    }
    
    func getTodoText() -> String {
        
        return todoItem!.todoItemText ?? ""
    }
    
    func getTodoCompletedEmotion() -> String? {
        return todoItem!.completedAtEmotion as String?
    }
    
    func wasCompleted() -> Bool {
        return todoItem!.completed
    }
    
    func getTodoPlaceholderText() -> String {
        return taskPlaceholderText
    }
}
