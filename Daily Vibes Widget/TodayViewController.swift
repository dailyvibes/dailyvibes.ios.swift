//
//  TodayViewController.swift
//  Daily Vibes Widget
//
//  Created by Alex Kluew on 2017-11-12.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UITableViewController, NCWidgetProviding, NSFetchedResultsControllerDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    
    var moc: NSManagedObjectContext?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
