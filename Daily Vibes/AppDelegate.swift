//
//  AppDelegate.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData
import SwiftTheme
import UserNotifications
//import SimulatorStatusMagic


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    let store = CoreDataManager.store
    let notificationDelegate = UYLNotificationDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        
//        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
//            SDStatusBarManager.sharedInstance().enableOverrides()
//
////            case DVDefault = 0
////            case nightBlue = 1
////            case night = 2
////            case lightOrange = 3
//
//            if ProcessInfo.processInfo.arguments.contains("NIGHT-THEME") {
//                defaults.set(MyThemes.night.rawValue, forKey: "themeSelected")
//            } else if ProcessInfo.processInfo.arguments.contains("NIGHT-BLUE-THEME") {
//                defaults.set(MyThemes.nightBlue.rawValue, forKey: "themeSelected")
//            } else if ProcessInfo.processInfo.arguments.contains("ORANGE-THEME") {
//                defaults.set(MyThemes.lightOrange.rawValue, forKey: "themeSelected")
//            } else {
//                defaults.set(MyThemes.DVDefault.rawValue, forKey: "themeSelected")
//            }
//                store.destroyALL(deleteExistingStore: true)
//                store.makeNewStore()
//                makeTestDataReady()
//                makeTemplateData()
//                store.saveContext()
//
//            if !store.hasDefaultDVList() {
//                store.makeDefaultDVList()
//
//                if store.filteredProjectList == nil {
////                    let usersaved = defaults.string(forKey: "com.getaclue.dv.user.project")
//                    let defaultProjectLabel = "Daily Vibes Project"
////                    let defaultProjectLabel = usersaved ?? "Inbox"
//                    let defaultProject = store.findDVList(byLabel: defaultProjectLabel)
//                    store.filteredProjectList = DVListViewModel.fromCoreData(list: defaultProject)
//                }
//            }
//        } else {
////            SDStatusBarManager.sharedInstance().enableOverrides()
//            SDStatusBarManager.sharedInstance()?.disableOverrides()
//        }
        
//        store.destroyALL(deleteExistingStore: true)
//        store.makeNewStore()
//        makeTestDataReady()
//        makeTemplateData()
//        store.saveContext()
        
        let openingCounter = defaults.integer(forKey: "hasRun")
        defaults.set(openingCounter + 1, forKey: "hasRun")
        
        if !defaults.bool(forKey: "hasLaunchedOnce") {
            defaults.set(true, forKey: "hasLaunchedOnce")
            defaults.set(Date(), forKey: "FirstRun")
            defaults.set(Date(), forKey: "LastRun")
            
            defaults.set(MyThemes.DVDefault.rawValue, forKey: "themeSelected")
            defaults.set(true, forKey: "todo.showOnDoneAlert")
            defaults.set(true, forKey: "todo.showOnDeleteAlert")
            
            defaults.synchronize()
        } else {
            defaults.set(Date(), forKey: "LastRun")
            defaults.synchronize()
        }
        
        if !defaults.bool(forKey: "isInitCanDVSyncSet") {
            defaults.set(false, forKey: "canDVSync")
            defaults.set(false, forKey: "isDVSyncON")
            defaults.set(true, forKey: "isInitCanDVSyncSet")
        }
        
        if !store.hasDefaultDVList() {
            store.makeDefaultDVList()
        }
        
        if store.filteredProjectList == nil {
            let usersaved = defaults.string(forKey: "com.getaclue.dv.user.project")
            let defaultProjectLabel = usersaved ?? "Inbox"
            let defaultProject = store.findDVList(byLabel: defaultProjectLabel)
            store.filteredProjectList = DVListViewModel.fromCoreData(list: defaultProject)
        }
        
        
        // TODO: COME BACK TO THIS - JANUARY 23 2019
        // setupNotifications()
        
//        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
//            // insert data from a JSON file into the managed object context
//            print("IS_RUNNING_UITEST")
//            store.destroyALL(deleteExistingStore: true)
//
//            if let path = Bundle.main.path(forResource: "fakeDataDump-Feb252018", ofType: "json") {
//                do {
//                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [Dictionary<String,AnyObject>]
//                    //                let jsonResult = try JSON.init
//
//                    for task in (jsonResult)! {
//                        //                    let taskId = task["id"]
//                        let taskText = task["todoItemText"] as! String
//                        let completedAtString = task["completedAt"] as! String
//                        let taskCompleted = Date.UTCToLocal(___date: completedAtString)
//                        store.storeCustomCompletedTodoItemTask(title: taskText, createdAt: nil, updatedAt: nil, duedateAt: nil, archivedAt: nil, completedAt: taskCompleted)
//                    }
//                } catch {
//                    // handle error
//                    fatalError("OOPS")
//                }
//            }
//        }
//            print("in debug mode")
//            //            store.destroyALL(deleteExistingStore: true)
//
//            let url = "https://dl.dropboxusercontent.com/s/u9mb9o016byip4d/FakeDataDump-Feb252018.json"
//
//            URLSession.shared.dataTask(with: URL(string: url)!) { (data, res, err) in
//
//                if let d = data {
//                    do {
//                        let jsonResult = try JSONSerialization.jsonObject(with: d, options: .mutableLeaves) as? [Dictionary<String,AnyObject>]
//
//                        for task in (jsonResult)! {
//                            let taskText = task["todoItemText"] as! String
//                            let completedAtString = task["completedAt"] as! String
//                            let taskCompleted = Date.UTCToLocal(___date: completedAtString)
//
//                            self.store.storeCustomCompletedTodoItemTask(title: taskText, createdAt: nil, updatedAt: nil, duedateAt: nil, archivedAt: nil, completedAt: taskCompleted)
//                        }
//                    } catch {
//                        print("error \(error)")
//                    }
//                }
//                }.resume()
            
            //            if let path = Bundle.main.path(forResource: "fakeDataDump-Feb252018", ofType: "json") {
            //                do {
            //                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            //                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [Dictionary<String,AnyObject>]
            //                    //                let jsonResult = try JSON.init
            //
            //                    for task in (jsonResult)! {
            //                        //                    let taskId = task["id"]
            //                        let taskText = task["todoItemText"] as! String
            //                        let completedAtString = task["completedAt"] as! String
            //                        let taskCompleted = Date.UTCToLocal(___date: completedAtString)
            //                        store.storeCustomCompletedTodoItemTask(title: taskText, createdAt: nil, updatedAt: nil, duedateAt: nil, archivedAt: nil, completedAt: taskCompleted)
            //                    }
            //                } catch {
            //                    // handle error
            //                    fatalError("OOPS")
            //                }
            //            }
//        #endif
        
        //        #if DEBUG
        // -------------------------- TODO REMOVE --------------------------
        //        if let path = Bundle.main.path(forResource: "fakeDataDump-Feb012018", ofType: "json") {
        //            do {
        //                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        //                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [Dictionary<String,AnyObject>]
        ////                let jsonResult = try JSON.init
        //
        //                for task in (jsonResult)! {
        ////                    let taskId = task["id"]
        //                    let taskText = task["todoItemText"] as! String
        //                    let completedAtString = task["completedAt"] as! String
        //                    let taskCompleted = Date.UTCToLocal(___date: completedAtString)
        //                    store.storeCustomCompletedTodoItemTask(title: taskText, createdAt: nil, updatedAt: nil, duedateAt: nil, archivedAt: nil, completedAt: taskCompleted)
        //                }
        //            } catch {
        //                // handle error
        //                fatalError("OOPS")
        //            }
        //        }
        // -------------------------- TODO REMOVE --------------------------
        //        #endif
        
        // default: Red.plist
        if let theme = MyThemes(rawValue: defaults.integer(forKey: "themeSelected")) {
            MyThemes.switchTo(theme)
        } else {
            ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
        }
        
        // status bar
        
        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        
        // navigation bar
        
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.theme_tintColor = "Global.barTextColor"
        navigationBar.theme_barTintColor = "Global.barTintColor"
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.barTextColor") { value -> [NSAttributedString.Key : AnyObject]? in
            guard let rgba = value as? String else {
                return nil
            }
            
            let color = UIColor(rgba: rgba)
            let shadow = NSShadow();
            
            shadow.shadowOffset = CGSize.zero
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.shadow: shadow
            ]
//            let titleTextAttributes = [
//                NSAttributedString.Key.foregroundColor: color,
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
//                NSAttributedString.Key.shadow: shadow
//            ]
            
            return titleTextAttributes
        }
        
        navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.textColor") { value -> [NSAttributedString.Key : AnyObject]? in
            guard let rgba = value as? String else {
                return nil
            }
            
            let color = UIColor(rgba: rgba)
            let shadow = NSShadow()
            
            shadow.shadowOffset = CGSize.zero
//            let titleTextAttributes = [
//                NSAttributedString.Key.foregroundColor: color,
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34),
//                NSAttributedString.Key.shadow: shadow
//            ]
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.shadow: shadow
            ]

            
            return titleTextAttributes
        }
        
        // tab bar
        
        let tabBar = UITabBar.appearance()
        
        tabBar.theme_tintColor = "Global.barTextColor"
        tabBar.theme_barTintColor = "Global.barTintColor"
        
        let uiTextView = UITextView.appearance()
        uiTextView.theme_keyboardAppearance = "Global.keyboardStyle"
        
        let uiTextField = UITextField.appearance()
        uiTextField.theme_keyboardAppearance = "Global.keyboardStyle"
        
        let icon = UIApplicationShortcutIcon(type: .add)
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let shortcutItemIdentifierQuickAddTodoItemTask = "\(bundleIdentifier).quickAddTodoItemTask"
        let newTodoLocalizedString = NSLocalizedString("Add a to-do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Add a to-do **", comment: "")
        let item = UIApplicationShortcutItem(type: shortcutItemIdentifierQuickAddTodoItemTask, localizedTitle: newTodoLocalizedString, localizedSubtitle: nil, icon: icon, userInfo: nil)
        UIApplication.shared.shortcutItems = [item]
        
        return true
    }
    
    func makeTestDataReady() {
        
        let _ = TestDataMagicManager()
        
//        let _ = self.store.createTag(withLabel: "dailyvibes")
//        let _ = self.store.createTag(withLabel: "January 2019")
        
//        let groceryList: DailyVibesList = store.storeDailyVibesList(withTitle: "Groceries", withDescription: "Things to buy")
//        let importedStr = "Imported"
//        let groceryList: DailyVibesList = store.storeDailyVibesList(withTitle: importedStr, withDescription: "")
//        let groceryListDV = DVListViewModel.fromCoreData(list: groceryList)
        
//        let rawDataText = [
//            "- buy milk 🥛 #groceries",
//            "- buy bacon 🥓 #groceries",
//            "- buy toast 🍞 #groceries",
//            "- buy avacadoes 🥑 #groceries",
//            "- buy coffee ☕️ #groceries",
//            "- buy oatmeal 🥣 #groceries",
//            "- buy tea 🍵 #groceries"
//        ]
//        print("test data: \t \(testdatamngr.textdata)")
        
//        let _ratDataText = testdatamngr.textdata.components(separatedBy: "\n")
//
//        for (index, entry) in _ratDataText.enumerated() {
//            let multipleData: DVMultipleTodoitemtaskItemsVM = DVMultipleTodoitemtaskItemsVM()
//            multipleData.curProject = groceryListDV
//            multipleData.prevProject = groceryListDV
//            multipleData.rawMultipleTaskText = entry
////            if index % 2 == 0 {
////                multipleData.isRemindable = true
////            }
//
//            if entry.lowercased().range(of: "due:") != nil {
//                multipleData.isRemindable = true
//            }
//
////            multipleData.duedateAt = Date().add(days: index)
//            multipleData.parsedText = DVMultipleTodoitemtaskItemsVC.parseMultipleTodos(data: multipleData, todosInput: multipleData.rawMultipleTaskText!)
//
//
//            if let hasParsedText = multipleData.parsedText, hasParsedText.count > 0 {
//                for item in hasParsedText {
//                    let temp: DVMultipleTodoitemtaskItemVM  = DVMultipleTodoitemtaskItemVM()
//                    temp.text = item
//                    if multipleData.cookedData == nil {
//                        multipleData.cookedData = [DVMultipleTodoitemtaskItemVM]()
//
//                    }
//                    temp.dueDate = Date().add(days: index)
//                    multipleData.cookedData?.append(temp)
//                }
//            }
//
//            store.editingDVTodotaskItemListPlaceholder = groceryListDV
//            store.processMultipleTodoitemTasks(forProject: groceryListDV, todoItemTasksData: multipleData)
//            store.editingDVTodotaskItemListPlaceholder = nil
//
//            store.filteredProjectList = groceryListDV
//        }
    }
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let shortcutItemIdentifierQuickAddTodoItemTask = "\(bundleIdentifier).quickAddTodoItemTask"
        
        if shortcutItem.type == shortcutItemIdentifierQuickAddTodoItemTask {
            
            
            let storyboard = UIStoryboard.init(name: "DVMultipleTodoitemtaskItems", bundle: nil)
            let tvc = storyboard.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsNC")
//
//            let transitionDelegate = DeckTransitioningDelegate(isSwipeToDismissEnabled: false)
//            tvc.transitioningDelegate = transitionDelegate
//            tvc.modalPresentationStyle = .custom
//            //            UIApplication.shared.statusBarStyle = .lightContent
//
//            self.present(tvc, animated: true, completion: nil)
            
            if let tabBarController = window?.rootViewController as? DailyVibesTabBarViewController {
                
                tabBarController.present(tvc, animated: true, completion: nil)
                
//                if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "AddNavigationVC") {
//                    tabBarController.present(newVC, animated: true)
//                }
                
            }
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        store.saveContext()
    }
    
    func makeTemplateData() {
        let today = Date()
        let mngdctx = store.context
        
        for day in 1...300 {
            let anotherday = today.subtract(days: day)
            
//            guard let newDateDescription = NSEntityDescription.entity(forEntityName: "LikertItemDate", in: mngdctx) else {
//                fatalError("need dat nsentitydescription for likertitementry")
//            }
            
//            let newDate = LikertItemDate.init(entity: newDateDescription, insertInto: mngdctx)
            
//            let newEntry = LikertItemEntry.init(entity: newEntryDescription, insertInto: mngdctx)
            
//            let newDate = LikertItemDate(context: mngdctx)
            
            
            guard let newDate = NSEntityDescription.insertNewObject(forEntityName: "LikertItemDate", into: mngdctx) as? LikertItemDate else {
                fatalError("need to do the insertNewObject func of LikertItemDate")
            }
            
            let date = anotherday
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            let dateSectionIndex = dateFormatter.string(from: date)
            
            //                    print("recent date is not today's date; making new one \(sectionIndex)")
            
            newDate.uuid = UUID()
            newDate.createdAt = date
            newDate.createdAtStr = dateSectionIndex
            newDate.updatedAt = date
            newDate.updatedAtStr = dateSectionIndex
            
//            let ratedValueHigh = newDate
            
            var dateRunningTotal = Float(0)
            
            for entry in 0...3 {
//                let newEntry = LikertItemEntry(context: mngdctx)
//                guard let newEntryDescription = NSEntityDescription.entity(forEntityName: "LikertItemEntry", in: mngdctx) else {
//                    fatalError("need dat nsentitydescription for likertitementry")
//                }
//
//                let newEntry = LikertItemEntry.init(entity: newEntryDescription, insertInto: mngdctx)
                
                guard let newEntry = NSEntityDescription.insertNewObject(forEntityName: "LikertItemEntry", into: mngdctx) as? LikertItemEntry else {
                    fatalError("need my nsentitydescription for likertitementry")
                }
                
                let entryDate = date.add(minutes: entry)
                let entrySectionIndex = dateFormatter.string(from: entryDate)
                
                newEntry.uuid = UUID()
                newEntry.createdAt = entryDate
                newEntry.createdAtStr = entrySectionIndex
                newEntry.updatedAt = entryDate
                newEntry.updatedAtStr = entrySectionIndex
                newEntry.date = newDate
                
                newDate.addToEntries(newEntry)
                
                var entryRunningTotal = Float(0)
                
                for scaleitem in 0...6 {
//                    guard let newLikertScaleItemDescription = NSEntityDescription.entity(forEntityName: "LikertScaleItem", in: mngdctx) else {
//                        fatalError("need dat nsentitydescription for likertitementry")
//                    }
//
//                    let item = LikertScaleItem.init(entity: newLikertScaleItemDescription, insertInto: mngdctx)
                    
                    guard let item = NSEntityDescription.insertNewObject(forEntityName: "LikertScaleItem", into: mngdctx) as? LikertScaleItem else {
                        fatalError("need my nsentitydescription for likertscaleitem")
                    }
                    
                    switch scaleitem {
                    case 0:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "motivation"
                        item.uuid = UUID()
                        item.pos = 0
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 1:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "mood"
                        item.uuid = UUID()
                        item.pos = 1
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 2:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "stress"
                        item.uuid = UUID()
                        item.pos = 2
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 3:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "vibes"
                        item.uuid = UUID()
                        item.pos = 3
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 4:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "work"
                        item.uuid = UUID()
                        item.pos = 4
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 5:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "life"
                        item.uuid = UUID()
                        item.pos = 5
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    case 6:
//                        let item = LikertScaleItem(context: mngdctx)
                        let randomvalue = Float.random(in: 0...10)
                        
                        item.type = "health"
                        item.uuid = UUID()
                        item.pos = 6
                        item.ratedValue = randomvalue
                        item.createdAt = entryDate
                        item.createdAtStr = entrySectionIndex
                        item.updatedAt = entryDate
                        item.updatedAtStr = entrySectionIndex
                        item.entry = newEntry
                        
                        entryRunningTotal = (entryRunningTotal + randomvalue)
                        newEntry.addToDpoints(item)
                    default:
                        print("defaut case")
                    }
                    
                }
                newEntry.runningTotal = entryRunningTotal
                dateRunningTotal = dateRunningTotal + entryRunningTotal
            }
            
            newDate.runningTotal = dateRunningTotal
        }
//        if mngdctx.hasChanges {
        if mngdctx.hasChanges {
            print("mngdctx.hasChanges")
            do {
//                try mngdctx.save()
                try mngdctx.save()
                print("saved mngdctx in maketemplatedata")
            } catch let error as NSError {
                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
            }
        }
    }
    
    func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.delegate = notificationDelegate
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
}
