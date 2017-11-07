//
//  Daily_VibesTests.swift
//  Daily VibesTests
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import XCTest
@testable import Daily_Vibes

class Daily_VibesTests: XCTestCase {
    
    // MARK: TodoItem Class Tests
    
    func testTodoItemInitializationSuccess() {
        let goodTodoItem = TodoItem.init(todoItemText: "Build a static todo list item", tags: ["producthunthackathon", "vibes"])
        XCTAssertNotNil(goodTodoItem)
        
        let emptyTagsTodoItem = TodoItem.init(todoItemText: "Build a static todo list item", tags: [])
        XCTAssertNotNil(emptyTagsTodoItem)
    }
    
    func testTodoItemInitializationFail() {
        let emptyTodoItem = TodoItem.init(todoItemText: "", tags: nil)
        XCTAssertNil(emptyTodoItem)
    }
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
