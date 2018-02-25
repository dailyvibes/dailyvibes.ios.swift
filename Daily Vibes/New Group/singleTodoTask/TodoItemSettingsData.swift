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

class TodoItemSettingsData {
    
    private let store = CoreDataManager.store
    private var todoItemViewModel: DVTodoItemTaskViewModel? {
        didSet {
            todoItemTaskLabel = todoItemViewModel?.todoItemText
            dueDate = todoItemViewModel?.duedateAt
        }
    }
    private var streakManager = StreakManager()
    private var tags: [DVTagViewModel] {
        didSet {
            let tmp = tags.map { tag in tag.label }
            tagsString = tmp.joined(separator: ",")
            wasUpdated = true
        }
    }
    
    private var list: DVListViewModel? {
        didSet {
            projectString = list?.title
            wasUpdated = true
        }
    }
    
    private var note: DVNoteViewModel? {
        didSet {
            noteTitle = note?.title
            noteContent = note?.content
            wasUpdated = true
        }
    }
    
    var dueDate: Date?
    var todoItemTaskLabel: String?
    var projectString: String?
    var tagsString: String?
    var noteTitle: String?
    var noteContent: String?
    
    var wasUpdated: Bool = false
    
    var isNew = true
    private let tagsCellIndexPath = IndexPath(row: 1, section: 0)
    
    private let taskPlaceholderText = NSLocalizedString("What would you like to do?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND What would you like to do? **", comment: "")
    
    private let data: DVTodoItemTaskViewModel?
    
    init(forViewModel todoItemTask: DVTodoItemTaskViewModel?) {
        if let _existingTask = todoItemTask as DVTodoItemTaskViewModel? {
            // existing todo task
            let existingTask = store.findTodoItemTaskVM(withUUID: _existingTask.uuid)
            
            self.data = existingTask
            self.todoItemViewModel = existingTask
            self.dueDate = existingTask?.duedateAt
            
            self.todoItemTaskLabel = existingTask?.todoItemText
            
            if let currentTags = existingTask?.tags {
                self.tags = currentTags.map { tag in DVTagViewModel.copyWithoutTagged(tag: tag) }
                let tmp = tags.map { tag in tag.label }
                self.tagsString = tmp.joined(separator: ",")
            } else {
                self.tags = [DVTagViewModel]()
                self.tagsString = nil
            }
            
            if let project = existingTask?.list {
                self.list = project
                self.projectString = project.title
            } else {
                self.list = nil
                self.projectString = nil
            }
            
            if let __note = existingTask?.note {
                self.note = __note
                self.noteTitle = __note.title
                self.noteContent = __note.content
            } else {
                self.note = nil
                self.noteTitle = nil
                self.noteContent = nil
            }
        } else {
            // brand new todo task
            let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
            let curDate = Date()
            
            let newDVModel = DVTodoItemTaskViewModel.init(uuid: fallbackString!, versionId: nil, versionPrevId: nil, version: nil, todoItemText: "", createdAt: curDate, updatedAt: curDate, duedateAt: nil, completedAt: nil, archivedAt: nil, completed: false, isArchived: false, isNew: true, isPublic: false, isFavourite: false)
            self.todoItemViewModel = newDVModel
            self.data = newDVModel
            self.tags = [DVTagViewModel]()
            self.list = nil
            self.note = nil
            self.todoItemTaskLabel = newDVModel.todoItemText
            self.projectString = nil
            self.tagsString = nil
            self.noteTitle = nil
            self.noteContent = nil
        }
    }
    
    fileprivate func processTags(forTodo todoItem:DVTodoItemTaskViewModel?) {
        
        if tags.count > 0 {
            // has tags to process
        } else {
            // no tags to 
        }
    }
    
    func processSave() -> Bool {
//        let _todo: TodoItem
//        if let _temp = __todoItem as TodoItem? {
////            process a created todo
//            _todo = _temp
////            fatalError("todoItem should be already set by processSave")
//        } else {
//            // create a new todo
//            _todo = TodoItem.createTodoItem(in: context)
//        }
//
//        do {
//            guard (data?.syncDataWith(todoItem: _todo))! else {
//                fatalError("syncDataWith this should not fail")
//            }
//
//            if let _list = list as DailyVibesList? {
//                _list.addToListItems(_todo)
//                _todo.setValue(_list, forKey: "list")
//            } else {
//                NSLog("no list attributed")
//            }
//
//            if note != nil {
//                // update old note
//                note = store.updateDailyVibesNote(withId: note?.uuid, withTitle: noteTitle, withContent: noteContent)
//            } else {
//                // new note time
//                note = store.storeDailyVibesNote(withTitle: self.noteTitle, withText: self.noteContent)
//            }
//
//            // TODO: REMOVE
////            note?.setValue(_todo, forKey: "todoItemTask")
////            _todo.setValue(note, forKey: "notes")
//
//
//            _todo.updatedAt = Date()
//            processTags(forTodo: _todo)
//            _todo.isNew = false
//
//            try context.save()
//
//            return true
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
        return true
    }
    
    func processCancel(in _context: NSManagedObjectContext) -> Bool {
        if !isNewTodo() {
            _context.rollback()
//            return true
        }
        return true
    }
    
    func addOrRemove(this _list:DVListViewModel) -> Bool {
        if contains(list: _list) {
            self.list = nil
            wasUpdated = true
        } else {
            self.list = store.findListVM(withUUID: _list.uuid)
            wasUpdated = true
        }
        return true
    }
    
    func addOrRemove(this _tag: DVTagViewModel) -> Bool {
        if contains(tag: _tag) {
            tags = tags.filter { tag in tag.uuid != _tag.uuid }
            wasUpdated = true
        } else {
            tags.append(DVTagViewModel.copyWithoutTagged(tag: _tag))
            wasUpdated = true
        }
        return true
    }
    
    func tagsCellIndexPath(equals indexPath: IndexPath) -> Bool {
        if indexPath.row == tagsCellIndexPath.row && indexPath.section == tagsCellIndexPath.section {
            return true
        }
        return false
    }
    
    // MARK: - Helpers
    
    func setTodoDueDate(at date: Date) -> Bool {
        data?.duedateAt = date
        return true
    }
    
    func contains(list _list:DVListViewModel) -> Bool {
        return self.list?.uuid == _list.uuid
    }
    
    func contains(tag _tag: DVTagViewModel) -> Bool {
        var found = false
        if tags.count > 0 {
            for tag in tags {
                if tag.uuid == _tag.uuid {
                    found = true
                    break
                }
            }
        }
        return found
    }
    
    func holdingAnyTags() -> Bool {
        return tags.count == 0
    }
    
    func getTagsLabels() -> String {
        return tagsString ?? ""
    }
    
    func isNewTodo() -> Bool {
        return data?.isNew ?? true
    }
    
    func getTodoCreatedAt() -> Date? {
        return data?.createdAt ?? Date()
    }
    
    func getTodoDuedateAt() -> Date? {
        return data?.duedateAt
    }
    
    func getTodoCompletedAt() -> Date? {
        return data?.completedAt
    }
    
    func getTodoArchivedAt() -> Date? {
        return data?.archivedAt
    }
    
    func setTodoText(to input: String) -> Bool {
        todoItemTaskLabel = input
        wasUpdated = true
        return true
    }
    
    func getTodoText() -> String {
        return todoItemTaskLabel ?? ""
    }
    
    func wasCompleted() -> Bool {
        return data?.isCompleted ?? false
    }
    
    func getTodoPlaceholderText() -> String {
        return taskPlaceholderText
    }
    
    func getNoteTitle() -> String {
        return self.noteTitle ?? ""
    }
    
    func getNoteText() -> String {
        return self.noteContent ?? ""
    }
    
    func getListLabel() -> String {
        return projectString ?? ""
    }
    
    func setTodoNoteText(title _title:String?, content _content: String?) -> Bool {
        self.noteTitle = _title ?? ""
        self.noteContent = _content ?? ""
        wasUpdated = true
        return true
    }
    
    func destroy() -> Bool {
        return store.destroyTodoItemTask(withUUID: getTodoItemTaskUUID())
    }
    
    func getTodoItemTaskUUID() -> UUID? {
        return data?.uuid
    }
}

fileprivate class OLDDVTodoItemViewModel {
    // used to hold the data for the screen...
    // no point in saving the data if someone clicks cancel
    var uuid: UUID?
    var string: String?
    var createdAt: Date?
    var duedateAt: Date?
    var updatedAt: Date?
    var completedAt: Date?
    var archivedAt: Date?
    var isNew: Bool = true
    var isCompleted: Bool = false
    var isArchived: Bool = false
    
    var createdAtEmotion: String?
    var updatedAtEmotion: String?
    var completedAtEmotion: String?
    
    init(dataFor todoItem:DVTodoItemTaskViewModel?) {
        if let todoItem = todoItem as DVTodoItemTaskViewModel? {
            self.uuid = todoItem.uuid
            self.string = todoItem.todoItemText
            self.createdAt = todoItem.createdAt
            self.duedateAt = todoItem.duedateAt
            self.updatedAt = todoItem.updatedAt
            self.completedAt = todoItem.completedAt
            self.archivedAt = todoItem.archivedAt
            self.isNew = todoItem.isNew
            self.isCompleted = todoItem.isCompleted
            self.isArchived = todoItem.isArchived
        } else {
            self.uuid = UUID.init()
            let curDate = Date()
            self.createdAt = curDate
            self.updatedAt = curDate
        }
    }
}
