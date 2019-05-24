//
//  LikertScaleItemTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-14.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class LikertScaleDateTVC: ThemableTableViewController {
    
    var dates = [LikertItemDate]()
    private var mngdctx = CoreDataManager.store.context
    var currDate: LikertItemDate?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // get data
        _fetchLikertItemDates()
        
        // setup ui stuff
        setupNavigation()
        setupUI()
    }
    
    private func setupNavigation() {
        let cancelBtn = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItems = [cancelBtn]

        setupVCTwoLineTitle(withTitle: "Your Daily Vibes", withSubtitle: nil)
    }
    
    private func setupUI() {
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
    }
    
    @objc
    func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func _fetchLikertItemDates() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LikertItemDate")
        let createdAt = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAt]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mngdctx, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
//            guard let results = fetchedResultsController.results
//            guard let results = fetchedResultsController.fet else {
//                fatalError("did not set current date properly based on core data results")
//            }
            //            entries = try mngdctx.fetch(fetchRequest) as! [LikertItemEntry]
        } catch let error as NSError {
            print("Could not complete _fetchLikertItemEntry. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
        view.theme_backgroundColor = "Global.backgroundColor"
        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
        label.font = UIFont.systemFont(ofSize: 14)
        label.theme_textColor = "Global.barTextColor"
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
        label.textAlignment = .center
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = fetchedResultsController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //        return 1
        //        return fetchedResultsController!.sections!.count
        //        guard let sections = fetchedResultsController!.sections else {
        //            fatalError("No sections in fetchedResultsController")
        //        }
        //        return sections.count
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        return entries.count
        //        return (fetchedResultsController?.sections?[0].numberOfObjects)!
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    private func printDate(forDate: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let todaysDate = dateFormatter.string(from: forDate)
        return todaysDate
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mvpEntryViewCell02", for: indexPath) as? LikertDataMVPTableViewCell else {
//            fatalError("Could not get the cell to dequeue")
//        }
//
//        guard let object = self.fetchedResultsController?.object(at: indexPath) as? LikertItemEntry else {
//            fatalError("Attempt to configure cell without a managed object")
//        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mvpEntryViewCell04", for: indexPath) as? LikertDataMVPDateTableViewCellTableViewCell else {
            fatalError("could not dequeue LikertDataMVPDateTableViewCellTableViewCell")
        }
        
        guard let dvDate = self.fetchedResultsController?.object(at: indexPath) as? LikertItemDate else {
            fatalError("Attempt to configure cell without an expected object")
        }
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
        cell.selectionStyle = .none
        
        cell.data = dvDate
        
//        cell.data = object
        // expanded cell
//        cell.delegate = self
        
        return cell
    }
    
    /*
     Override to support conditional editing of the table view. */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //        Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        guard let object = self.fetchedResultsController?.object(at: indexPath) as? LikertItemDate else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete Record", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
//            print("Are you sure?")
            
            let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
            let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
            let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
            let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
            
            let alert = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: deleteAlertConfirmation, style: .destructive , handler: { [unowned self] _ in
//                let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
//                self.setupDataAndNavBar()
                self.destroyRecord(record: object)
            }))
            alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            success(true)
        })
//        modifyAction.image = UIImage(named: "hammer")
        let deleteLabel = NSLocalizedString("Delete", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete ***", comment: "")
        
        modifyAction.title = deleteLabel
        modifyAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    private func destroyRecord(record: LikertItemDate) {
        do {
            self.mngdctx.delete(record)
            try self.mngdctx.save()
        } catch {
            fatalError("tried to destroyRecord: \(record) and got error: \(error)")
        }
    }
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
        //        Get the new view controller using segue.destination.
        //        Pass the selected object to the new view controller.
        if segue.identifier == "LSIDTVCSegue" {
            if let nav = segue.destination as? UINavigationController, let goingto = nav.topViewController as? LikertScaleItemDetailsTableViewController {
                // need things
                
                let date = Date()
                
                let dateISOformatter = ISO8601DateFormatter()
                let datetimeNow = dateISOformatter.string(from: date)
                
                guard let convertedDate = dateISOformatter.date(from: datetimeNow) else {
                    fatalError("check strssSlider func")
                }
                
                let dateISOformatterForSections = ISO8601DateFormatter()
                dateISOformatterForSections.formatOptions = [.withFullDate, .withDashSeparatorInDate]
                let sectionIndex = dateISOformatterForSections.string(from: date)
                
                //                let dateCtx = LikertItemDate(context: mngctx)
                let entryCtx = LikertItemEntry(context: mngdctx)
                
                // setup entry
                entryCtx.uuid = UUID()
                entryCtx.createdAt = convertedDate
                entryCtx.createdAtStr = sectionIndex
                entryCtx.updatedAt = convertedDate
                entryCtx.updatedAtStr = sectionIndex
                
                guard let latestCreatedAtDate = self.currDate?.createdAt else {
                    fatalError("we need a current date")
                }
                
                if latestCreatedAtDate.isInToday {
                    goingto.date = self.currDate
                    entryCtx.date = self.currDate
                } else {
                    let date = LikertItemDate(context: mngdctx)
                    
                    date.uuid = UUID()
                    date.createdAt = convertedDate
                    date.createdAtStr = sectionIndex
                    date.updatedAt = convertedDate
                    date.updatedAtStr = sectionIndex
                    
                    goingto.date = date
                    entryCtx.date = date
                }
                
                // prepare
                goingto.entry = entryCtx
                goingto.ctx = self.mngdctx
            }
        }
        
        if segue.identifier == "showDateEntries" {
//            if let nav = segue.destination as? UIStoryboardSegue, let goingto = nav.destination {
//
//            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let object = self.fetchedResultsController.object(at: indexPath) as? LikertItemDate else {
                    fatalError("need LikertItemDate here")
                }
                
                guard let goingto = segue.destination as? LikertScaleItemEntryTVC else {
                    fatalError("need LikertScaleItemEntryTVC")
                }
                
                
                goingto.uuid = object.uuid
                goingto.data = object

        } else {
            fatalError("expecting LikertScaleItemEntryTVC")
        }
    }
    }
}

extension LikertScaleDateTVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
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
}

//extension LikertScaleItemTableViewController: LikertDataMVPTableViewCellDelegate {
//    func expandableCellLayoutChanged(_ expandableCell: LikertDataMVPTableViewCell) {
//        refreshTableAfterCellExpansion()
//    }
//
//    func refreshTableAfterCellExpansion() {
//        self.tableView.beginUpdates()
//        self.tableView.setNeedsDisplay()
//        self.tableView.endUpdates()
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? LikertDataMVPTableViewCell {
//            cell.isExpanded = true
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? LikertDataMVPTableViewCell {
//            cell.isExpanded = false
//        }
//    }
//}
