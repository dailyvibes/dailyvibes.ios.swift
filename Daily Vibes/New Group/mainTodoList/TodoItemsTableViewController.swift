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
    
    private enum FilteredOption {
        case none
        case byTag
    }
    
    private struct FiltrationData {
        var tag: Tag?
    }
    
    // MARK: Properties
    private var segmentPosition = SegmentOption.inbox
    private var filteredOption = FilteredOption.none
    private var filtrationData = FiltrationData()
    
    @IBOutlet private weak var segmentController: UISegmentedControl!
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    private var moc: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLocalization()
        
        initializeFetchedResultsController(with: segmentPosition)
        
        tableView.tableFooterView = UIView.init()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        hideOrShowTableView()
    }
    
    private func configLocalization() {
        setupSegmentControllerLocalization()
    }
    
    private func setupSegmentControllerLocalization() {
        let inboxLabel = NSLocalizedString("Inbox", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Inbox ***", comment: "")
        let doneLabel = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let archiveLabel = NSLocalizedString("Archive", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archive ***", comment: "")
        segmentController.setTitle(inboxLabel, forSegmentAt: 0)
        segmentController.setTitle(doneLabel, forSegmentAt: 1)
        segmentController.setTitle(archiveLabel, forSegmentAt: 2)
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddTodoItem":
            // TODO: REMOVE
            // this and move it to the TAB BAR action handler or somewhere else
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
            // TODO: REMOVE
            print("Going to settings")
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            let sectionInfo = sections[section]
            let sectionName = sectionInfo.name
            let numericSection = Int(sectionName)
            
            if let todoItem: TodoItem = sectionInfo.objects?.first as? TodoItem {
                return sectionHeaderHelper(for: todoItem, numericSection: numericSection)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func sectionHeaderHelper(for item:TodoItem, numericSection section: Int?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d yyyy"
        
        switch segmentPosition {
        case .inbox:
            guard let numericSection = section else { return "Nothing" }
            
            //            let date = dateFormatter.string(from: item.createdAt!)
            let year = numericSection / 10000
            let month = (numericSection / 100) % 100
            let day = numericSection % 100
            
            // Reconstruct the date from these components.
            var components = DateComponents()
            components.calendar = Calendar.current
            components.day = day
            components.month = month
            components.year = year
            
            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
            
            if let date = components.date {
                if Calendar.current.isDateInToday(date) {
                    return todayString
                }
                if Calendar.current.isDateInYesterday(date) {
                    return yesterdayString
                }
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            }
            return String()
        case .archived:
            //            let date = dateFormatter.string(from: item.archivedAt!)
            //            return "\(date)"
            guard let numericSection = section else { return "Nothing" }
            
            //            let date = dateFormatter.string(from: item.createdAt!)
            let year = numericSection / 10000
            let month = (numericSection / 100) % 100
            let day = numericSection % 100
            
            // Reconstruct the date from these components.
            var components = DateComponents()
            components.calendar = Calendar.current
            components.day = day
            components.month = month
            components.year = year
            
            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
            
            if let date = components.date {
                if Calendar.current.isDateInToday(date) {
                    return todayString
                }
                if Calendar.current.isDateInYesterday(date) {
                    return yesterdayString
                }
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            }
            return String()
        case .done:
            //            let date = dateFormatter.string(from: item.completedAt!)
            //            return "\(date)"
            guard let numericSection = section else { return "Nothing" }
            
            //            let date = dateFormatter.string(from: item.createdAt!)
            let year = numericSection / 10000
            let month = (numericSection / 100) % 100
            let day = numericSection % 100
            
            // Reconstruct the date from these components.
            var components = DateComponents()
            components.calendar = Calendar.current
            components.day = day
            components.month = month
            components.year = year
            
            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
            
            if let date = components.date {
                if Calendar.current.isDateInToday(date) {
                    return todayString
                }
                if Calendar.current.isDateInYesterday(date) {
                    return yesterdayString
                }
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            }
            return String()
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
            let doneLabel = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
            
            let closeAction = UIContextualAction(style: .normal, title: doneLabel, handler: { (ac:UIContextualAction, view:UIView, success:@escaping (Bool) -> Void) in
                let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
                let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
                let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
                let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
                
                let defaults = UserDefaults.standard
                let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
                
                if showDoneAlert {
                    let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .destructive, handler: { _ in
                        do {
                            _todo.markCompleted()
                            try self.moc!.save()
                            self.tableView.reloadData()
                            guard StreakManager.process(item: _todo) else {
                                fatalError("StreakManager should not fail")
                            }
                        } catch {
                            self.moc!.rollback()
                            fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
                        }
                    }))
                    alert.addAction(UIAlertAction(title: doneAlertCancel, style: .default, handler: { _ in
                        success(true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    do {
                        _todo.markCompleted()
                        try self.moc!.save()
                        self.tableView.reloadData()
                        guard StreakManager.process(item: _todo) else {
                            fatalError("StreakManager should not fail")
                        }
                    } catch {
                        self.moc!.rollback()
                        fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
                    }
                }
            })
            
            actions.append(closeAction)
            closeAction.title = doneLabel
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
            
            let deleteLabel = NSLocalizedString("Delete", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete ***", comment: "")
            let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
            let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
            let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
            
            let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
                
                let defaults = UserDefaults.standard
                let showDoneAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
                
                if showDoneAlert {
                    let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
                    let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { action in
                        
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
                    
                    let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
                    let cancel = UIAlertAction(title: cancelLabel, style: .cancel, handler: { action in
                        
                        //this is optional, it makes the delete button go away on the cell
                        context.rollback()
                        completionHandler(true)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                    
                    alertController.addAction(delete)
                    alertController.addAction(cancel)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    do {
                        context.delete(removeable)
                        try context.save()
                        completionHandler(true)
                    } catch {
                        context.rollback()
                        completionHandler(false)
                        fatalError("UIAlertAction failed to delete from context")
                    }
                }
            }
            action.title = deleteLabel
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
                let archiveLabel = NSLocalizedString("Archive", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archive ***", comment: "")
                
                let action = UIContextualAction(style: .normal, title: archiveLabel) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
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
                action.title = archiveLabel
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
            
            switch filteredOption {
            case .none:
                switch segmentPosition {
                case .inbox:
                    // process inbox data
                    request.predicate = NSPredicate(format: "isArchived != true AND completed != true")
                    let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
                    //                let createdAtYearDayNumber = NSSortDescriptor(key: "createdAtYearDayNumber", ascending: false)
                    //                request.sortDescriptors = [createdAt, createdAtYearDayNumber]
                    request.sortDescriptors = [createdAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "inboxDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                case .archived:
                    // process archived data
                    request.predicate = NSPredicate(format: "isArchived = true")
                    let archivedAt = NSSortDescriptor(key: "archivedAt", ascending: false)
                    //                let archivedAtYearDayNumber = NSSortDescriptor(key: "archivedAtYearDayNumber", ascending: false)
                    request.sortDescriptors = [archivedAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "archivedDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                case .done:
                    //process done data
                    request.predicate = NSPredicate(format: "isArchived != true AND completed = true")
                    let completedAt = NSSortDescriptor(key: "completedAt", ascending: false)
                    //                let completedAtYearDayNumber = NSSortDescriptor(key: "completedAtYearDayNumber", ascending: false)
                    request.sortDescriptors = [completedAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "doneDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                }
            case .byTag:
                switch segmentPosition {
                case .inbox:
                    // process inbox data
                    request.predicate = NSPredicate(format: "isArchived != true AND completed != true AND tagz.label CONTAINS[cd] %@", (filtrationData.tag?.label)!)
                    let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
                    //                let createdAtYearDayNumber = NSSortDescriptor(key: "createdAtYearDayNumber", ascending: false)
                    //                request.sortDescriptors = [createdAt, createdAtYearDayNumber]
                    request.sortDescriptors = [createdAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "inboxDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                case .archived:
                    // process archived data
                    request.predicate = NSPredicate(format: "isArchived = true AND tagz.label CONTAINS[cd] %@", (filtrationData.tag?.label)!)
                    let archivedAt = NSSortDescriptor(key: "archivedAt", ascending: false)
                    //                let archivedAtYearDayNumber = NSSortDescriptor(key: "archivedAtYearDayNumber", ascending: false)
                    request.sortDescriptors = [archivedAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "archivedDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                case .done:
                    //process done data
                    request.predicate = NSPredicate(format: "isArchived != true AND completed = true AND tagz.label CONTAINS[cd] %@", (filtrationData.tag?.label)!)
                    let completedAt = NSSortDescriptor(key: "completedAt", ascending: false)
                    //                let completedAtYearDayNumber = NSSortDescriptor(key: "completedAtYearDayNumber", ascending: false)
                    request.sortDescriptors = [completedAt]
                    fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "doneDaySectionIdentifier", cacheName: nil)
                    fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
                }
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
    
    func setupTodoItemsTVC(using filter: Tag?) {
        filteredOption = .byTag
        filtrationData.tag = filter
        let navigationBarLabel = filter?.label
        self.navigationItem.title = navigationBarLabel
    }
}
