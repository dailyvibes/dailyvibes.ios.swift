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
//        app.launchArguments.append("NIGHT-BLUE-THEME")
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        snapshot("Launch")
        
        let tabBar = app.tabBars
        let firstButton = tabBar.buttons.element(boundBy: 0)
        let secondButton = tabBar.buttons.element(boundBy: 1)
        let thirdButton = tabBar.buttons.element(boundBy: 2)
        let fourthButton = tabBar.buttons.element(boundBy: 3)
////
        XCTAssert(secondButton.exists)
        secondButton.tap()
        snapshot("DailyVibes")
        
        XCTAssert(app.buttons["dailyvibes_compose_new_entry"].exists)
        app.buttons["dailyvibes_compose_new_entry"].tap()
        
//        XCTAssert(app.sliders.element(boundBy: 0).exists)
//        app.sliders.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.9)
//        XCTAssert(app.sliders.element(boundBy: 1).exists)
//        app.sliders.element(boundBy: 1).adjust(toNormalizedSliderPosition: 0.7)
//        XCTAssert(app.sliders.element(boundBy: 2).exists)
//        app.sliders.element(boundBy: 2).adjust(toNormalizedSliderPosition: 0.1)
        
        snapshot("MindfulVibes")
        
        XCTAssert(app.buttons["likert_scale_item_details_cancel_btn"].exists)
        app.buttons["likert_scale_item_details_cancel_btn"].tap()
        
//        let likertitemsavebtnidentifier = "likert_scale_item_details_save_btn"
//        let likertitemsavebtn = app.buttons[likertitemsavebtnidentifier]
//        XCTAssert(likertitemsavebtn.exists)
//        likertitemsavebtn.tap()
        
//        XCTAssert(thirdButton.exists)
//        XCTAssert(thirdButton.waitForExistence(timeout: 1))
        thirdButton.tap()
        snapshot("DailyProgress")
        
        XCTAssert(firstButton.exists)
        firstButton.tap()
        
//        XCTAssert(app.buttons["taskitemlist.dotdotdot.btn"].exists)
//        app.buttons["taskitemlist.dotdotdot.btn"].tap()
        
//        addUIInterruptionMonitor(withDescription: "edit btn pressed") { (alert) -> Bool in
////            let title = NSLocalizedString("Sort by", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sort by **", comment: "")
//            let title = "Sort By All"
//
//            XCTAssert(alert.buttons[title].exists)
//            alert.buttons[title].tap()
//
//            return true
//        }
        
        XCTAssert(app.buttons["dv_new_dvtaskitem"].exists)
        app.buttons["dv_new_dvtaskitem"].tap()
      
//        app.textFields.element.tap()
//        app.textFields.element.typeText("test")
        snapshot("MultiEntry")
        
        let projectCell = app.tables.cells.allElementsBoundByIndex[0]
        
        XCTAssert(projectCell.exists)
        projectCell.tap()
        
//        app.textFields.element.tap()
//        app.textFields.element.typeText("test")
        snapshot("OrganizeIdeas")
        
        let DVListViewModelCcancelBtnIdentifier = "DVListViewModel.cancel.btn"
        XCTAssert(app.buttons[DVListViewModelCcancelBtnIdentifier].exists)
        app.buttons[DVListViewModelCcancelBtnIdentifier].tap()
        
        XCTAssert(app.buttons["multicreate.keyboard.down.btn"].exists)
        app.buttons["multicreate.keyboard.down.btn"].tap()
        XCTAssert(app.buttons["multi_entry_cancel_btn"].exists)
        app.buttons["multi_entry_cancel_btn"].tap()
        
//        let firstMainCell = app.tables.cells.allElementsBoundByIndex[0]
//        XCTAssert(firstMainCell.exists)
//        firstMainCell.tap()
//        snapshot("DetailView")
//
//        let todoitemDetailsCancelBtnIdentifier = "details_cancel_btn"
//        XCTAssert(app.buttons[todoitemDetailsCancelBtnIdentifier].exists)
//        app.buttons[todoitemDetailsCancelBtnIdentifier].tap()
        
//        XCTAssert(secondButton.exists)
//        secondButton.tap()
//        snapshot("DailyVibes")
        
        let dotdotdotbtn = app.buttons["taskitemlist.dotdotdot.btn"]
        XCTAssert(dotdotdotbtn.exists)
        
        dotdotdotbtn.tap()
        
        snapshot("FilterProjects")
        app.tap()
        
        let mainbckbtn = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssert(mainbckbtn.exists)
        
        mainbckbtn.tap()
        snapshot("CustomProjects")
        
        let dvprojectidentifierbytitle = "Daily Vibes Project"
        app.tables.staticTexts[dvprojectidentifierbytitle].tap()
//        app.tables.cells.allElementsBoundByIndex[0]
        
//        NIGHT-BLUE-THEME
        
        let firstMainCell = app.tables.cells.allElementsBoundByIndex[0]
        XCTAssert(firstMainCell.exists)
        firstMainCell.tap()
        snapshot("DetailView")
        
        app.tables.cells.allElementsBoundByIndex[5].tap()
        snapshot("Markdown")
        
        let notescancelbtnIdentifier = "dv.notesentry.close.btn"
        XCTAssert(app.buttons[notescancelbtnIdentifier].exists)
        app.buttons[notescancelbtnIdentifier].tap()
        
        let todoitemDetailsCancelBtnIdentifier = "details_cancel_btn"
        XCTAssert(app.buttons[todoitemDetailsCancelBtnIdentifier].exists)
        app.buttons[todoitemDetailsCancelBtnIdentifier].tap()
        
//        let tagsCell = app.tables.cells.allElementsBoundByIndex[2]
//        XCTAssert(tagsCell.exists)
        
        
//        Daily Vibes
//        app.tap()
//        app.buttons["multi_entry_cancel_btn"].tap()
        
//        let button = app.buttons["main_more_filter_btn"]
//        XCTAssert(button.exists)
//        button.tap()
//        snapshot("3FilterProjects")
        
        // get to main day view
//        app.buttons["dvDayEntryBtn"].tap()
        // get to the entry compose view
//        app.buttons["dailyvibes_compose_new_entry"].tap()
//        snapshot("Daily Vibes")
        
        // go back
//        app.buttons["likert_scale_item_details_cancel_btn"].tap()
//        app.buttons["dailyvibes_dates_done"].tap()
        
        //let dvDateEntry = app.navigationBars["Daily_Vibes.DVLikertScaleItemUI"]
//
//        let dailyVibesTodotaskitemfiltersviewNavigationBar = app.navigationBars["Daily_Vibes.TodoTaskItemFiltersView"]
//        let listBaritemIconDailyvibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["list baritem icon dailyvibes"]
////        XCTAssert(dailyVibesTodotaskitemfiltersviewNavigationBar.exists)
////        XCTAssert(listBaritemIconDailyvibesButton.exists)
//        listBaritemIconDailyvibesButton.tap()
//        snapshot("4GroupByProjects")
////
//        let tablesQuery = app.tables
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Today"]/*[[".cells.staticTexts[\"Today\"]",".staticTexts[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
////
//        let dailyVibesButton = dailyVibesTodotaskitemfiltersviewNavigationBar.buttons["Daily Vibes"]
//        XCTAssert(dailyVibesButton.exists)
//        dailyVibesButton.tap()
//        snapshot("5SmartTodayView")
////
//        button.tap()
//        listBaritemIconDailyvibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["This week"]/*[[".cells.staticTexts[\"This week\"]",".staticTexts[\"This week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        dailyVibesButton.tap()
//        snapshot("6SmartThisWeekView")
//        
//        button.tap()
//        listBaritemIconDailyvibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Groceries"]/*[[".cells.staticTexts[\"Groceries\"]",".staticTexts[\"Groceries\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        dailyVibesButton.tap()
//        snapshot("7CustomProjects")
//
//
//        button.tap()
//        listBaritemIconDailyvibesButton.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Inbox"]/*[[".cells.staticTexts[\"Inbox\"]",".staticTexts[\"Inbox\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        dailyVibesButton.tap()
////        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["copy/pasted twitter banner to fb banner #dailyvibes"]/*[[".cells.staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]",".staticTexts[\"copy\/pasted twitter banner to fb banner #dailyvibes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
//        let firstCell = app.cells.element(boundBy: 0)
//        XCTAssert(firstCell.exists)
        
//        app.cells.element(boundBy: 0).swipeLeft()
//        snapshot("8QuickSwipeActions")
//
//        firstCell.tap()
//        snapshot("8DetailView")
        
//        app.buttons["details_cancel_btn"].tap()
        
        fourthButton.tap()
        let themesCell = app.tables.cells.allElementsBoundByIndex[1]
        
        XCTAssert(themesCell.exists)
        themesCell.tap()
        
        let nightbluecell = app.tables.cells.allElementsBoundByIndex[1]
        XCTAssert(nightbluecell.exists)
        
        nightbluecell.tap()
        snapshot("Themes")
        
        fourthButton.tap()
//        let exportbtnidentifier = "settings_export_btn"
//        let exportbtn = app.buttons[exportbtnidentifier]
        
        let exportbtncell = app.tables.cells.allElementsBoundByIndex[4]
        
        XCTAssert(exportbtncell.exists)
//        app.buttons["settings_export_btn"].tap()
        exportbtncell.tap()
        snapshot("ExportView")
    }
    
    
}
