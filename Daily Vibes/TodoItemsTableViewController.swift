//
//  TodoItemsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class TodoItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private enum SegmentOption {
        case inbox
        case archived
        case done
    }
    
    // MARK: Properties
    private var commitPredicate: NSPredicate?
    private var inArchiveView: Bool = false
    
    private var segmentPosition = SegmentOption.inbox
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    var moc: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController(with: segmentPosition)
        
        tableView.tableFooterView = UIView.init()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        hideOrShowTableView()
        
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TodoItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
        }
        
        if let todoItem = fetchedResultsController?.object(at: indexPath) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            if todoItem.completed {
                cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText!)
                cell.todoItemLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.emotionsImageView.image = UIImage(named: "checkedCheckbox")
                if let completedDate = todoItem.completedAt {
                    let dateString = dateFormatter.string(from: completedDate)
                    cell.todoItemTagsLabel.text = "Completed \(dateString)"
                    cell.todoItemTagsLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                }
            } else {
                cell.todoItemLabel.text = todoItem.todoItemText ?? "No Text"
                cell.todoItemLabel.textColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
                cell.emotionsImageView.image = UIImage(named: "uncheckedCheckbox")
//                cell.emotionsImageView.image = #imageLiteral(resourceName: "uncheckedFilledinCircle")
                let dateString = dateFormatter.string(from: todoItem.createdAt!)
                cell.todoItemTagsLabel.text = "Created \(dateString)"
            }
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            if let removeable = fetchedResultsController?.object(at: indexPath), let context = container?.viewContext {
//                context.delete(removeable)
//                do {
//                    try context.save()
//                } catch {
//                    context.rollback()
//                    fatalError("Could not remove because of error: \(error)")
//                }
//            }
//        }
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddTodoItem":
            guard let navigationViewController = segue.destination as? UINavigationController else {
                fatalError("should be UINavigationController for the AddTodoItem segue")
            }
            guard let todoItemViewController = navigationViewController.viewControllers.first as? TodoItemViewController else {
                fatalError("should be TodoItemViewController for the AddTodoItem segue")
            }
            todoItemViewController.setData(toProcess: nil, inContext: moc!)
        case "ShowTodoItemDetail":
            guard let todoItemDetailViewController = segue.destination as? TodoItemViewController else {
                fatalError("Unexpected destination = \(segue.destination)")
            }
            guard let selectedTodoItemCell = sender as? TodoItemTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTodoItemCell) else {
                fatalError("Selected sell is not being displayed on the table")
            }
            let _todoItem = fetchedResultsController?.object(at: indexPath)
            
            todoItemDetailViewController.setData(toProcess: _todoItem, inContext: moc)
        case "ShowSettings":
            print("Going to settings")
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            let sectionInfo = sections[section]
            
            if let todoItem: TodoItem = sectionInfo.objects?.first as? TodoItem {
                return sectionHeaderHelper(for: todoItem)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func sectionHeaderHelper(for item:TodoItem) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d yyyy"
        
        switch segmentPosition {
        case .inbox:
            let date = dateFormatter.string(from: item.createdAt!)
            return "\(date)"
        case .archived:
            let date = dateFormatter.string(from: item.archivedAt!)
            return "\(date)"
        case .done:
            let date = dateFormatter.string(from: item.completedAt!)
            return "\(date)"
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    // MARK: - Custom swipe right
    
    //    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let _todo = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Throw some errors =!!")
        }
        
        var actions = [UIContextualAction]()
        
        if !_todo.completed && !_todo.isArchived {
            let closeAction = UIContextualAction(style: .normal, title:  "Done", handler: { (ac:UIContextualAction, view:UIView, success:@escaping (Bool) -> Void) in
                
                let alert = UIAlertController(title: "Mark this task as done?", message: "This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, Mark this as Done", comment: "Default action"), style: .destructive, handler: { _ in
                    do {
                        _todo.markCompleted()
                        try self.moc!.save()
                        self.tableView.reloadData()
                    } catch {
                        self.moc!.rollback()
                        fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default cancel action"), style: .default, handler: { _ in
                    success(true)
                }))
                self.present(alert, animated: true, completion: nil)
            })
            
            actions.append(closeAction)
            //        closeAction.image = UIImage(named: "checkmark")
            closeAction.title = "Done"
            closeAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // MARK: - Overwriting trailingSwipeAction
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let _todo = fetchedResultsController?.object(at: indexPath) else {
            fatalError("todo should exist in trailingSwipeActionsConfigurationForRowAt")
        }
        if !_todo.isArchived {
            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
            let archiveAction = self.contextualToggleArchiveAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, archiveAction])
            return swipeConfig
        } else {
            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipeConfig
        }
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        if let removeable = fetchedResultsController?.object(at: indexPath), let context = container?.viewContext {
            
            let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
                
                let defaultLabelText = "this item"
                let todoLabel = "\"\(removeable.todoItemText ?? defaultLabelText)\""
                let alertController = UIAlertController(title: "Are you sure?", message: "You're about to delete \(todoLabel) forever", preferredStyle: .actionSheet)
                let delete = UIAlertAction(title: "Yes, Delete Forever.", style: .destructive, handler: { action in
                    
                    do {
                        context.delete(removeable)
                        try context.save()
                        completionHandler(true)
                    } catch {
                        context.rollback()
                        completionHandler(false)
                        fatalError("UIAlertAction failed to delete from context")
                    }
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
                    //this is optional, it makes the delete button go away on the cell
                    context.rollback()
                    completionHandler(true)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                })
                
                alertController.addAction(delete)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
            action.title = "Delete"
            action.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            return action
        } else {
            return UIContextualAction.init()
        }
    }
    
    private func contextualToggleArchiveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        if let _todoItem = fetchedResultsController?.object(at: indexPath), let context = container?.viewContext {
            
            if !_todoItem.isArchived {
                // if item is not archived... return action for user to archive
                
                let action = UIContextualAction(style: .normal, title: "Archive") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                    if _todoItem.archive() {
                        do {
                            try context.save()
                            completionHandler(true)
                        } catch {
                            context.rollback()
                            completionHandler(false)
                            fatalError("Could not remove because of error: \(error)")
                        }
                        
                    }
                }
                
                // 7
                action.title = "Archive"
                action.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                return action
            } else {
                // if item is archived... return an empty action
                return UIContextualAction.init()
            }
        } else {
            // otherwise always return nothing
            return UIContextualAction.init()
        }
    }

    
    // MARK: - Actions
    @IBAction func segmentedControllerEventHandler(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // handle the all view
            segmentPosition = .inbox
            initializeFetchedResultsController(with: segmentPosition)
            self.tableView.reloadData()
            hideOrShowTableView()
        }
        if sender.selectedSegmentIndex == 1 {
            //handle done view
            segmentPosition = .done
            initializeFetchedResultsController(with: segmentPosition)
            self.tableView.reloadData()
            hideOrShowTableView()
        }
        if sender.selectedSegmentIndex == 2 {
            //handle archived view
            segmentPosition = .archived
            initializeFetchedResultsController(with: segmentPosition)
            self.tableView.reloadData()
            hideOrShowTableView()
        }
    }
    
    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
        // do nothing
        // this methods used to have a lot of logic
        // now this method does nothing
        // the logic is still here because a button in TodoItemViewController (save) calls this action
        // need to figure out how to do this action without having this method here
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        hideOrShowTableView()
    }
    
    // MARK: - Helpers
    
    private func stringStrikeThrough(input: String) -> NSMutableAttributedString {
        // based on - https://stackoverflow.com/q/44152721
        let result = NSMutableAttributedString(string: input)
        let range = (input as NSString).range(of: input)
        result.addAttribute(NSAttributedStringKey.strikethroughStyle,
                            value: NSUnderlineStyle.styleSingle.rawValue,
                            range: range)
        return result;
    }
    
    private func initializeFetchedResultsController(with segmentPosition:SegmentOption) {
        self.moc = container?.viewContext
        if let context = container?.viewContext {
            let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
            
            switch segmentPosition {
            case .inbox:
                // process inbox data
                request.predicate = NSPredicate(format: "isArchived != true AND completed != true")
                let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
                let createdAtYearDayNumber = NSSortDescriptor(key: "createdAtYearDayNumber", ascending: false)
                request.sortDescriptors = [createdAt, createdAtYearDayNumber]
                fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "createdAtYearDayNumber", cacheName: nil)
                fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            case .archived:
                // process archived data
                request.predicate = NSPredicate(format: "isArchived = true")
                let archivedAt = NSSortDescriptor(key: "archivedAt", ascending: false)
                let archivedAtYearDayNumber = NSSortDescriptor(key: "archivedAtYearDayNumber", ascending: false)
                request.sortDescriptors = [archivedAt, archivedAtYearDayNumber]
                fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "archivedAtYearDayNumber", cacheName: nil)
                fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            case .done:
                //process done data
                request.predicate = NSPredicate(format: "isArchived != true AND completed = true")
                let completedAt = NSSortDescriptor(key: "completedAt", ascending: false)
                let completedAtYearDayNumber = NSSortDescriptor(key: "completedAtYearDayNumber", ascending: false)
                request.sortDescriptors = [completedAt, completedAtYearDayNumber]
                fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "completedAtYearDayNumber", cacheName: nil)
                fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            }
            
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    private func hideOrShowTableView() {
        if let count = fetchedResultsController.fetchedObjects?.count, count == 0 {
            guard let view = tableView as? TodoItemUITableView else {
                fatalError("hideOrShowTableView - Fail couldn't claim the view as TodoItemUITableView")
            }
            view.showEmptyView()
        } else {
            guard let view = tableView as? TodoItemUITableView else {
                fatalError("hideOrShowTableView - Fail couldn't claim the view as TodoItemUITableView")
            }
            view.hideEmptyView()
        }
    }
}
