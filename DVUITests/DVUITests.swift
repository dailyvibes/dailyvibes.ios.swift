//
//  DVUITests.swift
//  DVUITests
//
//  Created by Alex Kluew on 2018-02-24.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import XCTest

class DVUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("IS_RUNNING_UITEST")
//        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        snapshot("0Launch")
        
        let tabBar = app.tabBars
        let firstButton = tabBar.buttons.element(boundBy: 0)
        let secondButton = tabBar.buttons.element(boundBy: 1)
        let thirdButton = tabBar.buttons.element(boundBy: 2)

        thirdButton.tap()
        snapshot("1DailyProgress")
////
        firstButton.tap()
        secondButton.tap()
        
        snapshot("2MultiEntry")
        
        let newTodo = NSLocalizedString("Add a to-do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Add a to-do", comment: "")
        let cancelLbl = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel", comment: "")
        
        let newToDoSheet = app.sheets[newTodo]
        newToDoSheet.buttons[cancelLbl].tap()
//        snapshot("2MultiEntry")
        
//        let newToDoSheet = app.sheets["New To-do"]
//        newToDoSheet.buttons["Cancel"].tap()
//
        let button = app.navigationBars["Daily Vibes"].children(matching: .button).element
        button.tap()
        snapshot("3FilterProjects")
//
        let dailyVibesTodotaskitemfiltersviewNavigationBar = app.navigationBars["Daily_Vibes.TodoTaskItemFiltersView"]
        let listBaritemIconDailyvibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["list baritem icon dailyvibes"]
        listBaritemIconDailyvibesButton.tap()
        snapshot("4GroupByProjects")
//
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Today"]/*[[".cells.staticTexts[\"Today\"]",".staticTexts[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
        let dailyVibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["Daily Vibes"]
        dailyVibesButton.tap()
        button.tap()
//
        snapshot("5SmartTodayView")
//
        button.tap()
        listBaritemIconDailyvibesButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["This week"]/*[[".cells.staticTexts[\"This week\"]",".staticTexts[\"This week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        dailyVibesButton.tap()
        button.tap()
        snapshot("6SmartThisWeekView")
        
        button.tap()
        listBaritemIconDailyvibesButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Groceries"]/*[[".cells.staticTexts[\"Groceries\"]",".staticTexts[\"Groceries\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        dailyVibesButton.tap()
        button.tap()
        snapshot("7CustomProjects")
//
//
//        listBaritemIconDailyvibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Inbox"]/*[[".cells.staticTexts[\"Inbox\"]",".staticTexts[\"Inbox\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        dailyVibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["copy/pasted twitter banner to fb banner #dailyvibes"]/*[[".cells.staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]",".staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
//        /// snapshot("7QuickSwipeActions")
        
//        let app = XCUIApplication()
//        app.navigationBars["Daily Vibes"].children(matching: .button).element.tap()
//        app.navigationBars["Daily_Vibes.TodoTaskItemFiltersView"].buttons["Daily Vibes"].tap()
//
//        let addButton = app.tabBars.buttons["Add"]
//        addButton.tap()
//        app.sheets["New To-do"].buttons["Single"].tap()
//
//        let textView = app.tables.children(matching: .cell).element(boundBy: 0).children(matching: .textView).element
//        textView.tap()
//        textView.typeText("Buy Milk 🥛")
//        textView.typeText("\n")
//        let app = XCUIApplication()
        
//        let app = XCUIApplication()
//        app.navigationBars["Daily Vibes"].children(matching: .button).element.tap()
//        app.navigationBars["Change Project"].tap()
//        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Groceries"]/*[[".cells.staticTexts[\"Groceries\"]",".staticTexts[\"Groceries\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        snapshot("8AnyProject")
        
        
//        app.navigationBars["Daily_Vibes.TodoTaskItemFiltersView"].buttons["Daily Vibes"].tap()
//        app.tabBars.buttons["Progress"].tap()
        
    }
}
