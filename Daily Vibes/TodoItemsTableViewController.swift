//
//  TodoItemsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import os.log

class TodoItemsTableViewController: UITableViewController {
    
    // MARK: Properties
    var todoItems = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        loadSampleTodos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TodoItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
        }
        
        let todoItem = todoItems[indexPath.row]
        var tagText = ""

        // Configure the cell...
        if let tags = todoItem.tags {
            tagText = tags.joined(separator: " ")
        } else {
            tagText = "#Add #some #tags"
        }
        
        cell.todoItemTagsLabel.text = tagText
        
        if todoItem.completed {
            /*
            let attrString = NSAttributedString(todoItem.todoItemText,
                                                    UIStringAttributes { StrikethroughStyle = NSUnderlineStyle.Single })
            */
//            let attribute = [NSAttributedStringKey.strikethroughStyle : 2]
//            self.attributedText = attributedString
            
            /*
             Type 1
 
            let attributedString = NSMutableAttributedString(string: todoItem.todoItemText)
            attributedString.addAttribute(NSAttributedStringKey.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributedString.length))
            cell.todoItemLabel.attributedText = attributedString
            */
            
            /*
             TYPE 2 - works - https://stackoverflow.com/q/44152721
             */
             cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText)
            
            cell.emotionsImageView.image = UIImage(named: "checkedCheckbox")
        } else {
            cell.todoItemLabel.text = todoItem.todoItemText
            cell.emotionsImageView.image = UIImage(named: "uncheckedCheckbox")
//            cell.emotionsImageView.image
//            cell.emotionsImageView.image = UIImageView(named: uncheckedCheckbox)
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
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            let selectedTodoItem = todoItems[indexPath.row]
            todoItemDetailViewController.todoItem = selectedTodoItem
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TodoItemViewController, let todoItem = sourceViewController.todoItem {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // update existing todo
                todoItems[selectedIndexPath.row] = todoItem
                if todoItem.completed {
                    os_log("this item was marked completed", log: OSLog.default, type: .debug)
                }
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // create a new to do
                let newIndexPath = IndexPath(row: todoItems.count, section: 0)
                todoItems.append(todoItem)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadSampleTodos() {
        guard let todo1 = TodoItem.init(todoItemText: "create a todo item", tags: ["producthunthackathon", "vibes"]) else {
            fatalError("Unable to instantiate todo1")
        }
        guard let todo2 = TodoItem.init(todoItemText: "create a second todo and add to array", tags: ["producthunthackathon", "vibes"]) else {
            fatalError("Unable to instantiate todo2")
        }
        guard let todo3 = TodoItem.init(todoItemText: "display this list", tags: ["producthunthackathon", "vibes"]) else {
            fatalError("Unable to instantiate todo3")
        }
        
        guard let todo4 = TodoItem.init(todoItemText: "completed task", tags: ["producthunthackathon", "vibes"]) else {
            fatalError("Unable to instantiate todo3")
        }
        
        todo4.markCompleted()
        
        todoItems += [todo1, todo2, todo3, todo4]
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

}
