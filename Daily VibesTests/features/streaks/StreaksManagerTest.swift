////
////  StreaksManagerTest.swift
////  Daily VibesTests
////
////  Created by Alex Kluew on 2017-12-21.
////  Copyright © 2017 Alex Kluew. All rights reserved.
////
//
//import XCTest
//import CoreData
//@testable import Daily_Vibes
//
//class StreaksManagerTest: XCTestCase {
//    var streakManager: StreakManager!
//    
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
//        return managedObjectModel
//    }()
//    
//    lazy var mockPersistantContainer: NSPersistentContainer = {
//        
//        let container = NSPersistentContainer(name: "PersistentContainer", managedObjectModel: self.managedObjectModel)
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType
//        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
//        
//        container.persistentStoreDescriptions = [description]
//        container.loadPersistentStores { (description, error) in
//            // Check if the data store is in memory
//            precondition( description.type == NSInMemoryStoreType )
//            
//            // Check if creating container wrong
//            if let error = error {
//                fatalError("Create an in-mem coordinator failed \(error)")
//            }
//        }
//        return container
//    }()
//    
//    override func setUp() {
//        super.setUp()
//        initStubs()
//        streakManager = StreakManager.init(container: mockPersistantContainer)
//    }
//    
//    override func tearDown() {
//        flushData()
//        super.tearDown()
//    }
//    
//    func initStubs() {
//        
//        func insertTodoItem() -> TodoItem? {
////            let obj = NSEntityDescription.insertNewObject(forEntityName: "TodoItem", into: mockPersistantContainer.viewContext)
//            let ctx: NSManagedObjectContext = mockPersistantContainer.viewContext
//            let obj = TodoItem.createTodoItem(in: ctx)
//            let todoItemText: String = "What would you like to do?"
//            let timeNow = Date()
//            
//            obj.setValue(UUID.init(), forKey: "id")
//            obj.setValue(todoItemText, forKey: "todoItemText")
//            obj.setValue(timeNow, forKey: "createdAt")
//            obj.setValue(timeNow, forKey: "updatedAt")
//            obj.setValue(false, forKey: "completed")
//            obj.setValue(false, forKey: "isArchived")
//            obj.setValue(true, forKey: "isNew")
//            
////            return obj as? TodoItem
//            return obj
//        }
//        
//        for _ in 0..<10 {
//            let _ = insertTodoItem()
//        }
//        
//        do {
//            try mockPersistantContainer.viewContext.save()
//        }  catch {
//            print("create fakes error \(error)")
//        }
//        
//    }
//    
//    private func flushTodoItemData() {
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
//        
//        for case let obj as NSManagedObject in objs {
//            mockPersistantContainer.viewContext.delete(obj)
//        }
//        try! mockPersistantContainer.viewContext.save()
//    }
//    
//    private func flushStreakData() {
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
//        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
//        
//        for case let obj as NSManagedObject in objs {
//            mockPersistantContainer.viewContext.delete(obj)
//        }
//        try! mockPersistantContainer.viewContext.save()
//    }
//    
//    func flushData() {
//        
//        flushTodoItemData()
//        flushStreakData()
//        
//    }
//    
//    func testThatEverythingIsWiredUp() {
//        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        let todos = try! mockPersistantContainer.viewContext.fetch(request)
//        
//        XCTAssertEqual(todos.count, 10)
//    }
//    
//    func testInitialStreakLoad() {
//        let actualStreaks = streakManager.fetchAll()
//        let actualStreakCount = actualStreaks.count
//        let expectedStreakCount = 0
//        
//        XCTAssertEqual(actualStreakCount, expectedStreakCount, "should have no streaks")
//    }
//    
//    func testInitialStreakCreation() {
//        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
//        
//        let results = try! mockPersistantContainer.viewContext.fetch(request)
//        let randomTodo = results.first as! TodoItem
//        let timeNow = Date()
//        
//        randomTodo.setValue(false, forKey: "isNew")
//        randomTodo.setValue(true, forKey: "completed")
//        randomTodo.setValue(timeNow, forKey: "completedAt")
//        randomTodo.setValue(timeNow, forKey: "updatedAt")
//
//        let actualResult = streakManager.process(item: randomTodo)
//
//        let actualStreaks = streakManager.fetchAll()
//        let actualStreakCount = actualStreaks.count
//        let actualStreakTodosCount = actualStreaks.first?.todos?.count
//
//        XCTAssertTrue(actualResult, "expecting streakManager to successfully process the first todo")
//        XCTAssertEqual(actualStreakCount, 1, "should only have 1 streak")
//        XCTAssertEqual(actualStreakTodosCount, 1, "should only have 1 todo added")
//    }
//    
//    func testAddingTodoSameDayStreakCreation() {
//        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
//        let results = try! mockPersistantContainer.viewContext.fetch(request)
//
//        for case let todo as TodoItem in results {
//            let timeNow = Date()
//            
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(timeNow, forKey: "completedAt")
//            todo.setValue(timeNow, forKey: "updatedAt")
//            
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//
//        let actualStreaks = streakManager.fetchAll()
//        let actualStreakCount = actualStreaks.count
//        let actualStreakTodosCount = actualStreaks.first?.todos?.count
//
//        //        XCTAssertTrue(actualResult, "expecting streakManager to successfully process the first todo")
//        XCTAssertEqual(actualStreakCount, 1, "should only have 1 streak")
//        XCTAssertEqual(actualStreakTodosCount, 10, "should only have 1 todo added")
//    }
//    
//    func testYesterdayAndTodayStreak() {
//        let ctx: NSManagedObjectContext = mockPersistantContainer.viewContext
//        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        let results = try! mockPersistantContainer.viewContext.fetch(request)
//        
//        let firstTodo = results.first as! TodoItem
//        let timeNow = Date()
//        let firstTodoCreationDate = firstTodo.createdAt!
//        let yesterday = firstTodoCreationDate.subtract(days: 1)
//        
//        let TODO_CONST_1 = 7
//        let TODO_CONST_2 = 10
//        let CONST_DIFF = TODO_CONST_2 - TODO_CONST_1
//
//        for index in 0..<TODO_CONST_1 {
//            let todo = results[index] as! TodoItem
//            
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(timeNow, forKey: "completedAt")
//            todo.setValue(timeNow, forKey: "updatedAt")
//            
//            try! ctx.save()
//            
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//        
//        let actualStreaks = streakManager.fetchAll()
//        let actualStreakCount = actualStreaks.count
//        
//        let currentStreak = actualStreaks.first
//        let actualStreakTodosCount = currentStreak?.todos?.count
//        let todaysStreakDate = currentStreak?.createdAt
//        
//        XCTAssertEqual(actualStreakCount, 1, "should have 1 streaks")
//        XCTAssertEqual(actualStreakTodosCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to latest streak")
//        XCTAssertEqual(timeNow, todaysStreakDate, "date should be set to today")
//        XCTAssertEqual(currentStreak?.currentDaysInARow, 1, "should have 1 days in a row")
//        XCTAssertEqual(currentStreak?.recordDaysInARow, 1, "should have 1 record days in a row")
//        XCTAssertEqual(currentStreak?.tasksCompletedTotal, Int64(actualStreakTodosCount!), "should have \(Int64(actualStreakTodosCount!)) completed tasks")
//        
//        // Change today's createdAt date to tomorrow's day
//        let streak = actualStreaks.first
//        streak?.setValue(yesterday, forKey: "createdAt")
//        try! ctx.save()
//        
//        // for remaining todo, make a new streak with today's date
//        for index in TODO_CONST_1..<TODO_CONST_2 {
//            let todo = results[index] as! TodoItem
//
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(timeNow, forKey: "completedAt")
//            todo.setValue(timeNow, forKey: "updatedAt")
//            
//            try! ctx.save()
//
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//        
//        let actualStreaksAltered = streakManager.fetchAll()
//        let actualStreakCountAltered = actualStreaksAltered.count
//        let todaysStreak = actualStreaksAltered.first
//        let actualStreakTodosCountAltered = todaysStreak?.todos?.count
//        let todaysStreakCreatedAt = todaysStreak?.createdAt
//        
//        let yesterdaysStreakTodosCount = actualStreaksAltered.last?.todos?.count
//        let yesterdaysStreakDateCreated = actualStreaksAltered.last?.createdAt
//        
//        XCTAssertEqual(actualStreakCountAltered, 2, "should have 2 streaks")
//        XCTAssertEqual(actualStreakTodosCountAltered, CONST_DIFF, "should only have \(CONST_DIFF) todo added to latest streak")
//        XCTAssertEqual(yesterdaysStreakTodosCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to yesterday's streak")
//        XCTAssertEqual(timeNow, todaysStreakCreatedAt, "date should be set to today")
//        XCTAssertEqual(yesterday, yesterdaysStreakDateCreated, "date should be set to yesterday")
//        XCTAssertEqual(todaysStreak?.currentDaysInARow, 2, "should have 2 days in a row")
//        XCTAssertEqual(todaysStreak?.recordDaysInARow, 2, "should have 2 record days in a row")
//        XCTAssertEqual(todaysStreak?.tasksCompletedTotal, 10, "should have 10 completed tasks")
//    }
//    
//    func testThreeRandomDays() {
//        let ctx: NSManagedObjectContext = mockPersistantContainer.viewContext
//        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
//        let results = try! mockPersistantContainer.viewContext.fetch(request)
//        
//        let firstTodo = results.first as! TodoItem
//        let currentTime = Date()
//        
//        let SUBTRACT_CONST_1 = 13
//        let SUBTRACT_CONST_2 = 7
//        
//        let firstTodoCreationDate = firstTodo.createdAt!
//        let FIRST_DATE = firstTodoCreationDate.subtract(days: SUBTRACT_CONST_1)
//        let SECOND_DATE = firstTodoCreationDate.subtract(days: SUBTRACT_CONST_2)
//        
//        let TODO_CONST_1 = 4
//        let TODO_CONST_MAX = 10
//        let TODO_CONST_2 = 7
//        let CONST_DIFF = TODO_CONST_MAX - TODO_CONST_1
//        
//        for index in 0..<TODO_CONST_1 {
//            let todo = results[index] as! TodoItem
//            
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(currentTime, forKey: "completedAt")
//            todo.setValue(currentTime, forKey: "updatedAt")
//            
//            try! ctx.save()
//            
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//        
//        var _streak = streakManager.fetchBy(date: currentTime)
//        _streak.setValue(FIRST_DATE, forKey: "createdAt")
//        try! ctx.save()
//        
//        var _streakTodoCount = _streak.todos?.count
//        var _streakCreatedAt = _streak.createdAt
//        
//        var streakCount = streakManager.fetchAll().count
//        
//        XCTAssertEqual(streakCount, 1, "should have 1 streaks")
//        XCTAssertEqual(_streakTodoCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to latest streak")
//        XCTAssertEqual(FIRST_DATE, _streakCreatedAt, "date should be set to \(FIRST_DATE)")
//        XCTAssertEqual(_streak.currentDaysInARow, 1, "should have 1 days in a row")
//        XCTAssertEqual(_streak.recordDaysInARow, 1, "should have 1 record days in a row")
//        XCTAssertEqual(_streak.tasksCompletedTotal, Int64(TODO_CONST_1), "should have \(Int64(TODO_CONST_1)) completed tasks")
//        
//        _streak = Streak()
//        _streakTodoCount = -1
//        _streakCreatedAt = Date()
//        
//        ///////////////////////////////////////////////
//        
//        for index in TODO_CONST_1..<TODO_CONST_2 {
//            let todo = results[index] as! TodoItem
//            
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(currentTime, forKey: "completedAt")
//            todo.setValue(currentTime, forKey: "updatedAt")
//            
//            try! ctx.save()
//            
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//        
//        let TODO_CONST_1_2_DIFF = abs(TODO_CONST_2 - TODO_CONST_1)
//        
//        _streak = streakManager.fetchBy(date: currentTime)
//        _streak.setValue(SECOND_DATE, forKey: "createdAt")
//        try! ctx.save()
//        
//        _streakTodoCount = _streak.todos?.count
//        _streakCreatedAt = _streak.createdAt
//        
//        streakCount = streakManager.fetchAll().count
//        
//        XCTAssertEqual(streakCount, 2, "should have 2 streaks")
//        XCTAssertEqual(_streakTodoCount, TODO_CONST_1_2_DIFF, "should only have \(TODO_CONST_1_2_DIFF) todo added to latest streak")
//        XCTAssertEqual(SECOND_DATE, _streakCreatedAt, "date should be set to \(SECOND_DATE)")
//        XCTAssertEqual(_streak.tasksCompletedToday, Int64(TODO_CONST_1_2_DIFF), "should have \(TODO_CONST_1_2_DIFF) tasks completed today.")
//        XCTAssertEqual(_streak.currentDaysInARow, 1, "should have 1 days in a row")
//        XCTAssertEqual(_streak.recordDaysInARow, 1, "should have 1 record days in a row")
//        XCTAssertEqual(_streak.tasksCompletedTotal, Int64(TODO_CONST_1 + TODO_CONST_1_2_DIFF), "should have \(Int64(TODO_CONST_1 + TODO_CONST_1_2_DIFF)) completed tasks")
//        
//        _streak = Streak()
//        _streakTodoCount = -1
//        _streakCreatedAt = Date()
//        
//        ///////////////////////////////////////////////
//        
//        for index in TODO_CONST_2..<TODO_CONST_MAX {
//            let todo = results[index] as! TodoItem
//            
//            todo.setValue(false, forKey: "isNew")
//            todo.setValue(true, forKey: "completed")
//            todo.setValue(currentTime, forKey: "completedAt")
//            todo.setValue(currentTime, forKey: "updatedAt")
//            
//            try! ctx.save()
//            
//            guard streakManager.process(item: todo) else { fatalError("should not") }
//        }
//        
//        let TODO_CONST_2_MAX_DIFF = abs(TODO_CONST_MAX - TODO_CONST_2)
//        
//        _streak = streakManager.fetchBy(date: currentTime)
//        
//        _streakTodoCount = _streak.todos?.count
//        _streakCreatedAt = _streak.createdAt
//        
//        streakCount = streakManager.fetchAll().count
//        
//        XCTAssertEqual(streakCount, 3, "should have 3 streaks")
//        XCTAssertEqual(_streakTodoCount, TODO_CONST_2_MAX_DIFF, "should only have \(TODO_CONST_2_MAX_DIFF) todo added to latest streak")
//        XCTAssertEqual(currentTime, _streakCreatedAt, "date should be set to \(currentTime)")
//        XCTAssertEqual(_streak.tasksCompletedToday, Int64(TODO_CONST_2_MAX_DIFF), "should have \(TODO_CONST_2_MAX_DIFF) tasks completed today.")
//        XCTAssertEqual(_streak.currentDaysInARow, 1, "should have 1 days in a row")
//        XCTAssertEqual(_streak.recordDaysInARow, 1, "should have 1 record days in a row")
//        XCTAssertEqual(_streak.tasksCompletedTotal, Int64(TODO_CONST_1 + TODO_CONST_1_2_DIFF + TODO_CONST_2_MAX_DIFF), "should have \(Int64(TODO_CONST_1 + TODO_CONST_1_2_DIFF + TODO_CONST_2_MAX_DIFF)) completed tasks")
//        XCTAssertEqual(_streak.tasksCompletedTotal, 10, "should have 10 completed tasks")
//        _streak = Streak()
//        _streakTodoCount = -1
//        _streakCreatedAt = Date()
//        
////        // Change today's createdAt date to four days ago
////        let streak = actualStreaks.first
////        streak?.setValue(fourDaysAgo, forKey: "createdAt")
////        try! ctx.save()
////
////        ////////////////////////////////////////////
////
////        for index in TODO_CONST_1..<TODO_CONST_2 {
////            let todo = results[index] as! TodoItem
////
////            todo.setValue(false, forKey: "isNew")
////            todo.setValue(true, forKey: "completed")
////            todo.setValue(currentTime, forKey: "completedAt")
////            todo.setValue(currentTime, forKey: "updatedAt")
////
////            try! ctx.save()
////
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        let actualStreaks = streakManager.fetchAll()
////        let actualStreakCount = actualStreaks.count
////
////        let currentStreak = actualStreaks.first
////        let actualStreakTodosCount = currentStreak?.todos?.count
////        let todaysStreakDate = currentStreak?.createdAt
////
////        XCTAssertEqual(actualStreakCount, 1, "should have 1 streaks")
////        XCTAssertEqual(actualStreakTodosCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to latest streak")
////        XCTAssertEqual(currentTime, todaysStreakDate, "date should be set to today")
////        XCTAssertEqual(currentStreak?.currentDaysInARow, 1, "should have 1 days in a row")
////        XCTAssertEqual(currentStreak?.recordDaysInARow, 1, "should have 1 record days in a row")
////        XCTAssertEqual(currentStreak?.tasksCompletedTotal, Int64(actualStreakTodosCount!), "should have \(Int64(actualStreakTodosCount!)) completed tasks")
////
////        // Change today's createdAt date to four days ago
////        let streak = actualStreaks.first
////        streak?.setValue(fourDaysAgo, forKey: "createdAt")
////        try! ctx.save()
////
////        ////////////////////////////////////////////
////
////        for index in TODO_CONST_2..<TODO_CONST_MAX {
////            let todo = results[index] as! TodoItem
////
////            todo.setValue(false, forKey: "isNew")
////            todo.setValue(true, forKey: "completed")
////            todo.setValue(currentTime, forKey: "completedAt")
////            todo.setValue(currentTime, forKey: "updatedAt")
////
////            try! ctx.save()
////
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        let actualStreaks = streakManager.fetchAll()
////        let actualStreakCount = actualStreaks.count
////
////        let currentStreak = actualStreaks.first
////        let actualStreakTodosCount = currentStreak?.todos?.count
////        let todaysStreakDate = currentStreak?.createdAt
////
////        XCTAssertEqual(actualStreakCount, 1, "should have 1 streaks")
////        XCTAssertEqual(actualStreakTodosCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to latest streak")
////        XCTAssertEqual(currentTime, todaysStreakDate, "date should be set to today")
////        XCTAssertEqual(currentStreak?.currentDaysInARow, 1, "should have 1 days in a row")
////        XCTAssertEqual(currentStreak?.recordDaysInARow, 1, "should have 1 record days in a row")
////        XCTAssertEqual(currentStreak?.tasksCompletedTotal, Int64(actualStreakTodosCount!), "should have \(Int64(actualStreakTodosCount!)) completed tasks")
////
////        // Change today's createdAt date to four days ago
////        let streak = actualStreaks.first
////        streak?.setValue(fourDaysAgo, forKey: "createdAt")
////        try! ctx.save()
////
////        ////////////////////////////////////////////
////
////        // for remaining todo, make a new streak with today's date
////        for index in TODO_CONST_1..<TODO_CONST_2 {
////            let todo = results[index] as! TodoItem
////
////            todo.setValue(false, forKey: "isNew")
////            todo.setValue(true, forKey: "completed")
////            todo.setValue(currentTime, forKey: "completedAt")
////            todo.setValue(currentTime, forKey: "updatedAt")
////
////            try! ctx.save()
////
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        let actualStreaksAltered = streakManager.fetchAll()
////        let actualStreakCountAltered = actualStreaksAltered.count
////        let todaysStreak = actualStreaksAltered.first
////        let actualStreakTodosCountAltered = todaysStreak?.todos?.count
////        let todaysStreakCreatedAt = todaysStreak?.createdAt
////
////        let yesterdaysStreakTodosCount = actualStreaksAltered.last?.todos?.count
////        let yesterdaysStreakDateCreated = actualStreaksAltered.last?.createdAt
////
////        XCTAssertEqual(actualStreakCountAltered, 2, "should have 2 streaks")
////        XCTAssertEqual(actualStreakTodosCountAltered, CONST_DIFF, "should only have \(CONST_DIFF) todo added to latest streak")
////        XCTAssertEqual(yesterdaysStreakTodosCount, TODO_CONST_1, "should only have \(TODO_CONST_1) todo added to yesterday's streak")
////        XCTAssertEqual(currentTime, todaysStreakCreatedAt, "date should be set to today")
////        XCTAssertEqual(yesterday, yesterdaysStreakDateCreated, "date should be set to yesterday")
////        XCTAssertEqual(todaysStreak?.currentDaysInARow, 2, "should have 2 days in a row")
////        XCTAssertEqual(todaysStreak?.recordDaysInARow, 2, "should have 2 record days in a row")
////        XCTAssertEqual(todaysStreak?.tasksCompletedTotal, 10, "should have 10 completed tasks")
//    }
//    
////    func testTodayAndThreeDaysAgoStreak() {
////        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
////        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
////        let results = try! mockPersistantContainer.viewContext.fetch(request)
////        //        let randomTodo = results.first as? TodoItem
////
////        for index in 0..<8 {
////            let todo = results[index] as! TodoItem
////            todo.markCompleted()
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        var streak = streakManager.fetchAll().first
////        let fourDaysAgo = Date().subtract(days: 4)
////
////        streak?.setValue(fourDaysAgo, forKey: "createdAt")
////        streak?.setValue(fourDaysAgo, forKey: "updatedAt")
////
////        try! mockPersistantContainer.viewContext.save()
////
////        for index in 8..<9 {
////            let todo = results[index] as! TodoItem
////            todo.markCompleted()
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        streak = streakManager.fetchAll().first
////        let threeDaysAgo = Date().subtract(days: 3)
////
////        streak?.setValue(threeDaysAgo, forKey: "createdAt")
////        streak?.setValue(threeDaysAgo, forKey: "updatedAt")
////
////        try! mockPersistantContainer.viewContext.save()
////
////        for index in 9..<10 {
////            let todo = results[index] as! TodoItem
////            todo.markCompleted()
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
////        let actualStreaks = streakManager.fetchAll()
////        let actualStreakCount = actualStreaks.count
////        let actualStreakTodosCount = actualStreaks.first?.todos?.count
////
////        //        XCTAssertTrue(actualResult, "expecting streakManager to successfully process the first todo")
////        XCTAssertEqual(actualStreakCount, 3, "should have 3 streaks")
////        XCTAssertEqual(actualStreakTodosCount, 1, "should only have 1 todo added to latest streak")
////    }
//    
////    func testThreeDaysStreakVariables() {
////        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
////        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
////        let results = try! mockPersistantContainer.viewContext.fetch(request)
////        //        let randomTodo = results.first as? TodoItem
////        let fourDaysAgo = Date().subtract(days: 4)
////        let threeDaysAgo = Date().subtract(days: 3)
////
////        for index in 0..<6 {
////            let todo = results[index] as! TodoItem
////            todo.markCompleted()
////            todo.updatedAt = fourDaysAgo
////            todo.completedAt = fourDaysAgo
////        }
////
////        try! mockPersistantContainer.viewContext.save()
////
////        for index in 0..<6 {
////            let todo = results[index] as! TodoItem
////            guard streakManager.process(item: todo) else { fatalError("should not") }
////        }
////
//////        var streak = streakManager.fetchAll().first as Streak!
//////
//////        streak?.setValue(fourDaysAgo, forKey: "createdAt")
//////        streak?.setValue(fourDaysAgo, forKey: "updatedAt")
//////
////////        try! mockPersistantContainer.viewContext.save()
//////
//////        for index in 6..<9 {
//////            let todo = results[index] as! TodoItem
//////            todo.markCompleted()
//////            todo.updatedAt = threeDaysAgo
//////            todo.completedAt = threeDaysAgo
//////            try! mockPersistantContainer.viewContext.save()
//////            NSLog("about to create 3 days ago")
//////            guard streakManager.process(item: todo) else { fatalError("should not") }
//////            NSLog("processing index \(index)")
//////        }
//////
//////        streak = streakManager.fetchAll().first
//////
//////        streak?.setValue(threeDaysAgo, forKey: "createdAt")
//////        streak?.setValue(threeDaysAgo, forKey: "updatedAt")
//////
////////        try! mockPersistantContainer.viewContext.save()
//////
//////        for index in 9..<10 {
//////            let todo = results[index] as! TodoItem
//////            todo.markCompleted()
//////            try! mockPersistantContainer.viewContext.save()
//////            NSLog("about to create todays")
//////            guard streakManager.process(item: todo) else { fatalError("should not") }
//////            NSLog("processing index \(index)")
//////        }
//////
////////        try! mockPersistantContainer.viewContext.save()
//////
//////        let actualStreaks: [Streak] = streakManager.fetchAll()
////////        let actualStreakCount = actualStreaks.count
//////
//////        for (index, value) in actualStreaks.enumerated() {
//////            let tasksCompletedToday = 1
//////            let tasksCompletedThreeDaysAgo = 3
//////            let tasksCompletedFourDaysAgo = 6
//////
//////            let totalFourDaysAgo = tasksCompletedFourDaysAgo
//////            let totalThreeDaysAgo = tasksCompletedThreeDaysAgo + totalFourDaysAgo
//////            let totalToday = tasksCompletedToday + totalThreeDaysAgo
//////
//////            let totalRecordDaysInARow = 2
//////            let minimumRecordDaysInARow = 1
//////
//////            switch index {
//////            case 0:
//////                XCTAssertEqual(value.updatedAt, actualStreaks.first?.updatedAt, "updateAt should be today")
//////                XCTAssertEqual(value.tasksCompletedToday, Int64(tasksCompletedToday), "tasks completed today should be equal")
//////                XCTAssertEqual(value.tasksCompletedTotal, Int64(totalToday), "task completed should be over 3 streaks")
//////                XCTAssertEqual(value.currentDaysInARow, Int64(minimumRecordDaysInARow), "should be 1 day in a row")
//////                XCTAssertEqual(value.recordDaysInARow, Int64(totalRecordDaysInARow), "should have 2 days in a row as a record")
//////            case 1:
//////                XCTAssertEqual(value.updatedAt, threeDaysAgo, "updateAt should be 3 days ago")
//////                XCTAssertEqual(value.tasksCompletedToday, Int64(tasksCompletedThreeDaysAgo), "tasks completed today should be equal")
//////                XCTAssertEqual(value.tasksCompletedTotal, Int64(totalThreeDaysAgo), "task completed should be over 2 streaks")
//////                XCTAssertEqual(value.currentDaysInARow, Int64(totalRecordDaysInARow), "should be 2 day in a row")
//////                XCTAssertEqual(value.recordDaysInARow, Int64(totalRecordDaysInARow), "should have 2 days in a row as a record")
//////            case 2:
//////                XCTAssertEqual(value.updatedAt, fourDaysAgo, "updateAt should be 4 days ago")
//////                XCTAssertEqual(value.tasksCompletedToday, Int64(tasksCompletedFourDaysAgo), "tasks completed today should be equal")
//////                XCTAssertEqual(value.tasksCompletedTotal, Int64(totalFourDaysAgo), "task completed should be over 1 day")
//////                XCTAssertEqual(value.currentDaysInARow, Int64(minimumRecordDaysInARow), "should be 1 day in a row")
//////                XCTAssertEqual(value.recordDaysInARow, Int64(minimumRecordDaysInARow), "should have 1 days in a row as a record")
//////            default:
//////                fatalError()
//////            }
//////        }
////
////        //        XCTAssertTrue(actualResult, "expecting streakManager to successfully process the first todo")
//////        XCTAssertEqual(actualStreakCount, 3, "should have 3 streaks")
////        //        XCTAssertEqual(actualStreakTodosCount, 1, "should only have 1 todo added to latest streak")
////    }
//}

