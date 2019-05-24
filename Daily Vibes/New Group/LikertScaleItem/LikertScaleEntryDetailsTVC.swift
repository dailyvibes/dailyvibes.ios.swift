//
//  LikertScaleEntryDetailsTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-28.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class LikertScaleEntryDetailsTVC: ThemableTableViewController {
    
    var uuid: UUID?
    var entry: LikertItemEntry?
    var data: [LikertScaleItem] = [LikertScaleItem]()
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    private var mngdctx = CoreDataManager.store.context
    
    lazy var deleteBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItem))
        
        btn.accessibilityIdentifier = "likert_scale_item_details_delete_btn"
        
        return btn
    }()
    
    lazy var edit: UIBarButtonItem = {
        let btn = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(handleEditBtn))
        
        btn.accessibilityIdentifier = "likert_scale_item_details_edit_btn"
        
        return btn
    }()
    
    @objc
    func handleEditBtn() {
        let storyboard = UIStoryboard(name: "LikertScaleItemUI", bundle: nil)
        //
        guard let vc = storyboard.instantiateViewController(withIdentifier: "LikertScaleItemDetailsTableViewController") as? LikertScaleItemDetailsTableViewController else {
            fatalError("need dat LikertScaleItemDetailsTableViewController controller")
        }
        
        guard let parent = self.entry, let parentDate = parent.date else {
            //close the view controller a state after editing the main entry
//            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return
//            fatalError("entry needs to have a date object associated")
        }
        
        vc.entry = self.entry
        vc.date = parentDate
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.theme_barTintColor = "Global.barTintColor"
        navigationController.navigationBar.barStyle = .blackTranslucent
        
        present(navigationController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.allowsSelection = false
        
        fetchEntryData()
        
        self.tableView.reloadData()
        
        setupUI()
        setupNavigation()
//        navigationController?.isToolbarHidden = false
//        setToolbarItems([deleteBtn], animated: true)
    }
    
    private func setupUI() {
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
    }
    
    private func setupNavigation() {
        //        let dateFormatter = ISO8601DateFormatter()
        //        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        //        let todaysDate = dateFormatter.string(from: Date())
        
        guard let _entry = entry, let createdAt = _entry.createdAt else {
            fatalError("date had missing createdAt date")
        }
        
        let _formttr = DateFormatter()
        _formttr.dateStyle = .medium
        _formttr.timeStyle = .short
        
        let formattedDate = _formttr.string(from: createdAt)
        let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")
        
        if let _time = manipulatedFormattedDate.last {
            //            title.text = _time
            //            subTitle.text = _date
            //            detail.text = "↑"
            //           setupNavigationTitleText(title: _date, subtitle: nil)
//            setupVCTwoLineTitle(withTitle: _time, withSubtitle: nil)
//            navigationController?.navigationBar.largeTitleTextAttributes
            navigationItem.title = _time
            navigationItem.rightBarButtonItems = [edit]
//            if _entry.runningTotal.isLessThanOrEqualTo(35) {
//                navigationItem.rightBarButtonItems = [goingDown]
//            } else {
//                navigationItem.rightBarButtonItems = [goingUp]
//            }
        }
    }
    
    private func fetchEntryData() {
        
        if let _uuid = uuid {
//            let request: NSFetchRequest<NSFetchRequestResult> = LikertItemEntry.fetchRequest()
            let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LikertItemEntry")
            
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [_uuid])
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.relationshipKeyPathsForPrefetching = ["dpoints"]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.store.context, sectionNameKeyPath: nil, cacheName: nil)
//            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
                
                if let _result = fetchedResultsController.fetchedObjects as? [LikertItemEntry],
                    let top = _result.first,
                    let dpoints = top.dpoints,
                    let convrtedDpoints = dpoints.allObjects as? [LikertScaleItem] {
                    data = convrtedDpoints.sorted(by: { (item1, item2) -> Bool in
                        return item1.pos < item2.pos
                    })
                }
            } catch let error as NSError {
                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
            }
        }
    }
    
    /**
     * toggle was from https://stackoverflow.com/a/52678523
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source
    
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
        if data.count > 0 {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mvpLikertItemCell001", for: indexPath)
        
        let object = data[indexPath.row]
        
        //        cell.data = object
        
        var symbol: String = "↑"
        
        let magicfloat = Float(5.0)
        let _value = object.ratedValue
        
        if let type = object.type, type == "stress" {
            if _value.isEqual(to: magicfloat) {
                symbol = "="
                cell.detailTextLabel?.textColor = .orange
            } else if _value.isLess(than: magicfloat) {
                symbol = "↓"
                cell.detailTextLabel?.textColor = .whatsNewKitGreen
            } else {
                symbol = "↑"
                cell.detailTextLabel?.textColor = .whatsNewKitRed
            }
        } else {
            if _value.isEqual(to: magicfloat) {
                symbol = "="
                cell.detailTextLabel?.textColor = .orange
            } else if _value.isLess(than: magicfloat) {
                symbol = "↓"
                cell.detailTextLabel?.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                cell.detailTextLabel?.textColor = .whatsNewKitGreen
            }
        }
        
//        let label = object.ratedValue > 5 ? "↑" : "↓"
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.textLabel?.text = object.type
//        cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        cell.detailTextLabel?.text = symbol
        
        return cell
    }
    
    @objc
    func deleteItem() {
        let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
        let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
        let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
        
        let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { [unowned self] _ in
            guard let _entry = self.entry, let uuid = _entry.uuid else { fatalError("need that uuid item") }
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
        let request = NSFetchRequest<LikertItemEntry>(entityName: "LikertItemEntry")
        
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
            
//            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
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
    
}
