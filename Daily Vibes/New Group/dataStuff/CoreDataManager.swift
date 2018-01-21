//
//  CoreDataManager.swift
//  Daily Vibes
//
// taken from https://raw.githubusercontent.com/almusto/CustomNotes/master/CustomNotes/CoreDataStack.swift
//
//  Created by Alex Kluew on 2018-01-07.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation
import CoreData


final class CoreDataManager {
    
    static let store = CoreDataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var fetchedStreaks = [Streak]()
    var fetchedTags = [Tag]()
    var fetchedLists = [DailyVibesList]()
    var fetchedNotes = [DailyVibesNote]()
    var fetchedCompletedTodos = [TodoItem]()
    
    func storeCustomCompletedTodoItemTask(title: String, createdAt: Date?, updatedAt: Date?, duedateAt: Date?, archivedAt: Date?, completedAt: Date) {
        let todoItemTask = TodoItem(context: context)
        todoItemTask.todoItemText = title
        todoItemTask.id = UUID()
        todoItemTask.isNew = false
        
        todoItemTask.completed = true
        todoItemTask.completedAt = completedAt
        
        todoItemTask.createdAt = createdAt ?? completedAt
        todoItemTask.updatedAt = updatedAt ?? completedAt
        todoItemTask.duedateAt = duedateAt ?? completedAt
        try! context.save()
    }
    
    func storeTodoItemTask(withTitle title: String, forDueDate date: Date) {
        let todoItemTask = TodoItem(context: context)
        todoItemTask.id = UUID()
        let timeNow = Date()
        todoItemTask.isNew = false
        todoItemTask.createdAt = timeNow
        todoItemTask.updatedAt = timeNow
        todoItemTask.todoItemText = title
        todoItemTask.duedateAt = date
        try! context.save()
    }
    
    func findTodoItemTask(withUUID uuid:UUID?) throws -> TodoItem {
        let todo: TodoItem?

        let fetchRequest = NSFetchRequest<TodoItem>(entityName: "TodoItem")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid! as CVarArg)
        todo = try context.fetch(fetchRequest).first as TodoItem!

        return todo!
    }
    
    func destroyTodoItemTask(withUUID uuid:UUID?) -> Bool {
        do {
            let todo = try findTodoItemTask(withUUID: uuid!)
            
            context.delete(todo)
            saveContext()
            
            return true
        } catch {
            context.rollback()
            
            return false
        }
    }
    
    func storeTodoItemTaskTag(withTitle title: String, forDueDate date: Date, for tag:Tag) {
        let todoItemTask = TodoItem(context: context)
        todoItemTask.id = UUID()
        let timeNow = Date()
        todoItemTask.isNew = false
        todoItemTask.createdAt = timeNow
        todoItemTask.updatedAt = timeNow
        todoItemTask.todoItemText = title
        todoItemTask.duedateAt = date
        tag.addToTodos(todoItemTask)
        try! context.save()
    }
    
    func storeTag(withLabel title: String) -> Tag {
        let tag = Tag(context: context)
        tag.label = title
        tag.uuid = UUID.init()
        tag.createdAt = Date()
        tag.updatedAt = Date()
        saveContext()
        return tag
    }
    
    func storeDailyVibesList(withTitle title:String, withDescription titleDescription:String?) -> DailyVibesList {
        let newList = DailyVibesList(context: context)
        let curDate = Date()
        
        newList.uuid = UUID.init()
        newList.version = 0
        newList.versionId = UUID.init()
        newList.versionPrevId = nil
        newList.title = title
        newList.titleDescription = titleDescription
        newList.createdAt = curDate
        newList.updatedAt = curDate
        
        saveContext()
        
        return newList
    }
    
    func storeDailyVibesNote(withTitle title:String?, withText content:String?) -> DailyVibesNote {
        let newNote = DailyVibesNote(context: context)
        let curDate = Date()
        
        newNote.uuid = UUID.init()
        newNote.version = 0
        newNote.versionId = UUID.init()
        newNote.versionPrevId = nil
        newNote.title = title
        newNote.content = content
        newNote.createdAt = curDate
        newNote.updatedAt = curDate
        
        saveContext()
        
        return newNote
    }
    
    func updateDailyVibesNote(withId id:UUID?, withTitle title:String?, withContent content:String?) -> DailyVibesNote {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesNote")
        var note: DailyVibesNote?
        
        do {
            // try to fetch by id...
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", id! as CVarArg)
            fetchRequest.fetchLimit = 1

            note = try context.fetch(fetchRequest).first as? DailyVibesNote
            note?.title = title
            note?.content = content
            
            let curDate = Date()
            
            note?.updatedAt = curDate
            saveContext()
        } catch {
            // apparently we did not find it... that is okay just make a new note then
            let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
            NSLog("for some reason failed to find note with id \(String(describing: id ?? fallbackString))")
            
            note = self.storeDailyVibesNote(withTitle: title, withText: content)
        }
        
        return note!
    }
    
    func getTodoItemTasks(ascending: Bool = false) -> [DVTodoItemTaskViewModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
        let completedAt = NSSortDescriptor(key: "createdAt", ascending: ascending)
        
        fetchRequest.sortDescriptors = [completedAt]
        
        do {
            guard let users = try context.fetch(fetchRequest) as? [TodoItem] else { return nil }
            return users.flatMap { DVTodoItemTaskViewModel.fromCoreData(todoItem: $0) }
        } catch {
            return nil
        }
    }
    
    func getCompletedTodoItemTasks(ascending: Bool = false) -> [DVTodoItemTaskViewModel]? {
        let all = getTodoItemTasks(ascending: ascending)
        let result = all?.filter { todoItem in
            return todoItem.isCompleted == true
        }
        return result
    }
    
    func fetchCompletedDailyVibesTodoItems() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
        let completedAt = NSSortDescriptor(key: "completedAt", ascending: false)
        fetchRequest.sortDescriptors = [completedAt]
        self.fetchedCompletedTodos = try! context.fetch(fetchRequest) as! [TodoItem]
    }
    
    func fetchDailyVibesLists() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesList")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        self.fetchedLists = try! context.fetch(fetchRequest) as! [DailyVibesList]
    }
    
    func fetchDailyVibesNotes() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesNote")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        self.fetchedNotes = try! context.fetch(fetchRequest) as! [DailyVibesNote]
    }
    
    func fetchTags() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        self.fetchedTags = try! context.fetch(fetchRequest) as! [Tag]
    }
    
    func fetchStreaks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        self.fetchedStreaks = try! context.fetch(fetchRequest) as! [Streak]
    }
    
    func getTodoItemTaskCount() -> Int? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
        
        let count = try? context.count(for: fetchRequest)
        
        return count
    }
    
    func fetchSpecificTag(byLabel title:String) -> Tag? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        
        if let count = try! context.count(for: fetchRequest) as Int?, count > 0 {
            
            fetchRequest.predicate = NSPredicate(format: "label == %@", title)
            
            if let tags = try? context.fetch(fetchRequest) as? [Tag] {
                let resultantTag = tags?.first as Tag?
                
                if resultantTag != nil  {
                    return resultantTag!
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    //    func delete(note: Note) {
    //        context.delete(note)
    //        try! context.save()
    //    }
    
    
    lazy var persistentContainer: CustomPersistantContainer = {
        let container = CustomPersistantContainer(name: "DailyVibesModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


class CustomPersistantContainer : NSPersistentContainer {
    
    static let groupName = "group.com.sugarplumoriginals.dailyvibes.shared"
    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}

