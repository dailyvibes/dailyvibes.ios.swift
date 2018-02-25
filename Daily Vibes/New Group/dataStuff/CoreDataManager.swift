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
import UserNotifications

enum ItemDateSort : CustomStringConvertible {
    case createdAt
    case completedAt
    case archivedAt
    case duedateAt
    case updatedAt
    
    var description: String {
        switch self {
        case .createdAt:
            return "createdAt"
        case .completedAt:
            return "completedAt"
        case .archivedAt:
            return "archivedAt"
        case .duedateAt:
            return "duedateAt"
        case .updatedAt:
            return "updatedAt"
        }
    }
}

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
    
    var dvTodoItemTaskData = [DVCoreSectionViewModel]()
    var filteredDvTodoItemTaskData = [DVCoreSectionViewModel]()
    var dvTagsVM = [DVTagViewModel]()
    var dvListsVM = [DVListViewModel]()
    var dvNoteVM = [DVNoteViewModel]()
    
    func destroyALL(deleteExistingStore:Bool? = false) {
//        let deleteExistingStore = false
        let storeUrl = persistentContainer.persistentStoreCoordinator.persistentStores.first!.url!
        
        do {
            if let deleteExistingStore = deleteExistingStore, deleteExistingStore {
                try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeUrl, ofType: NSSQLiteStoreType, options: nil)
                persistentContainer = {
                    let container = CustomPersistantContainer(name: "DailyVibesModel")
                    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                        if let error = error as NSError? {
                            fatalError("Unresolved error \(error), \(error.userInfo)")
                        }
                    })
                    return container
                }()
            }
        } catch {
            fatalError("Error deleting store: \(error)")
        }
    }
    
    //    @objc dynamic public var duedateDaySectionIdentifier: String? {
    //        let currentCalendar = Calendar.current
    //        self.willAccessValue(forKey: "duedateDaySectionIdentifier")
    //        var sectionIdentifier = String()
    //
    //        if let date = self.duedateAt as Date? {
    //            let day = currentCalendar.component(.day, from: date)
    //            let month = currentCalendar.component(.month, from: date)
    //            let year = currentCalendar.component(.year, from: date)
    //
    //            // Construct integer from year, month, day. Convert to string.
    //            sectionIdentifier = "\(year * 10000 + month * 100 + day)"
    //        }
    //        self.didAccessValue(forKey: "duedateDaySectionIdentifier")
    //
    //        return sectionIdentifier
    //    }
    
    var editingDVTodotaskItem: DVTodoItemTaskViewModel?
    var dvfilter: DVSectionVMStatus = .all
    var filteredTag: DVTagViewModel?
    var filteredProjectList: DVListViewModel?
    
    func storeCustomCompletedTodoItemTask(title: String, createdAt: Date?, updatedAt: Date?, duedateAt: Date?, archivedAt: Date?, completedAt: Date) {
        let todoItemTask = TodoItem(context: context)
        
        let defaultListString = "Inbox"
        let defaultList = findDVList(byLabel: defaultListString)
        
        todoItemTask.todoItemText = title
        todoItemTask.id = UUID()
        todoItemTask.isNew = false
        
        todoItemTask.list = defaultList
        defaultList.addToListItems(todoItemTask)
        
        todoItemTask.completed = true
        todoItemTask.completedAt = completedAt
        
        todoItemTask.createdAt = createdAt ?? completedAt
        todoItemTask.updatedAt = updatedAt ?? completedAt
        todoItemTask.duedateAt = duedateAt ?? completedAt
        try! context.save()
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
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
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
    }
    
    func findTodoItemTask(withUUID uuid:UUID?) throws -> TodoItem {
        let todo: TodoItem?
        
        let fetchRequest = NSFetchRequest<TodoItem>(entityName: "TodoItem")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid! as CVarArg)
        todo = try context.fetch(fetchRequest).first as TodoItem!
        
        return todo!
    }
    
    func archiveTodoitemTask(task todoItemTask:DVTodoItemTaskViewModel) -> DVTodoItemTaskViewModel {
        do {
            let taskToArchive = try findTodoItemTask(withUUID: todoItemTask.uuid) as TodoItem
            
            let archivedListString = "Archived"
            let archivedList = findDVList(byLabel: archivedListString)
            
            taskToArchive.list = archivedList
            archivedList.addToListItems(taskToArchive)
            
            let curDate = Date()
            taskToArchive.setValue(true, forKey: "isArchived")
            taskToArchive.setValue(curDate, forKey: "updatedAt")
            taskToArchive.setValue(curDate, forKey: "archivedAt")
            try! context.save()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
            return DVTodoItemTaskViewModel.fromCoreData(todoItem: taskToArchive)
        } catch {
            return todoItemTask
        }
    }
    
    func completeTodoitemTask(task todoItemTask:DVTodoItemTaskViewModel) -> DVTodoItemTaskViewModel {
        do {
            let taskToArchive = try findTodoItemTask(withUUID: todoItemTask.uuid) as TodoItem
            let curDate = Date()
            
            taskToArchive.setValue(true, forKey: "completed")
            taskToArchive.setValue(curDate, forKey: "updatedAt")
            taskToArchive.setValue(curDate, forKey: "completedAt")
            try! context.save()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
            return DVTodoItemTaskViewModel.fromCoreData(todoItem: taskToArchive)
        } catch {
            return todoItemTask
        }
    }
    
    func destroyTodoItemTask(withUUID uuid:UUID?) -> Bool {
        do {
            let todo = try findTodoItemTask(withUUID: uuid!)
            
            context.delete(todo)
            saveContext()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func findTodoItemTaskVM(withUUID uuid:UUID?) -> DVTodoItemTaskViewModel? {
        do {
            let todo = try findTodoItemTask(withUUID: uuid!)
            return DVTodoItemTaskViewModel.fromCoreData(todoItem: todo)
        } catch {
            return nil
        }
    }
    
    func findNote(withUUID uuid:UUID?) throws -> DailyVibesNote {
        let note: DailyVibesNote?
        
        let fetchRequest = NSFetchRequest<DailyVibesNote>(entityName: "DailyVibesNote")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate.init(format: "uuid == %@", uuid! as CVarArg)
        note = try context.fetch(fetchRequest).first as DailyVibesNote!
        
        return note!
    }
    
    func findList(withUUID uuid:UUID?) throws -> DailyVibesList {
        let list: DailyVibesList?
        
        let fetchRequest = NSFetchRequest<DailyVibesList>(entityName: "DailyVibesList")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid! as CVarArg)
        list = try context.fetch(fetchRequest).first as DailyVibesList!
        
        return list!
    }
    // figure out why crash
    // titleText    String    "** DID NOT FIND Unsorted **"
    func findDVList(byLabel titleText:String) -> DailyVibesList {
        var list: DailyVibesList?
        
        do {
            let fetchRequest = NSFetchRequest<DailyVibesList>(entityName: "DailyVibesList")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "title == %@", titleText as CVarArg)
            list = try context.fetch(fetchRequest).first as DailyVibesList!
        } catch {
            list = nil
        }
        
        if list == nil {
            let defaultList = defaultDVListLabels()
            
            let translatedDefaultList = defaultList.map { listLabel in return NSLocalizedString(listLabel, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND \(listLabel) **", comment: "") }
            
            if translatedDefaultList.contains(titleText) {
                // translated string
                let indexOfString = translatedDefaultList.index(of: titleText)
                let originalString = defaultList[indexOfString!]
                
                makeDefaultDVList()
                list = findDVList(byLabel: originalString)
            } else {
                list = nil
            }
        }
        
        return list!
    }
    
    func findListVM(withUUID uuid:UUID) -> DVListViewModel? {
        do {
            let list = try findList(withUUID: uuid)
            return DVListViewModel.fromCoreData(list: list)
        } catch {
            return nil
        }
    }
    
    func findTagVM(withUUID uuid:UUID) -> DVTagViewModel? {
        do {
            let tag = try findTag(withUUID: uuid)
            return DVTagViewModel.fromCoreData(tag: tag)
        } catch {
            return nil
        }
    }
    
    func destroyList(withUUID uuid:UUID?) -> Bool {
        do {
            let list = try findList(withUUID: uuid!)
            
            context.delete(list)
            saveContext()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            fetchListsViewModel()
            
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func findTag(withUUID uuid:UUID?) throws -> Tag {
        let tag: Tag?
        
        let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate.init(format: "uuid == %@", uuid! as CVarArg)
        tag = try context.fetch(fetchRequest).first as Tag!
        
        return tag!
    }
    
    func destroyTag(withUUID uuid:UUID?) -> Bool {
        do {
            let tag = try findTag(withUUID: uuid!)
            
            context.delete(tag)
            saveContext()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            fetchTagsViewModel()
            
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func storeTodoItemTaskTag(withTitle title: String, forDueDate date: Date, for tag:Tag) {
        // FOR SHARE
        
        let defaultListString = "Unsorted"
        let defaultList = findDVList(byLabel: defaultListString)
        
        let todoItemTask = TodoItem(context: context)
        todoItemTask.id = UUID()
        let timeNow = Date()
        todoItemTask.isNew = false
        todoItemTask.createdAt = timeNow
        todoItemTask.updatedAt = timeNow
        todoItemTask.todoItemText = title
        todoItemTask.duedateAt = date
        
        todoItemTask.list = defaultList
        defaultList.addToListItems(todoItemTask)
        
        tag.addToTodos(todoItemTask)
        
        try! context.save()
        
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
    }
    
    func storeTag(withLabel title: String) -> Tag {
        let tag = Tag(context: context)
        tag.label = title
        tag.uuid = UUID.init()
        let currDate = Date()
        tag.createdAt = currDate
        tag.updatedAt = currDate
        saveContext()
        return tag
    }
    
    func createTag(withLabel title: String) -> DVTagViewModel {
        let tag = storeTag(withLabel: title)
        
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
        fetchTagsViewModel()
        
        return DVTagViewModel.fromCoreData(tag: tag)
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
        
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
        
        return newList
    }
    
    func hasDefaultDVList() -> Bool {
        let defaultListsCount = defaultDVListLabels().count
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesList")
        fetchRequest.predicate = NSPredicate(format: "isDVDefault = YES")
        
        let count = try? context.count(for: fetchRequest)
        
        return count == defaultListsCount
    }
    
    func defaultDVListLabels() -> [String] {
        var defaultLists = [String]()
        
        defaultLists.append("Inbox")
        defaultLists.append("Today")
        defaultLists.append("This week")
        defaultLists.append("Archived")
        defaultLists.append("Unsorted")
        
        //        defaultLists.append(NSLocalizedString("Inbox", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Inbox **", comment: ""))
        //        defaultLists.append(NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today **", comment: ""))
        //        defaultLists.append(NSLocalizedString("This week", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This week **", comment: ""))
        //        defaultLists.append(NSLocalizedString("Archived", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archived **", comment: ""))
        //        defaultLists.append(NSLocalizedString("Unsorted", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Unsorted **", comment: ""))
        
        return defaultLists
    }
    
    func makeDefaultDVList() {
        let defaultLists = defaultDVListLabels()
        
        for defaultDVList in defaultLists {
            let title = defaultDVList
            let newList = DailyVibesList(context: context)
            let curDate = Date()
            
            newList.uuid = UUID.init()
            newList.version = 1
            newList.versionId = UUID.init()
            newList.versionPrevId = nil
            newList.title = title
            newList.isDVDefault = true
            newList.createdAt = curDate
            newList.updatedAt = curDate
            
            saveContext()
        }
    }
    
    func createProject(withTitle title: String, withDescription titleDescription: String?) -> DVListViewModel {
        let newProject = storeDailyVibesList(withTitle: title, withDescription: titleDescription)
        return DVListViewModel.fromCoreData(list: newProject)
    }
    
    func storeDailyVibesNote(withTitle title:String?, withText content:String?) -> DVNoteViewModel {
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
        
        // TODO - workaround
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
        
        return DVNoteViewModel.fromCoreData(note: newNote)
    }
    
    func updateDailyVibesNote(withId id:UUID?, withTitle title:String?, withContent content:String?) -> DVNoteViewModel {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesNote")
        var result: DVNoteViewModel?
        
        do {
            // try to fetch by id...
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", id! as CVarArg)
            fetchRequest.fetchLimit = 1
            
            let note: DailyVibesNote?
            note = try context.fetch(fetchRequest).first as? DailyVibesNote
            note?.title = title
            note?.content = content
            
            let curDate = Date()
            
            note?.updatedAt = curDate
            saveContext()
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
            result = DVNoteViewModel.fromCoreData(note: note!)
        } catch {
            // apparently we did not find it... that is okay just make a new note then
            let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
            NSLog("for some reason failed to find note with id \(String(describing: id ?? fallbackString))")
            
            result = self.storeDailyVibesNote(withTitle: title, withText: content)
        }
        
        return result!
    }
    
    func getTodoItemTasks(ascending: Bool = false, itemDateSort: ItemDateSort = .createdAt) -> [DVTodoItemTaskViewModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
        
        let customItemDateSort = NSSortDescriptor(key: itemDateSort.description, ascending: ascending)
        
        fetchRequest.sortDescriptors = [customItemDateSort]
        
        do {
            guard let tasks = try context.fetch(fetchRequest) as? [TodoItem] else { return nil }
            return tasks.flatMap { DVTodoItemTaskViewModel.fromCoreData(todoItem: $0) }
        } catch {
            return nil
        }
    }
    
    func processMultipleTodoitemTasks(forProject: DVListViewModel, todoItemTasksData: DVMultipleTodoitemtaskItemsVM) {
        do {
            let curDate = Date()
            
            for (_, element) in todoItemTasksData.parsedText!.enumerated() {
                
                let titleText = element.split(separator: "#")
                let tags = titleText.dropFirst()
                let title = titleText.first
                
                let todo = TodoItem(context: context)
                todo.id = UUID.init()
                let problem = String(describing: title!)
                
                todo.todoItemText = "\(problem)"
                
                todo.isNew = false
                todo.createdAt = curDate
                todo.updatedAt = curDate
                todo.duedateAt = todoItemTasksData.duedateAt
                
                if todoItemTasksData.hasTags {
                    
                    for (_, element) in tags.enumerated() {
                        if let tag = fetchSpecificTag(byLabel: String(element)) {
                            // tags exists
                            todo.addToTags(tag)
                            tag.addToTodos(todo)
                        } else {
                            // need to create a tag
                            let newTag = createTag(withLabel: String(element))
                            if let tag = fetchSpecificTag(byLabel: newTag.label) {
                                todo.addToTags(tag)
                                tag.addToTodos(todo)
                            }
                        }
                    }
                }
                
                if todoItemTasksData.isRemindable {
                    
                    if let duedateAt = todoItemTasksData.duedateAt {
                        todo.isRemindable = todoItemTasksData.isRemindable
                        
                        let content = UNMutableNotificationContent()
                        content.title = NSLocalizedString("Reminder", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reminder **", comment: "")
                        content.body = todo.todoItemText!
                        content.sound = UNNotificationSound.default()
                        
                        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: duedateAt)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                                    repeats: false)
                        
                        if let uuid = todo.id {
                            let identifier = "UYLLocalNotification-\(uuid)"
                            let center = UNUserNotificationCenter.current()
                            let request = UNNotificationRequest(identifier: identifier,
                                                                content: content, trigger: trigger)
                            center.add(request, withCompletionHandler: { (error) in
                                if error != nil {
                                    // Something went wrong
                                    print("We had an error in processMultipleTodoitemTasks")
                                }
                            })
                        }
                    }
                }
                
                let list = try findList(withUUID: todoItemTasksData.curProject?.uuid)
                todo.list = list
                list.addToListItems(todo)
                try! context.save()
            }
            
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
        } catch {
            fatalError("failed on processMultipleTodoitemTasks")
        }
    }
    
    func saveEditingDVTodotaskItem() {
        if let editingTodoitemTask = editingDVTodotaskItem {
            do {
                let placeholderUUIDString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
                
                if editingTodoitemTask.isNew {
                    // process a new todo
                    let todo = TodoItem(context: context)
                    todo.id = UUID.init()
                    todo.todoItemText = editingTodoitemTask.todoItemText
                    
                    let curDate = Date()
                    
                    todo.isNew = false
                    todo.createdAt = curDate
                    todo.updatedAt = curDate
                    todo.duedateAt = editingTodoitemTask.duedateAt
                    todo.completedAt = editingTodoitemTask.completedAt
                    
                    if let hasTags = editingTodoitemTask.tags {
                        let incomingTagsUUID = hasTags.map { tag in tag.uuid }
                        
                        for uuid in incomingTagsUUID {
                            let tag = try findTag(withUUID: uuid)
                            todo.addToTags(tag)
                            tag.addToTodos(todo)
                        }
                    }
                    
                    if let hasList = editingTodoitemTask.list {
                        let list = try findList(withUUID: hasList.uuid)
                        todo.list = list
                        list.addToListItems(todo)
                    }
                    
                    if let isRemindable = editingTodoitemTask.isRemindable, isRemindable {
                        
                        if let duedateAt = editingTodoitemTask.duedateAt {
                            todo.isRemindable = isRemindable
                            
                            let content = UNMutableNotificationContent()
                            content.title = NSLocalizedString("Reminder", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reminder **", comment: "")
                            content.body = todo.todoItemText!
                            content.sound = UNNotificationSound.default()
                            
                            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: duedateAt)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                                        repeats: false)
                            
                            
                            if let uuid = todo.id {
                                let identifier = "UYLLocalNotification-\(uuid)"
                                let center = UNUserNotificationCenter.current()
                                let request = UNNotificationRequest(identifier: identifier,
                                                                    content: content, trigger: trigger)
                                center.add(request, withCompletionHandler: { (error) in
                                    if error != nil {
                                        // Something went wrong
                                        print("We had an error in saveEditingDVTodotaskItem")
                                    }
                                })
                            }
                        }
                    }
                    
                    if let hasNote = editingTodoitemTask.note {
                        if hasNote.uuid == placeholderUUIDString {
                            // new note
                            let newNote = DailyVibesNote(context: context)
                            
                            newNote.uuid = UUID.init()
                            newNote.version = 0
                            newNote.versionId = UUID.init()
                            newNote.versionPrevId = nil
                            newNote.title = hasNote.title
                            newNote.content = hasNote.content
                            newNote.createdAt = curDate
                            newNote.updatedAt = curDate
                            
                            todo.notes = newNote
                            newNote.todoItemTask = todo
                        } else {
                            // old note
                            let note = try findNote(withUUID: hasNote.uuid)
                            note.updatedAt = curDate
                            note.title = hasNote.title
                            note.content = hasNote.content
                            todo.notes = note
                            note.todoItemTask = todo
                        }
                    }
                } else {
                    // process an existing todo
                    
                    let todo = try findTodoItemTask(withUUID: editingTodoitemTask.uuid)
                    
                    let curDate = Date()
                    
                    todo.updatedAt = curDate
                    todo.duedateAt = editingTodoitemTask.duedateAt
                    todo.completedAt = editingTodoitemTask.completedAt
                    todo.todoItemText = editingTodoitemTask.todoItemText
                    
                    if let hasTags = editingTodoitemTask.tags {
                        let incomingTagsUUID = hasTags.map { tag in tag.uuid }
                        
                        if incomingTagsUUID.count == 0 {
                            // TODO FIX THIS IN NEXT ITERATION
                            // want to actually walk through each tag and remove the relationshp
                            todo.setValue(nil, forKey: "tags")
                        } else {
                            todo.setValue(nil, forKey: "tags")
                            
                            for uuid in incomingTagsUUID {
                                let tag = try findTag(withUUID: uuid)
                                todo.addToTags(tag)
                                tag.addToTodos(todo)
                            }
                        }
                    }
                    
                    if let hasList = editingTodoitemTask.list {
                        let list = try findList(withUUID: hasList.uuid)
                        todo.list = list
                        list.addToListItems(todo)
                    }
                    
                    if let isRemindable = editingTodoitemTask.isRemindable, isRemindable {
                        
                        if let duedateAt = editingTodoitemTask.duedateAt {
                            todo.isRemindable = isRemindable
                            
                            let content = UNMutableNotificationContent()
                            content.title = NSLocalizedString("Reminder", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reminder **", comment: "")
                            content.body = todo.todoItemText!
                            content.sound = UNNotificationSound.default()
                            
                            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: duedateAt)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                                        repeats: false)
                            
                            if let uuid = todo.id {
                                let identifier = "UYLLocalNotification-\(uuid)"
                                let center = UNUserNotificationCenter.current()
                                let request = UNNotificationRequest(identifier: identifier,
                                                                    content: content, trigger: trigger)
                                center.add(request, withCompletionHandler: { (error) in
                                    if error != nil {
                                        // Something went wrong
                                        print("We had an error in saveEditingDVTodotaskItem")
                                    }
                                })
                            }
                        }
                    }
                    
                    if let hasNote = editingTodoitemTask.note {
                        if hasNote.uuid == placeholderUUIDString {
                            // new note
                            let newNote = DailyVibesNote(context: context)
                            
                            newNote.uuid = UUID.init()
                            newNote.version = 0
                            newNote.versionId = UUID.init()
                            newNote.versionPrevId = nil
                            newNote.title = hasNote.title
                            newNote.content = hasNote.content
                            newNote.createdAt = curDate
                            newNote.updatedAt = curDate
                            
                            todo.notes = newNote
                            newNote.todoItemTask = todo
                        } else {
                            // old note
                            let note = try findNote(withUUID: hasNote.uuid)
                            note.updatedAt = curDate
                            note.title = hasNote.title
                            note.content = hasNote.content
                            todo.notes = note
                            note.todoItemTask = todo
                        }
                    }
                    
                }
                
                saveContext()
                editingDVTodotaskItem = nil
                
                // TODO - workaround
                self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
                
            } catch {
                fatalError("failed on saveEditingDVTodotaskItem")
            }
        }
    }
    
    func findOrCreateTodoitemTaskDeepNested(withUUID _uuid:UUID?) {
        let defaultListString = "Inbox"
        
        let defaultList = DVListViewModel.fromCoreData(list: findDVList(byLabel: defaultListString))
        
        if let uuid = _uuid as UUID! {
            do {
                let foundTodo = try findTodoItemTask(withUUID: uuid)
                let foundTodoVM = DVTodoItemTaskViewModel.fromCoreData(todoItem: foundTodo)
                
                // map tags
                if let hasTags = foundTodo.tags?.allObjects as? [Tag] {
                    foundTodoVM.tags = hasTags.map { tag in DVTagViewModel.fromCoreData(tag: tag) }
                }
                
                // map notes
                if let hasNote = foundTodo.notes {
                    let tempNote = DVNoteViewModel.fromCoreData(note: hasNote)
                    foundTodoVM.note = tempNote
                }
                
                // map lists
                if let hasProjectList = foundTodo.list {
                    let tempList = DVListViewModel.fromCoreData(list: hasProjectList)
                    foundTodoVM.list = tempList
                } else {
                    foundTodoVM.list = defaultList
                }
                
                self.editingDVTodotaskItem = foundTodoVM
            } catch {
                let empty = DVTodoItemTaskViewModel.makeEmpty()
                empty.list = defaultList
                self.editingDVTodotaskItem = empty
            }
        } else {
            let empty = DVTodoItemTaskViewModel.makeEmpty()
            empty.list = defaultList
            self.editingDVTodotaskItem = empty
        }
    }
    
    func filterDvTodoItemTaskData(by filter:DVSectionVMStatus) {
        switch filter {
        case .all:
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .all
                return section
            })
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        case .completed:
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .completed
                return section
            })
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        case .upcoming:
            // TODO - workaround
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .upcoming
                return section
            })
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        }
    }
    
    func filterFilteredDvTodoItemTaskData(by filter:DVSectionVMStatus) {
        switch filter {
        case .all:
            let temp = self.filteredDvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .all
                return section
            })
            self.filteredDvTodoItemTaskData = temp
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        case .completed:
            let temp = self.filteredDvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .completed
                return section
            })
            self.filteredDvTodoItemTaskData = temp
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        case .upcoming:
            let temp = self.filteredDvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                section.filterStatus = .upcoming
                return section
            })
            self.filteredDvTodoItemTaskData = temp
            self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
        }
    }
    
    func filterDvTodoItemTaskDataByTag() {
        
        self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
        self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
            var todoitemTaskHolder = [DVTodoItemTaskViewModel]()
            
            for todoItemTask in section.allObjects {
                
                if let tags = todoItemTask.tags, tags.count > 0 {
                    for tag in tags {
                        if tag.uuid == filteredTag?.uuid {
                            todoitemTaskHolder.append(todoItemTask)
                            break
                        }
                    }
                }
            }
            
            section.allObjects = todoitemTaskHolder
            
            return section
        })
        
        self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
    }
    
    func filterDvTodoItemTaskDataByList() {
        
        if filteredProjectList?.title == "Today" {
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false, itemDateSort: .duedateAt)!
            
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                var todoitemTaskHolder = [DVTodoItemTaskViewModel]()
                
                todoitemTaskHolder = section.allObjects.filter({ (todoItemTask) -> Bool in
                    if let dueDate = todoItemTask.duedateAt, dueDate.isInToday {
                        return true
                    } else if todoItemTask.list?.uuid == filteredProjectList?.uuid {
                        return true
                    } else {
                        return false
                    }
                })
                
                section.allObjects = todoitemTaskHolder
                
                return section
            })
        } else if filteredProjectList?.title == "This week" {
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false, itemDateSort: .duedateAt)!
            
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                var todoitemTaskHolder = [DVTodoItemTaskViewModel]()
                
                todoitemTaskHolder = section.allObjects.filter({ (todoItemTask) -> Bool in
                    if let dueDate = todoItemTask.duedateAt, dueDate.isInThisWeek {
                        return true
                    } else if todoItemTask.list?.uuid == filteredProjectList?.uuid {
                        return true
                    } else {
                        return false
                    }
                    //                    if let dueDate = todoItemTask.duedateAt, dueDate.isInThisWeek {
                    //                        return true
                    //                    } else if let dueDate = todoItemTask.duedateAt, dueDate.isInThePast {
                    //                        return true
                    //                    } else if todoItemTask.list?.uuid == filteredProjectList?.uuid {
                    //                        return true
                    //                    } else {
                    //                        return false
                    //                    }
                })
                
                section.allObjects = todoitemTaskHolder
                
                return section
            })
        } else {
            self.dvTodoItemTaskData = getGroupedTodoItemTasks(ascending: false)!
            
            self.filteredDvTodoItemTaskData = self.dvTodoItemTaskData.map({ (section) -> DVCoreSectionViewModel in
                var todoitemTaskHolder = [DVTodoItemTaskViewModel]()
                
                todoitemTaskHolder = section.allObjects.filter({ (todoItemTask) -> Bool in
                    return todoItemTask.list?.uuid == filteredProjectList?.uuid
                })
                
                section.allObjects = todoitemTaskHolder
                
                return section
            })
        }
        
        self.filteredDvTodoItemTaskData = self.filteredDvTodoItemTaskData.filter { section in section.sectionCount() > 0 }
    }
    
    func getGroupedTodoItemTasks(ascending: Bool = false, itemDateSort:ItemDateSort = .createdAt) -> [DVCoreSectionViewModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
        
        let dateSortAt = NSSortDescriptor(key: itemDateSort.description, ascending: ascending)
        
        fetchRequest.sortDescriptors = [dateSortAt]
        
        do {
            var controller: NSFetchedResultsController<NSFetchRequestResult>
            
            switch itemDateSort {
            case .createdAt:
                controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "inboxDaySectionIdentifier", cacheName: nil)
            case .completedAt:
                controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "doneDaySectionIdentifier", cacheName: nil)
            case .archivedAt:
                controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "archivedDaySectionIdentifier", cacheName: nil)
            case .duedateAt:
                controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "duedateDaySectionIdentifier", cacheName: nil)
            case .updatedAt:
                controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "inboxDaySectionIdentifier", cacheName: nil)
            }
            
            try controller.performFetch()
            
            guard let sections = controller.sections else { return nil }
            
            dvTodoItemTaskData.removeAll()
            
            sections.forEach({ (sectionInfo) in
                let dvModel = DVCoreSectionViewModel.init(sectionIdentifier: sectionInfo.name, sectionCount: sectionInfo.numberOfObjects, indexTitle: sectionInfo.indexTitle)
                if let tasks = sectionInfo.objects as? [TodoItem] {
                    let transformedTasks = tasks.flatMap { (todoItemTask) -> DVTodoItemTaskViewModel in
                        let transformedDVTodoItemTask = DVTodoItemTaskViewModel.fromCoreData(todoItem: todoItemTask)
                        
                        if let numTags = todoItemTask.tags?.count, numTags > 0 {
                            if let tags = todoItemTask.tags?.allObjects as? [Tag] {
                                let transformedDVTagsForTodoItemTask = tags.flatMap({ (tag) -> DVTagViewModel? in
                                    let transformedDVTag = DVTagViewModel.fromCoreData(tag: tag)
                                    transformedDVTag.tagged.append(transformedDVTodoItemTask)
                                    return transformedDVTag
                                })
                                transformedDVTodoItemTask.tags = transformedDVTagsForTodoItemTask
                            }
                        }
                        
                        if let project = todoItemTask.list {
                            let transformedDVListForTodoItemTask = DVListViewModel.fromCoreData(list: project)
                            transformedDVListForTodoItemTask.listItems?.append(transformedDVTodoItemTask)
                            transformedDVTodoItemTask.list = transformedDVListForTodoItemTask
                        }
                        
                        if let note = todoItemTask.notes {
                            let transformedDVNoteForTodoItemTask = DVNoteViewModel.fromCoreData(note: note)
                            transformedDVNoteForTodoItemTask.attachedTo = transformedDVTodoItemTask
                            transformedDVTodoItemTask.note = transformedDVNoteForTodoItemTask
                        }
                        
                        return transformedDVTodoItemTask
                    }
                    dvModel.allObjects.append(contentsOf: transformedTasks)
                }
                _ = dvTodoItemTaskData.append(dvModel)
            })
            
            return dvTodoItemTaskData
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
    
    func fetchTagsViewModel() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        let result = try! context.fetch(fetchRequest) as! [Tag]
        self.dvTagsVM = result.flatMap({ (tag) -> DVTagViewModel? in
            return DVTagViewModel.fromCoreData(tag: tag)
        })
    }
    
    func fetchListsViewModel() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesList")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        let result = try! context.fetch(fetchRequest) as! [DailyVibesList]
        self.dvListsVM = result.flatMap({ (list) -> DVListViewModel? in
            return DVListViewModel.fromCoreData(list: list)
        })
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
    
    func fetchSpecificDVProjectlist(byLabel title:String) -> DailyVibesList? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyVibesList")
        
        if let count = try! context.count(for: fetchRequest) as Int?, count > 0 {
            
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            
            if let tags = try? context.fetch(fetchRequest) as? [DailyVibesList] {
                let resultantList = tags?.first as DailyVibesList?
                
                if resultantList != nil  {
                    return resultantList!
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

