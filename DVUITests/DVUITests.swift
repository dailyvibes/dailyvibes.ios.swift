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
        setupSnapshot(app)
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
        let fourthButton = tabBar.buttons.element(boundBy: 3)

        thirdButton.tap()
        snapshot("1DailyProgress")
////
        firstButton.tap()
        secondButton.tap()
        
        snapshot("2MultiEntry")
        
//        app.tap()
        app.buttons["multi_entry_cancel_btn"].tap()
        
        let button = app.buttons["main_more_filter_btn"]
        XCTAssert(button.exists)
        button.tap()
        snapshot("3FilterProjects")
//
        let dailyVibesTodotaskitemfiltersviewNavigationBar = app.navigationBars["Daily_Vibes.TodoTaskItemFiltersView"]
        let listBaritemIconDailyvibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["list baritem icon dailyvibes"]
        XCTAssert(dailyVibesTodotaskitemfiltersviewNavigationBar.exists)
        XCTAssert(listBaritemIconDailyvibesButton.exists)
        listBaritemIconDailyvibesButton.tap()
        snapshot("4GroupByProjects")
//
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Today"]/*[[".cells.staticTexts[\"Today\"]",".staticTexts[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
        let dailyVibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["Daily Vibes"]
        XCTAssert(dailyVibesButton.exists)
        dailyVibesButton.tap()
        snapshot("5SmartTodayView")
//
        button.tap()
        listBaritemIconDailyvibesButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["This week"]/*[[".cells.staticTexts[\"This week\"]",".staticTexts[\"This week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        dailyVibesButton.tap()
        snapshot("6SmartThisWeekView")
        
        button.tap()
        listBaritemIconDailyvibesButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Groceries"]/*[[".cells.staticTexts[\"Groceries\"]",".staticTexts[\"Groceries\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        dailyVibesButton.tap()
        snapshot("7CustomProjects")
//
//
        button.tap()
        listBaritemIconDailyvibesButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Inbox"]/*[[".cells.staticTexts[\"Inbox\"]",".staticTexts[\"Inbox\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        dailyVibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["copy/pasted twitter banner to fb banner #dailyvibes"]/*[[".cells.staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]",".staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssert(firstCell.exists)
        
//        app.cells.element(boundBy: 0).swipeLeft()
//        snapshot("8QuickSwipeActions")
//
        firstCell.tap()
        snapshot("8DetailView")
        
        app.buttons["details_cancel_btn"].tap()
        fourthButton.tap()
        app.buttons["settings_export_btn"].tap()
        snapshot("9ExportView")
    }
}
