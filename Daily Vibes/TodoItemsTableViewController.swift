//
//  TodoItemsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import os.log
import CoreData

class TodoItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    var todoItems = [TodoItem]()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    
    var moc: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        moc = container?.viewContext
        initializeFetchedResultsController()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
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
            if todoItem.completed {
                cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText!)
                cell.emotionsImageView.image = UIImage(named: "checkedCheckbox")
            } else {
                cell.todoItemLabel.text = todoItem.todoItemText ?? "No Text"
                cell.emotionsImageView.image = UIImage(named: "uncheckedCheckbox")
            }
            cell.todoItemTagsLabel.text = todoItem.tags
        }
        
        return cell
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "TodoItemTableViewCell"
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
//            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
//        }
//
//        let todoItem = todoItems[indexPath.row]
//        var tagText = ""
//
//        // Configure the cell...
//        if let tags = todoItem.tags {
//            tagText = tags.joined(separator: " ")
//        } else {
//            tagText = "#Add #some #tags"
//        }
//
//        cell.todoItemTagsLabel.text = tagText
//
//        if todoItem.completed {
//            /*
//            let attrString = NSAttributedString(todoItem.todoItemText,
//                                                    UIStringAttributes { StrikethroughStyle = NSUnderlineStyle.Single })
//            */
////            let attribute = [NSAttributedStringKey.strikethroughStyle : 2]
////            self.attributedText = attributedString
//
//            /*
//             Type 1
//
//            let attributedString = NSMutableAttributedString(string: todoItem.todoItemText)
//            attributedString.addAttribute(NSAttributedStringKey.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributedString.length))
//            cell.todoItemLabel.attributedText = attributedString
//            */
//
//            /*
//             TYPE 2 - works - https://stackoverflow.com/q/44152721
//             */
//             cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText)
//
//            cell.emotionsImageView.image = UIImage(named: "checkedCheckbox")
//        } else {
//            cell.todoItemLabel.text = todoItem.todoItemText
//            cell.emotionsImageView.image = UIImage(named: "uncheckedCheckbox")
////            cell.emotionsImageView.image
////            cell.emotionsImageView.image = UIImageView(named: uncheckedCheckbox)
//        }
//
//        return cell
//    }

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
            os_log("Adding todo item.", log: OSLog.default, type: .debug)
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
                return "Completed"
            } else {
                return "Todo List"
            }
//            print("*** \(sections[section].name) - \(sections[section].indexTitle) - \(sections[section].numberOfObjects)***")
//            return "\(sections[section].numberOfObjects) Items"
//            return sections[section].name
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
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Complete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if let todoItem = self.fetchedResultsController?.object(at: indexPath) {
                todoItem.markCompleted()
                do {
                    try self.moc!.save()
                } catch {
                    print("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
                }
            }
            success(true)
        })
        closeAction.image = UIImage(named: "checkmark")
        closeAction.title = "Complete"
        closeAction.backgroundColor = .purple

        return UISwipeActionsConfiguration(actions: [closeAction])

    }

    
    // MARK: - Custom swipe left
//    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
//    override func tableView(_ tableView: UITableView,
//                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
//    {
//        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            print("Update action ...")
//            success(true)
//        })
//        modifyAction.image = UIImage(named: "hammer")
//        modifyAction.backgroundColor = .blue
//
//        return UISwipeActionsConfiguration(actions: [modifyAction])
//    }
    
    // MARK: - Actions
    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
        self.tableView.reloadData()
//        if let sourceViewController = sender.source as? TodoItemViewController, let todoItem = sourceViewController.todoItem {
//            if let selectedIndexPath = tableView.indexPathForSelectedRow {
//                // update existing todo
//                todoItems[selectedIndexPath.row] = todoItem
//                if todoItem.completed {
//                    os_log("this item was marked completed", log: OSLog.default, type: .debug)
//                }
//                tableView.reloadRows(at: [selectedIndexPath], with: .none)
//            } else {
//                // create a new to do
//                let newIndexPath = IndexPath(row: todoItems.count, section: 0)
//                todoItems.append(todoItem)
//                tableView.insertRows(at: [newIndexPath], with: .automatic)
//            }
//        }
    }
    
    // MARK: - Private Methods
//    private func loadSampleTodos() {
//        guard let todo1 = TodoItem.init(todoItemText: "create a todo item", tags: ["producthunthackathon", "vibes"]) else {
//            fatalError("Unable to instantiate todo1")
//        }
//        guard let todo2 = TodoItem.init(todoItemText: "create a second todo and add to array", tags: ["producthunthackathon", "vibes"]) else {
//            fatalError("Unable to instantiate todo2")
//        }
//        guard let todo3 = TodoItem.init(todoItemText: "display this list", tags: ["producthunthackathon", "vibes"]) else {
//            fatalError("Unable to instantiate todo3")
//        }
//
//        guard let todo4 = TodoItem.init(todoItemText: "completed task", tags: ["producthunthackathon", "vibes"]) else {
//            fatalError("Unable to instantiate todo3")
//        }
//
//        todo4.markCompleted()
//
//        todoItems += [todo1, todo2, todo3, todo4]
//    }
    
    private func stringStrikeThrough(input: String) -> NSMutableAttributedString {
        // based on - https://stackoverflow.com/q/44152721
        let result = NSMutableAttributedString(string: input)
        let range = (input as NSString).range(of: input)
        result.addAttribute(NSAttributedStringKey.strikethroughStyle,
                             value: NSUnderlineStyle.styleSingle.rawValue,
                             range: range)
        return result;
    }
    
    func initializeFetchedResultsController() {
        if let context = container?.viewContext {
            let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
            let completedSort = NSSortDescriptor(key: "completed", ascending: true)
            let createdAtSort = NSSortDescriptor(key: "createdAt", ascending: true)
            request.sortDescriptors = [completedSort, createdAtSort]
            fetchedResultsController = NSFetchedResultsController<TodoItem>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "completed", cacheName: nil)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
        printDatabaseStatistics()
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            if let todoItemCount = try? context.count(for: TodoItem.fetchRequest()) {
                print("\(todoItemCount) Todos")
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
    }
    
//    func gradient(frame:CGRect) -> CAGradientLayer {
//        let layer = CAGradientLayer()
//        layer.frame = frame
//        layer.startPoint = CGPointMake(0,0.5)
//        layer.endPoint = CGPointMake(1,0.5)
//        layer.colors = [
//            UIColor.red.cgColor,UIColor.blue.cgColor]
//        return layer
//    }
    
//    func setGradientBackground() {
//        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
//        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [ colorTop, colorBottom]
//        gradientLayer.locations = [ 0.0, 1.0]
//        gradientLayer.frame = self.view.bounds
//
//        self.layer.insertSublayer(gradientLayer)
//    }

}

//extension UIView{
//    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
//        clipsToBounds = true
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
//        gradientLayer.frame = self.bounds
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
//        print(gradientLayer.frame)
//        self.layer.insertSublayer(gradientLayer, at: 0)
//    }
//}

