//
//  LikertScaleDateTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-28.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData
import FSCalendar
import SwiftTheme

class LikertScaleDateTVC: ThemableTableViewController {

    
    @IBOutlet weak var dvcalendar: FSCalendar!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private var mngdctx = CoreDataManager.store.context
    
    var currDate: LikertItemDate?
//    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var readOnlyList: [LikertItemDate]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
        
        fetchData()
        setupUI()
        setupNavigation()
        
//        print("reloading calendardata")
        self.dvcalendar.reloadData()
//        print("setNeedsLayout")
        self.dvcalendar.setNeedsLayout()
        self.dvcalendar.setNeedsDisplay()
//        print("reloading tableviewdata")
        self.tableView.reloadData()
    }
    
    lazy var vibesCacheName : String = {
        return "vibes.main.cache"
    }()
    
    fileprivate func fetchData() {
//        let request: NSFetchRequest<NSFetchRequestResult> = LikertItemDate.fetchRequest()
        print("fetching data in fetchData()")
        
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LikertItemDate")
        let createdAtSort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [createdAtSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.store.context, sectionNameKeyPath: nil, cacheName: vibesCacheName)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("performed performFetch()")
            
            if let collection = fetchedResultsController.fetchedObjects as? [LikertItemDate],
                let topItem = collection.first,
                let createdAt = topItem.createdAt {
                
                if createdAt.isInToday {
                    // todays date is the one we want
                    print("using todays date that is on the stack")
                    currDate = topItem
                }
                
                readOnlyList = collection
                
                for xdate in collection.reversed() {
                    self.dvcalendar.select(xdate.createdAt)
                }
                
                print("performed dvcalendar.select in performFetch()")
                
            } else {
                
                if let dataCount = fetchedResultsController.fetchedObjects?.count {
                    print("have this many object : \(dataCount)")
                }
                
                print("performed nothing in performFetch()")
            }
        } catch let error as NSError {
            print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloatingBtn()
    
        dvcalendar.delegate = self
        dvcalendar.dataSource = self
        dvcalendar.today = nil
        dvcalendar.allowsMultipleSelection = true
        
        dvcalendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]

        dvcalendar.accessibilityIdentifier = "dvcalendar"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
//    @IBAction func deleteAll(_ sender: Any) {
//        showDeleteAction()
//    }
    
//    private func _delete() {
//        let request: NSFetchRequest<NSFetchRequestResult> = LikertItemDate.fetchRequest()
//        let delete = NSBatchDeleteRequest.init(fetchRequest: request)
//
//        do {
//            try mngdctx.execute(delete)
//            try mngdctx.save()
//            fetchData()
//            self.tableView.reloadData()
//        } catch let error as NSError {
//            print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
//        }
//    }
    
    private func setupUI() {
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        tableView.theme_sectionIndexBackgroundColor = "Global.backgroundColor"
        
        if let barTintColor = ThemeManager.value(for: "Global.barTintColor") as? String,
            let barTextColor = ThemeManager.value(for: "Global.barTextColor") as? String,
            let backgroundColor = ThemeManager.value(for: "Global.backgroundColor") as? String,
            let placeholderColor = ThemeManager.value(for: "Global.placeholderColor") as? String,
            let globalTextColor = ThemeManager.value(for: "Global.textColor") as? String {
            let barTintColor = UIColor.from(hex: barTintColor)
            let barTextColor = UIColor.from(hex: barTextColor)
            let bgColor = UIColor.from(hex: backgroundColor)
            let placeholderClr = UIColor.from(hex: placeholderColor)
            let textColor = UIColor.from(hex: globalTextColor)
            
            dvcalendar.backgroundColor = barTintColor
            dvcalendar.appearance.borderSelectionColor = barTextColor
            dvcalendar.appearance.selectionColor = barTextColor
            dvcalendar.appearance.titleSelectionColor = bgColor
            dvcalendar.appearance.titlePlaceholderColor = placeholderClr
            dvcalendar.appearance.titleDefaultColor = textColor
            dvcalendar.appearance.weekdayTextColor = textColor
            dvcalendar.appearance.headerTitleColor = barTextColor
            dvcalendar.calendarHeaderView.backgroundColor = bgColor
            //            dvcalendar.calendarHeaderView.tintColor = UIColor.from(hex: barTextColor)
        }
    }
    
    private func setupNavigation() {
        // remove shadow from navbar to blend into calendar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
//        let cancelBTN = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
//        self.navigationItem.leftBarButtonItems = [cancelBTN]
//        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
//        cancelBtn.accessibilityIdentifier = "dailyvibes_dates_done"
//        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveButton))
        
//        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let composeBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleComposeBtn))
//        let btnsize = 48
////        let composeBtnImage = #imageLiteral(resourceName: "dvHeartNavBarIcon")
//        let composeBtn = AAFloatingButton(frame: CGRect(x: 0, y: 0, width: btnsize, height: btnsize))
//
//        composeBtn.setImage(#imageLiteral(resourceName: "dvHeartNavBarIcon"), for: .normal)
//        composeBtn.buttonBackgroundColor = .whatsNewKitRed
//        composeBtn.addTarget(self, action: #selector(handleComposeBtn), for: .touchDown)
//        composeBtn.accessibilityIdentifier = "dailyvibes_compose_new_entry"
//
//        composeBtn.widthAnchor.constraint(equalToConstant: CGFloat(btnsize)).isActive = true
//        composeBtn.heightAnchor.constraint(equalToConstant: CGFloat(btnsize)).isActive = true
        
//        composeBtn.transform = CGAffineTransform(translationX: 10, y: -10)
        
//        guard let composeBtnItm = composeBtn.toBarButtonItem() else { fatalError("failed on getting dat AAFloatingButton") }
        
//        composeBtnItm.setBackgroundVerticalPositionAdjustment(-20, for: .default)
//        composeBtnItm.backgroundVerticalPositionAdjustment(for: .default)
        let vibesStr = NSLocalizedString("Vibes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Vibes **", comment: "")
        
        setupVCTwoLineTitle(withTitle: vibesStr, withSubtitle: nil)
//        navigationItem.title = "Vibes"
        
//        navigationController?.isToolbarHidden = false
//        navigationController?.toolbar.theme_barStyle = "Global.toolbarStyle"
//        navigationController?.toolbar.theme_tintColor = "Global.barTextColor"
        
//        make transparent toolbar but with a top header
//        navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//        navigationController?.toolbar.backgroundColor = .clear
//        navigationController?.toolbar.clipsToBounds = true
        
//        setToolbarItems([spacer, composeBtnItm], animated: true)
        
//        self.tableView.addSubview(composeBtn)
        
//        composeBtn.translatesAutoresizingMaskIntoConstraints = false
//        composeBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
//        composeBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
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
    
    lazy var composeBtn: AAFloatingButton = {
        let btnSize = CGFloat(48)
        
        let btnFrame = CGRect(x: 0, y: 0, width: btnSize, height: btnSize)
        let btn = AAFloatingButton(frame: btnFrame)
        
        let heartImg = #imageLiteral(resourceName: "dvHeartFilledIcon")
        let whiteHeartImg = heartImg.tint(color: .white)
        
        btn.setImage(whiteHeartImg, for: .normal)
        
        btn.buttonBackgroundColor = .whatsNewKitRed
        btn.addTarget(self, action: #selector(handleComposeBtn), for: .touchDown)
        btn.accessibilityIdentifier = "dailyvibes_compose_new_entry"
        
        return btn
    }()
    
    @objc
    func handleComposeBtn() {
        handleCompose()
    }
    
    func handleCompose() {
        let btnFeedback = UIImpactFeedbackGenerator(style: .light)
        btnFeedback.impactOccurred()
        
//        LikertScaleItemDetailsTableViewController
        let storyboard = UIStoryboard(name: "LikertScaleItemUI", bundle: nil)
        
//        guard let navcv = storyboard.instantiateViewController(withIdentifier: "dvLikertScaleItemDetailsNC") as? UINavigationController else {
//            fatalError("need dat DVLikertScaleItemUI controller")
//        }
        
//        guard let vc = navcv.topViewController as? LikertScaleItemDetailsTableViewController else {
//            fatalError("need dat LikertScaleItemDetailsTableViewController controller")
//        }
//
        guard let vc = storyboard.instantiateViewController(withIdentifier: "LikertScaleItemDetailsTableViewController") as? LikertScaleItemDetailsTableViewController else {
            fatalError("need dat LikertScaleItemDetailsTableViewController controller")
        }
        
//        guard let vc = gotovc as? LikertScaleItemDetailsTableViewController else {
//            fatalError("need dat LikertScaleItemDetailsTableViewController")
//        }
        
//        let date = Date()
//
//        let dateFomatter = DateFormatter()
//        dateFomatter.dateStyle = .medium
//        dateFomatter.timeStyle = .short
//        let sectionIndex = dateFomatter.string(from: date)
//
//        //            let item = LikertScaleItem(context: mngdctx)
//
//        print("making a new entry")
//
//        let newEntry = LikertItemEntry(context: mngdctx)
//
//        newEntry.uuid = UUID()
//        newEntry.createdAt = date
//        newEntry.createdAtStr = sectionIndex
//        newEntry.updatedAt = date
//        newEntry.updatedAtStr = sectionIndex
//        newEntry.date = currDate
        
//        print("setting vc with new entry and current date")
//        print("setting with date of : \(currDate ?? nil)")
        
//        vc.date = currDate
//        vc.entry = newEntry
        
//        let viewcontroller = self
        
        vc.date = currDate
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.theme_barTintColor = "Global.barTintColor"
        navigationController.navigationBar.barStyle = .blackTranslucent
        
        present(navigationController, animated: true, completion: nil)
//        present(vc, animated: true, completion: nil)
//        navigationController?.show(navcv, sender: self)
//        show(vc, sender: nil)
//        present(vc, animated: true, completion: nil)
        
//        if let top = UIApplication.shared.keyWindow?.rootViewController {
//            top.present(navcv, animated: true, completion: nil)
//        }
        
//        present(vc, animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
        
//        present(navigationController, animated: true, completion: nil)
        
//        navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
    }
    
//    @objc
//    func cancel() {
//        if mngdctx.hasChanges {
//            do {
//                mngdctx.rollback()
//                try mngdctx.save()
//            } catch let error as NSError {
//                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
//            }
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
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
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mvpEntryViewCell07", for: indexPath) as? LikertDataMVPDateTVCell002 else {
            fatalError("cannot deque LikertDataMVPDateTVCell002")
        }
        guard let object = self.fetchedResultsController?.object(at: indexPath) as? LikertItemDate else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.data = object
        
        // Configure the cell with data from the managed object.
        return cell
    }
    
    func selectTableCellBasedOn(date selectDate:Date) {
        guard let dates = self.fetchedResultsController?.fetchedObjects as? [LikertItemDate] else {
            fatalError("need some likertitemdates to work with")
        }
        
        for date in dates {
            if let createdAtDate = date.createdAt, createdAtDate.isSameDay(as: selectDate) {
                print("found createdate that is the same as selecteddate day")
                if let indexpath = self.fetchedResultsController.indexPath(forObject: date) {
                    print("scrolling to : \(indexpath)")
                    self.tableView.scrollToRow(at: indexpath, at: .middle, animated: true)
                    self.tableView.selectRow(at: indexpath, animated: true, scrollPosition: .middle)
                }
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LSIDTVCSegue" {
            guard let nav = segue.destination as? UINavigationController,
                let goto = nav.topViewController as? LikertScaleItemDetailsTableViewController else {
                fatalError("need LikertScaleItemDetailsTableViewController")
            }
            
            let date = Date()
            
            let dateFomatter = DateFormatter()
            dateFomatter.dateStyle = .medium
            dateFomatter.timeStyle = .short
            let sectionIndex = dateFomatter.string(from: date)
            
            let newEntry = LikertItemEntry(context: mngdctx)
            
            newEntry.uuid = UUID()
            newEntry.createdAt = date
            newEntry.createdAtStr = sectionIndex
            newEntry.updatedAt = date
            newEntry.updatedAtStr = sectionIndex
            newEntry.date = currDate
            newEntry.runningTotal = Float(0)
            
            goto.date = currDate
            goto.entry = newEntry
        }
        
        if segue.identifier == "showDateEntries" {
            guard let goto = segue.destination as? LikertScaleItemEntryTVC else {
                fatalError("need LikertScaleItemEntryTVC")
            }

            guard let _cell = sender as? LikertDataMVPDateTVCell002,
                let _data = _cell.data,
                let _uuid = _data.uuid else {
                fatalError("need that LikertDataMVPDateTVCell002")
            }
            
            goto.uuid = _uuid
            goto.data = _data
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteAction(forRowAt: indexPath)
        }
    }
    
    private func _delete(forRowAt indexPath: IndexPath) {
        do {
            guard let object = self.fetchedResultsController?.object(at: indexPath) as? LikertItemDate else {
                fatalError("Attempt to configure cell without a managed object")
            }
            
            self.mngdctx.delete(object)
            try self.mngdctx.save()
            
            self.fetchData()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
        }
    }
    
    func showDeleteAction(forRowAt indexPath: IndexPath) {
        let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
        let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
        let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
        
        let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { [unowned self] _ in
            self._delete(forRowAt: indexPath)
        })
        //
        let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        let cancel = UIAlertAction(title: cancelLabel, style: .cancel, handler: nil)
        //
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LikertScaleDateTVC : NSFetchedResultsControllerDelegate {
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

extension LikertScaleDateTVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        if let dates = self.readOnlyList {
//            let likertscaledates = dates.filter { (itemdate) -> Bool in
//                guard let createdat = itemdate.createdAt else {
//                    return false
//                }
//                if createdat.isInSameDay(date: date) {
//                    return true
//                } else {
//                    return false
//                }
//            }
////                        print("found likertscaledates")
//            if likertscaledates.isEmpty {
//                return 0
//            }
////                        print("likertscaledates is not empty")
//            if likertscaledates.count != 1 {
//                return 0
//            }
////                        print("likertscaledates is equal to one")
//            if let likertscaledate = likertscaledates.last {
//                if let entries = likertscaledate.entries {
//                    let count = entries.count
//                    return count > 0 ? 1 : 0
//                }
//            }
//        }
//
//        return 0
//    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
//
//        if let dates = self.readOnlyList {
//            let likertscaledates = dates.filter { (itemdate) -> Bool in
//                guard let createdat = itemdate.createdAt else {
//                    return false
//                }
//                if createdat.isInSameDay(date: date) {
//                    return true
//                } else {
//                    return false
//                }
//            }
////            print("found likertscaledates")
//            if likertscaledates.isEmpty {
//                return nil
//            }
////            print("likertscaledates is not empty")
//            if likertscaledates.count != 1 {
//                return nil
//            }
////            print("likertscaledates is equal to one")
//            if let likertscaledate = likertscaledates.last {
//                var colors = [UIColor]()
//                if let entries = likertscaledate.entries, entries.count > 0 {
//                    let MAGIC_35 = Float(35)
//                    let estDateTotal = Float(entries.count) * MAGIC_35
//
//                    let daterunningtotal = likertscaledate.runningTotal
//
//                    if daterunningtotal.isEqual(to: estDateTotal) {
//                        colors.append(.orange)
//                    } else if daterunningtotal.isLess(than: estDateTotal) {
//                        colors.append(.red)
//                    } else {
//                        colors.append(.green)
//                    }
//                }
//                return colors
//            }
//        }
//
//        return nil
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        selectTableCellBasedOn(date: date)
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
//    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        return super.cale
//    }
    
//    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
//        print("did deselect date \(self.dateFormatter.string(from: date))")
//        self.configureVisibleCells()
//    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- FSCalendarDataSource
    
//    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
//        if let dates = self.readOnlyList {
//            let likertscaledates = dates.filter { (itemdate) -> Bool in
//                guard let createdat = itemdate.createdAt else {
//                    return false
//                }
//                if createdat.isInSameDay(date: date) {
//                    return true
//                } else {
//                    return false
//                }
//            }
//            if likertscaledates.isEmpty {
//                return nil
//            }
//            if likertscaledates.count != 1 {
//                return nil
//            }
//            if let likertscaledate = likertscaledates.last {
//                if let entries = likertscaledate.entries {
//                    let count = entries.count
//
//                    return "\(count) entries"
//                }
//            }
//        }
//        return nil
//    }
    
//    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        guard self.lunar else {
//            return nil
//        }
//        return self.lunarFormatter.string(from: date)
//    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        if let dates = readOnlyList {
            if let lastEntry = dates.last {
                return lastEntry.createdAt ?? Date()
            }
        }
        return Date()
    }
//
    func maximumDate(for calendar: FSCalendar) -> Date {
        return currDate?.createdAt ?? Date()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        if let dates = readOnlyList {
            for _dateentry in dates {
                if let createdat = _dateentry.createdAt, createdat.isSameDay(as: date) {
                    let count = Float(_dateentry.entries?.count ?? 0)
                    let MAGIC_NUMBER = Float(35)
                    
                    let baseline = count * MAGIC_NUMBER
                    
                    if _dateentry.runningTotal.isEqual(to: baseline) {
                        return .orange
                    } else if _dateentry.runningTotal.isLess(than: baseline) {
                        return .whatsNewKitRed
                    } else {
                        return .whatsNewKitGreen
                    }
                }
            }
        }
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        if let dates = readOnlyList {
            for _dateentry in dates {
                if let createdat = _dateentry.createdAt, createdat.isSameDay(as: date) {
                    let count = Float(_dateentry.entries?.count ?? 0)
                    let MAGIC_NUMBER = Float(35)
                    
                    let baseline = count * MAGIC_NUMBER
                    
                    if _dateentry.runningTotal.isEqual(to: baseline) {
                        return .orange
                    } else if _dateentry.runningTotal.isLess(than: baseline) {
                        return .whatsNewKitRed
                    } else {
                        return .whatsNewKitGreen
                    }
                }
            }
        }
        return appearance.borderSelectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        if let dates = readOnlyList {
            for _dateentry in dates {
                if let createdat = _dateentry.createdAt, createdat.isSameDay(as: date) {
                    let count = Float(_dateentry.entries?.count ?? 0)
                    let MAGIC_NUMBER = Float(35)
                    
                    let baseline = count * MAGIC_NUMBER
                    
                    if _dateentry.runningTotal.isEqual(to: baseline) {
                        return .black
                    } else if _dateentry.runningTotal.isLess(than: baseline) {
                        return .black
                    } else {
                        return .black
                    }
                }
            }
        }
        return appearance.titleSelectionColor
    }
//
//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        if let dates = self.readOnlyList {
//            let likertscaledates = dates.filter { (itemdate) -> Bool in
//                guard let createdat = itemdate.createdAt else {
//                    return false
//                }
//                if createdat.isInSameDay(date: date) {
//                    return true
//                } else {
//                    return false
//                }
//            }
//            //            print("found likertscaledates")
//            if likertscaledates.isEmpty {
//                return 0
//            }
//            //            print("likertscaledates is not empty")
//            if likertscaledates.count != 1 {
//                return 0
//            }
//            //            print("likertscaledates is equal to one")
//            if let likertscaledate = likertscaledates.last {
//                if let entries = likertscaledate.entries {
//                    let count = entries.count
//
//                    return count
//                }
//            }
//        }
//        return 0
//    }
//
//    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
//        if let dates = self.readOnlyList {
//            let likertscaledates = dates.filter { (itemdate) -> Bool in
//                guard let createdat = itemdate.createdAt else {
//                    return false
//                }
//                if createdat.isInSameDay(date: date) {
//                    return true
//                } else {
//                    return false
//                }
//            }
//            if likertscaledates.isEmpty {
//                return nil
//            }
//            if likertscaledates.count != 1 {
//                return nil
//            }
//            if let likertscaledate = likertscaledates.last {
//                if let entries = likertscaledate.entries {
//                    let count = entries.count
//
//                    let estTotal = Float(count) * Float(35)
//                    if likertscaledate.runningTotal.isEqual(to: estTotal) {
//                        print("returning neutral")
//                        return #imageLiteral(resourceName: "dvMinusOrange")
//                    } else if (likertscaledate.runningTotal.isLessThanOrEqualTo(estTotal)) {
//                        print("returning less than or equal to")
//                        return #imageLiteral(resourceName: "dvArrowDownRed")
//                    } else {
//                        print("returning positive")
//                        return #imageLiteral(resourceName: "dvArrowUpGreen")
//                    }
//                }
//            }
//        }
//        return nil
//    }
    
    // MARK:- FSCalendarDelegate
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        print("change page to \(self.formatter.string(from: calendar.currentPage))")
//    }
//
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        print("calendar did select date \(self.formatter.string(from: date))")
//        if monthPosition == .previous || monthPosition == .next {
//            calendar.setCurrentPage(date, animated: true)
//        }
//    }
//
//    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
//        self.dvcalendar.constant = bounds.height
//        self.view.layoutIfNeeded()
//    }
    
//    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
//        self.configure(cell: cell, for: date, at: position)
//    }
    
//    private func configureVisibleCells(using date: Date) {
//        dvcalendar.visibleCells().forEach { (cell) in
//            if let dvdate = dvcalendar.date(for: cell), dvdate.isInSameDay(date: date) {
//                print("selecting date: \(date)")
//                cell.isSelected = true
//            }
////            let position = dvcalendar.monthPosition(for: cell
////            self.configure(cell: cell, for: date!, at: position)
//        }
//    }
    
//    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
//        if let dateList = readOnlyList, !dateList.isEmpty {
//            for dateentry in dateList {
//                if let createdat = dateentry.createdAt, createdat.isSameDay(as: date) {
//                    cell.isSelected = true
//                }
//            }
//        }
//    }
}
