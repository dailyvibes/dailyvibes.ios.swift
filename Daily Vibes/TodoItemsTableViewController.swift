//
//  TodoItemsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
//import os.log
import CoreData

class TodoItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
//    var todoItems = [TodoItem]()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    var moc: NSManagedObjectContext?
    
//    var emptyView: LoadingTableViewEmptyView = UINib(nibName: "LoadingTableViewEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! LoadingTableViewEmptyView
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        moc = container?.viewContext
//        initializeFetchedResultsController()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = container?.viewContext
        initializeFetchedResultsController()
        
        tableView.tableFooterView = UIView.init()
        
        hideOrShowTableView()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        
//        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        var bounds = view.bounds
//        bounds.size.height += 20
//        bounds.origin.y -= 20
//        visualEffectView.isUserInteractionEnabled = false
//        visualEffectView.frame = bounds
//        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        self.navigationController?.navigationBar.addSubview(visualEffectView)
//        visualEffectView.layer.zPosition = -1
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        //UI_Util.setGradientGreenBlue(uiView: self.view)
//        loadSampleTodos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        return 1
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return todoItems.count
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
                cell.emotionsImageView.image = UIImage(named: "checkedCheckbox")
                if let completedDate = todoItem.completedAt {
                    let dateString = dateFormatter.string(from: completedDate)
                    cell.todoItemTagsLabel.text = "Completed \(dateString)"
                }
            } else {
                cell.todoItemLabel.text = todoItem.todoItemText ?? "No Text"
                cell.emotionsImageView.image = UIImage(named: "uncheckedCheckbox")
                let dateString = dateFormatter.string(from: todoItem.createdAt!)
                cell.todoItemTagsLabel.text = "Created \(dateString)"
            }
//            cell.todoItemTagsLabel.text = todoItem.tags
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let removeable = fetchedResultsController?.object(at: indexPath), let context = container?.viewContext {
                context.delete(removeable)
                do {
                    try context.save()
                } catch {
                    context.rollback()
                    fatalError("Could not remove because of error: \(error)")
                }
            }
//            todoItems.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 2 && indexPath.row == 1 {
//            let height:CGFloat = web.hidden ? 0.0 : 216.0
//            return height
//        }
//        
//        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
//    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddTodoItem":
//            os_log("Adding todo item.", log: OSLog.default, type: .debug)
            let navVC = segue.destination as? UINavigationController
            let vC = navVC?.viewControllers.first as! TodoItemViewController
            vC.moc = moc
            vC.todoItem = TodoItem.createTodoItem(in: moc!)
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
//            let selectedTodoItem = todoItems[indexPath.row]
            // todoItemDetailViewController.todoItem = selectedTodoItem
            todoItemDetailViewController.todoItem = fetchedResultsController?.object(at: indexPath)
            todoItemDetailViewController.moc = moc
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            let sectionInfo = sections[section]
            if let todoItem: TodoItem = sectionInfo.objects?.first as? TodoItem, todoItem.completed {
                return "Done"
            } else {
                return "To do"
            }
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    // MARK: - Custom swipe right
    //    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Done", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if let todoItem = self.fetchedResultsController?.object(at: indexPath) {
                todoItem.markCompleted()
                do {
                    try self.moc!.save()
                } catch {
                    fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
                }
            }
            success(true)
        })
//        closeAction.image = UIImage(named: "checkmark")
        closeAction.title = "Done"
        closeAction.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [closeAction])

    }
    
    // MARK: - Actions
    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
//        do nothing
//        self.tableView.reloadData()
    }
    
    private func stringStrikeThrough(input: String) -> NSMutableAttributedString {
        // based on - https://stackoverflow.com/q/44152721
        let result = NSMutableAttributedString(string: input)
        let range = (input as NSString).range(of: input)
        result.addAttribute(NSAttributedStringKey.strikethroughStyle,
                             value: NSUnderlineStyle.styleSingle.rawValue,
                             range: range)
        return result;
    }
    
    private func initializeFetchedResultsController() {
        if let context = container?.viewContext {
            let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
            let completedSort = NSSortDescriptor(key: "completed", ascending: true)
            let completedAt = NSSortDescriptor(key: "completedAt", ascending: true)
            
            request.sortDescriptors = [completedSort, completedAt]
            fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "completed", cacheName: nil)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
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
