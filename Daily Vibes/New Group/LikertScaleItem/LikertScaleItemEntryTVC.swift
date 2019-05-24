//
//  LikertScaleItemEntryTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class LikertScaleItemEntryTVC: ThemableTableViewController {
    
    var uuid: UUID?
    var data: LikertItemDate?

    private var mngdctx = CoreDataManager.store.context
    var entries = [LikertItemEntry]()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    private func fetchDateEntries() {
        guard let searchUUID = uuid else {
            fatalError("need data's uuid")
        }
        
//        guard let searchCreatedAT = data?.createdAt else {
//            fatalError("need data's createdAt")
//        }
        
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LikertItemDate.fetchRequest()
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LikertItemDate")
        
//        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.relationshipKeyPathsForPrefetching = ["entries"]
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", argumentArray: [searchUUID])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.store.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            
            guard let result = fetchedResultsController.fetchedObjects as? [LikertItemDate],
                let topDate = result.first else {
                fatalError("need my LikertItemDate hurr")
            }
            
            data = topDate
            
            if let e = topDate.entries, let _entries = e.allObjects as? [LikertItemEntry] {
                entries = _entries.sorted(by: { (item1, item2) -> Bool in
                        return item1.createdAt! > item2.createdAt!
                })
            }
        } catch let error as NSError {
            print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
        }
    }
    
    lazy var composeBtn: AAFloatingButton = {
        let btnSize = CGFloat(48)
        
        let btnFrame = CGRect(x: 0, y: 0, width: btnSize, height: btnSize)
        let btn = AAFloatingButton(frame: btnFrame)
        
        let heartImg = #imageLiteral(resourceName: "dvHeartFilledIcon")
        let whiteHeartImg = heartImg.tint(color: .white)
        
        btn.setImage(whiteHeartImg, for: .normal)
        
        btn.buttonBackgroundColor = .whatsNewKitRed
        btn.addTarget(self, action: #selector(handleCompose), for: .touchDown)
        btn.accessibilityIdentifier = "dailyvibes_compose_new_entry"
        
        return btn
    }()
    
    @objc
    func handleCompose() {
//        print("handle compose")
        composeHandler()
    }
    
    fileprivate func composeHandler() {
//        print("handle composeHandler")
        
        let btnFeedback = UIImpactFeedbackGenerator(style: .light)
        btnFeedback.impactOccurred()
        
        let storyboard = UIStoryboard(name: "LikertScaleItemUI", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "LikertScaleItemDetailsTableViewController") as? LikertScaleItemDetailsTableViewController else { fatalError("need my LikertScaleItemDetailsTableViewController") }
        
        vc.date = data
        
        let nvc = UINavigationController(rootViewController: vc)
        nvc.navigationBar.isTranslucent = false
        nvc.navigationBar.theme_barTintColor = "Global.barTintColor"
        nvc.navigationBar.barStyle = .blackTranslucent
        
        present(nvc, animated: true, completion: nil)
    }
    
    fileprivate func setupFloatingBtn() {
        let btnSize = CGFloat(48)
        let btnPlacementOffset = CGFloat(-16)
        
        self.tableView.addSubview(composeBtn)
        composeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        composeBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        composeBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        
        composeBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: btnPlacementOffset).isActive = true
        composeBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btnPlacementOffset).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloatingBtn()
//        navigationItem.rightBarButtonItem = editButtonItem
//        navigationController?.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDateEntries()
        self.tableView.reloadData()
        setupUI()
        setupNavigation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /**
     issue with navbar being black background during transitions from one vc to another
     https://stackoverflow.com/a/25421617
    */
    
    private func setupUI() {
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.theme_backgroundColor = "Global.backgroundColor"
//        self.navigationItem.largeTitleDisplayMode = .never
//        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupNavigation() {
//        let dateFormatter = ISO8601DateFormatter()
//        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
//        let todaysDate = dateFormatter.string(from: Date())

        guard let createdAt = data?.createdAt else {
            fatalError("date had missing createdAt date")
        }

        let _formttr = DateFormatter()
        _formttr.dateStyle = .medium
        _formttr.timeStyle = .short

        let formattedDate = _formttr.string(from: createdAt)
        let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")

        if let _date = manipulatedFormattedDate.first {
//            title.text = _time
//            subTitle.text = _date
//            detail.text = "↑"
//           setupNavigationTitleText(title: _date, subtitle: nil)
//            setupVCTwoLineTitle(withTitle: _date, withSubtitle: nil)
//            navigationItem.largeTitleDisplayMode = .always
//            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.title = _date
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //            TODO:
//            print("gonna delete here at \(indexPath)")
            
            handleDelete(forRowAt: indexPath)
            fetchDateEntries()
            tableView.reloadData()
        }
    }
    
    fileprivate func handleDelete(forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LikertDataMVPEntryTVCell002 else {
            fatalError("cannot fin this cell of LikertDataMVPEntryTVCell002 type")
        }
        guard let data = cell.data else { fatalError("missing that LikertItemEntry entry") }
        guard let uuidtodelete = data.uuid else { fatalError("need that uuid to delete by") }
        
        // if runningTotal has no values -- simply delete
        // if runningTotal has values -- need to remove from day
        deleteItem(using: uuidtodelete)
        
    }
    
    @objc
    func deleteItem(using uuid:UUID) {
        let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
        let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
        let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
        
        let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { [unowned self] _ in
//            guard let _entry = self.entry, let uuid = _entry.uuid else { fatalError("need that uuid item") }
//            self.deleteEntry(using: uuid)
            self.deleteEntry(using: uuid)
        })
        //
        let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        let cancel = UIAlertAction(title: cancelLabel, style: .cancel, handler: nil)
        //
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func deleteEntry(using uuid:UUID) {
//        let request: NSFetchRequest<LikertItemEntry> = LikertItemEntry.fetchRequest()
        let request: NSFetchRequest<LikertItemEntry> = NSFetchRequest(entityName: "LikertItemEntry")
        
        request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [uuid])
        request.fetchLimit = 1
        
        do {
            guard var result = try? mngdctx.fetch(request) else {
                fatalError("failed on the delete")
            }
            
            guard let tobedeleted = result.popLast() else {
                fatalError("didn't find by uuid")
            }
            
            if tobedeleted.runningTotal.isZero {
                // delete
                print("running total is 0 so just removing")
                reduceDateRunningTotal(usingEntry: tobedeleted)
                mngdctx.delete(tobedeleted)
            } else {
                // cleaup
                print("running total is \(tobedeleted.runningTotal) so need to adjust")
                reduceDateRunningTotal(usingEntry: tobedeleted)
                mngdctx.delete(tobedeleted)
            }
            try mngdctx.save()
            print("deleted entry with uuid: \(uuid)")
            fetchDateEntries()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("error: \(error) with \(error.userInfo)")
        }
    }
    
    fileprivate func reduceDateRunningTotal(usingEntry entry:LikertItemEntry) {
        guard let date = entry.date else { fatalError("entry needs to belong to a date") }
        date.removeFromEntries(entry)
        print("date runningTotal before adjustment : \(date.runningTotal)")
        date.runningTotal = date.runningTotal - entry.runningTotal
        print("date runningTotal after adjustment : \(date.runningTotal)")
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
        view.theme_backgroundColor = "Global.backgroundColor"
        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
        label.font = UIFont.systemFont(ofSize: 14)
        label.theme_textColor = "Global.barTextColor"
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        view.addSubview(label)
        return view
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if entries.count > 0 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mvpEntryViewCell06", for: indexPath) as? LikertDataMVPEntryTVCell002 else {
            fatalError("need LikertDataMVPEntryTableViewCell here")
        }
        
        let object = entries[indexPath.row]
        
        cell.data = object

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            do {
//                guard let _todelete = data else { fatalError("need something to delete") }
//                
//                self.mngdctx.delete(_todelete)
//                try self.mngdctx.save()
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            } catch let error as NSError {
//                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
//            }
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            numbers.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
////        let section = taskItemsAll[indexPath.section]
////        let todoItemTask = section.object(at: indexPath)
//
//        guard
//
////        if !todoItemTask.isArchived {
////            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
////            let archiveAction = self.contextualToggleArchiveAction(forRowAtIndexPath: indexPath)
////            let swipeConfig = UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
////            return swipeConfig
////        } else {
////            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
////            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
////            return swipeConfig
////        }
//        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
//        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
//        return swipeConfig
//    }
//
//    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
//        let section = taskItemsAll[indexPath.section]
//        let removable = section.object(at: indexPath)
//        let deleteLabel = NSLocalizedString("Delete", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete ***", comment: "")
//
//        let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
//
//            let defaults = UserDefaults.standard
//            let showDoneAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
//
//            if showDoneAlert {
//                let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
//                let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
//                let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
//                let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
//
//                let alert = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
//                alert.addAction(UIAlertAction(title: deleteAlertConfirmation, style: .destructive , handler: { [unowned self] _ in
//                    let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
//                    self.setupDataAndNavBar()
//                }))
//                alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
//                self.setupDataAndNavBar()
//            }
//        }
//        action.title = deleteLabel
//        action.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
//        return action
//    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEntryItems" {
            guard let _sender = sender as? LikertDataMVPEntryTVCell002 else {
                fatalError("should be a LikertDataMVPEntryTableViewCell")
            }
            guard let goto = segue.destination as? LikertScaleEntryDetailsTVC else {
                fatalError("need LikertScaleItemEntryTVC")
            }
//            guard let nav = segue.destination as? UINavigationController else {
//                fatalError("Expecting UINavigationController")
//            }
//            guard let goto = nav.topViewController as? LikertScaleEntryDetailsTVC else {
//                fatalError("expecting LikertScaleEntryDetailsTVC")
//            }
            
            if let _data = _sender.data, let _createdat = _data.createdAt {
                let _formttr = DateFormatter()
                _formttr.dateStyle = .medium
                _formttr.timeStyle = .short
                
                let formattedDate = _formttr.string(from: _createdat)
                let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")
                
                if let _date = manipulatedFormattedDate.first {
                    let backItem = UIBarButtonItem()
                    backItem.title = _date
                    navigationItem.backBarButtonItem = backItem
                }
            }
            
            goto.uuid = _sender.data?.uuid
            goto.entry = _sender.data
            
            goto.hidesBottomBarWhenPushed = true
        }
    }
}

extension LikertScaleItemEntryTVC : NSFetchedResultsControllerDelegate {
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
}
