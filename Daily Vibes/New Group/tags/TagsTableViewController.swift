//
//  TagsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-20.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

struct TagCreator {
    private var location = IndexPath(row: 0, section:0)
    
    func isLocated(at indexPath: IndexPath?) -> Bool {
        if indexPath!.row == location.row && indexPath!.section == location.section {
            return true
        } else {
            return false
        }
    }
}

class TagsTableViewController: ThemableTableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    private var tagCreator = TagCreator()
    private var todoItemSettingsData: TodoItemSettingsData?
    
    // flip to ensure that the cell at position 0 in cellForRowAt is only used once
    private var addingNewCell: Bool = false
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.store.persistentContainer
    private var fetchedResultsController: NSFetchedResultsController<Tag>!
    private var moc: NSManagedObjectContext?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleString = "Tags"
        setupNavigationTitleText(title: titleString)
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - configure func
    func configure(todoItemSettingsData data: TodoItemSettingsData) {
        self.todoItemSettingsData = data
        self.moc = container?.viewContext
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController?.fetchedObjects?.count)! + 1;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt === row \(indexPath.row) === section \(indexPath.section)")
        
        let displayCell = "tagsDisplayCell"
        let createCell = "tagsCreateCell"
        
        if tagCreator.isLocated(at: indexPath) {
            // create
            let cell = tableView.dequeueReusableCell(withIdentifier: createCell, for: indexPath) as! TagsCreationTableViewCell
            cell.tagLabeler.delegate = self
//            cell.theme_backgroundColor = "Global.barTintColor"
//            cell.theme_tintColor = "Global.textColor"
//            cell.tagLabeler.theme_backgroundColor = "Global.barTintColor"
//            cell.tagLabeler.theme_tintColor = "Global.textColor"
//            cell.tagLabeler.theme_textColor = "Global.textColor"
            return cell
        } else {
            guard let data = todoItemSettingsData else { fatalError("todoItemSettingsData should be set by now") }
            // display
            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
            // we need adjustedIndexPath b/c our initial row is set to input row
            // so we just need to adjust for the row that we are getting
            // and we are only having 1 section for the forseable future
            let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: indexPath.section)
            if let tag = fetchedResultsController?.object(at: adjustedIndexPath) {
                cell.imageView?.image = #imageLiteral(resourceName: "tagsFilledinCircle")
                cell.textLabel?.text = tag.label
                if data.contains(tag: tag) {
                    cell.accessoryType = .checkmark
//                    cell.tintColor = .orange
                } else {
                    cell.accessoryType = .none
                }
            }
            cell.theme_backgroundColor = "Global.barTintColor"
            cell.textLabel?.theme_textColor = "Global.textColor"
            cell.theme_tintColor = "Global.barTextColor"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // removed this because we would need to adjust the indexPath
        // and coredata should be doing this update via calling cellForRowAt after the save
//        tableView.deselectRow(at: indexPath, animated: true)

        let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: 0)
        
        if !tagCreator.isLocated(at: indexPath) {
            // don't want anything to happen when people select the first row
            if let tag = fetchedResultsController?.object(at: adjustedIndexPath) {
                
                guard let data = todoItemSettingsData else { fatalError("should have todoItemSettingsData by here") }
                
                guard data.addOrRemove(this: tag) else {
                    fatalError("should have processed data")
                }
                
                tableView.reloadData()
            }
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if tagCreator.isLocated(at: indexPath) {
            return false
        }
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: indexPath.section)
            if let removable = fetchedResultsController?.object(at: adjustedIndexPath), let context = moc {
                context.delete(removable)
                do {
                    try context.save()
                } catch {
                    context.rollback()
                    fatalError("could not remove in TagsTableViewController")
                }
                guard let data = todoItemSettingsData else { fatalError("this must exist") }
                guard data.addOrRemove(this: removable) else {
                    fatalError("this should not fail")
                }
            }
        }   
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tagLabel = textField.text, !tagLabel.isEmpty {
            let tag = Tag.createTag(in: moc!)
            tag.label = tagLabel
            
            guard let data = todoItemSettingsData else { fatalError("todoItemSettingsData should be set") }

            if let context = moc {
                do {
                    try context.save()
                    clearTextfield(at: textField)
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                    context.rollback()
                    fatalError("textFieldDidEndEditing failed")
                }
            }
            
            guard data.addOrRemove(this: tag) else {
                fatalError("should ")
            }
            
            tableView.reloadData()
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
            // toggle addingNewCell to ensure its inserted at position 0 with correct type of cell
            // we need it to insert at row 1 section 0 in the table
            let rowAdjuster = newIndexPath!.row + 1
            let adjustInsertIndexPath = IndexPath(row: rowAdjuster, section: newIndexPath!.section)
            addingNewCell = true
            tableView.insertRows(at: [adjustInsertIndexPath], with: .fade)
        case .delete:
            // deleteing row 3 section 0
            // thus... should delete row 3 section 0 from table
            // should delete row 2 section 0 from fetchedResultsController
            let rowAdjuster = indexPath!.row + 1
            let adjustedIndexPath = IndexPath(row: rowAdjuster, section: indexPath!.section)
            tableView.deleteRows(at: [adjustedIndexPath], with: .fade)
        case .update:
//            print("calling update")
//            printIndexPath(indexPath: indexPath)
            let rowAdjuster = indexPath!.row + 1
            let adjustedIndexPath = IndexPath(row: rowAdjuster, section: indexPath!.section)
//            print("calling update -- adjustedIndexPath")
//            printIndexPath(indexPath: adjustedIndexPath)
            tableView.reloadRows(at: [adjustedIndexPath], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - private
    private func adjustedRow(_ row: Int) -> Int {
        return row - 1
    }
    
    private func clearTextfield(at textField: UITextField) {
        textField.text = String()
    }
    
    private func initializeFetchedResultsController() {
        if let context = moc {
            let request = NSFetchRequest<Tag>(entityName: "Tag")
            let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
            
            request.sortDescriptors = [createdAt]
            fetchedResultsController = NSFetchedResultsController<Tag>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }

}
