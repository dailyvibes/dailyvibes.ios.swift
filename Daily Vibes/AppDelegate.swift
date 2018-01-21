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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    let store = CoreDataManager.store
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        
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
        
//        http://d.pr/97Hx8g
//        if(!NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch1.0")){
//            //Put any code here and it will be executed only once.
//            println("Is a first launch")
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstlaunch1.0")
//            NSUserDefaults.standardUserDefaults().synchronize();
//        }
        
//        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
//        if launchedBefore {
//        print("Has launched before")
//        } else {
//        print("First launch")
//        UserDefaults.standard.set(true, forKey: "launchedBefore")
//        }
//        
        // Override point for customization after application launch.
        
        // -------------------------- TODO REMOVE --------------------------
//        if let path = Bundle.main.path(forResource: "fakeDataDump-Jan202018", ofType: "json") {
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
        
        // default: Red.plist
        if let theme = MyThemes(rawValue: defaults.integer(forKey: "themeSelected")) {
            MyThemes.switchTo(theme)
        } else {
            ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
        }
        
        // status bar
        
//        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        
        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        
        // navigation bar
        
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.theme_tintColor = "Global.barTextColor"
        navigationBar.theme_barTintColor = "Global.barTintColor"
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.barTextColor") { value -> [NSAttributedStringKey : AnyObject]? in
            guard let rgba = value as? String else {
                return nil
            }
            
            let color = UIColor(rgba: rgba)
            let shadow = NSShadow(); shadow.shadowOffset = CGSize.zero
            let titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: color,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                NSAttributedStringKey.shadow: shadow
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
        
        return true
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
    
}
