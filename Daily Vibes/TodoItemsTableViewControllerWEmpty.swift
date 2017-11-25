//
//  TodoItemsTableViewControllerWEmpty.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-17.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import HGPlaceholders
import CoreData

class TodoItemsTableViewControllerWEmpty: TodoItemsTableViewController {
//    @IBOutlet var mainTableView: TableView!
    var mainTableView: TableView?
//    var placeholderTableView: TableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView = tableView as? TableView
//        mainTableView?.placeholderDelegate = self
        
//        mainTableView.placeholderDelegate = fetchedResultsController.delegate
//        updateTableViewLook()
//        tableView.tableFooterView = UIView()
//        print("viewDidLoad")
    }

    // MARK: - NSFetchedResultsControllerDelegate
    override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("controllerWillChangeContent override")
        super.controllerWillChangeContent(controller)
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("controllerDidChangeContent override")
        super.controllerDidChangeContent(controller)
//        updateTableViewLook()
//        print("table view should have updated")
    }
}

//extension TodoItemsTableViewControllerWEmpty: PlaceholderDelegate {
//
//    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
////        print(placeholder.key.value)
//        mainTableView?.showDefault()
//    }
//
//}

