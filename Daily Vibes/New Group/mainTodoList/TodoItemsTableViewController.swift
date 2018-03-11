//
//  TodoItemsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData
import SwiftTheme

enum SegmentOption {
    case inbox
    case archived
    case done
}

class TodoItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private var store = CoreDataManager.store
    
    private var taskItemsAll = [DVCoreSectionViewModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var dvRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.theme_tintColor = "Global.barTintColor"
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
//        do {
////            let jsonEncoder = JSONEncoder()
////            jsonEncoder.outputFormatting = .prettyPrinted
////            jsonEncoder.dateEncodingStrategy = .iso8601
////            store.filteredDvTodoItemTaskData
////            let jsonData = try jsonEncoder.encode(store.filteredDvTodoItemTaskData)
////            taskItemsAll = store.filteredDvTodoItemTaskData
//            
////            let jsonString = String(data: jsonData, encoding: .utf8)
//            
////            print(jsonString)
////            refreshControl.endRefreshing()
//        } catch {
//            
//        }
        print("refresh")
//        let newHotel = Hotels(name: "Montage Laguna Beach", place:
//            "California south")
//        hotels.append(newHotel)
//
//        hotels.sort() { $0.name < $0.place }
//
//        self.tableView.reloadData()
    }
    
    private var streakManager = StreakManager()
    private var dynamicNavigationBarLabel: String?
    
    fileprivate func setupDataAndNavBar() {
        var filterString: String = ""
        
        switch store.dvfilter {
        case .all:
            filterString = NSLocalizedString("All", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND All **", comment: "")
        case .completed:
            filterString = NSLocalizedString("Completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Completed **", comment: "")
        case .upcoming:
            filterString = NSLocalizedString("Upcoming", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Upcoming **", comment: "")
        }
        
        if store.filteredTag != nil {
            store.filterDvTodoItemTaskDataByTag()
            
            store.filterFilteredDvTodoItemTaskData(by: store.dvfilter)
            taskItemsAll = store.filteredDvTodoItemTaskData
            
            setupTitleView(withTitle: store.filteredTag?.label, withSubtitle: filterString)
        } else {
            store.filterDvTodoItemTaskDataByList()
            
            store.filterFilteredDvTodoItemTaskData(by: store.dvfilter)
            taskItemsAll = store.filteredDvTodoItemTaskData
            
            setupTitleView(withTitle: store.filteredProjectList?.title, withSubtitle: filterString)
        }
        
//        self.tableView.addSubview(self.dvRefreshControl)
        
        hideOrShowTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.theme_backgroundColor = "Global.backgroundColor"
        self.tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        setupDataAndNavBar()
    }
    
    @objc func handleShowSimpleView() {
        self.tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    @objc func handleHideSimpleView() {
        self.tabBarController?.setTabBarVisible(visible: false, animated: true)
//        self.tabBarController?.tabBar.isHidden = !(self.tabBarController?.tabBar.isHidden)!
//
//        let frame = self.tabBarController?.tabBar.frame
//        let height = frame?.size.height
//
//        if let isHidden = self.tabBarController?.tabBar.isHidden, isHidden {
////            self.view.frame.origin.y += height!
//////            self.tableView.frame.offsetBy(dx: 0, dy: height!)
////            self.tableView.frame = CGRect.init(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height + height!)
//            tabBarController?.tabBar.isHidden = true
//            edgesForExtendedLayout = UIRectEdge.bottom
//            extendedLayoutIncludesOpaqueBars = true
//            self.view.setNeedsDisplay()
//            self.view.layoutIfNeeded()
//        } else {
//            tabBarController?.tabBar.isHidden = false
//            edgesForExtendedLayout = UIRectEdge.bottom
//            extendedLayoutIncludesOpaqueBars = false
//            self.view.setNeedsDisplay()
//            self.view.layoutIfNeeded()
////            self.view.frame.origin.y -= height!
//////            self.tableView.frame.offsetBy(dx: 0, dy: -height!)
////            self.tableView.frame = CGRect.init(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height - height!)
//        }
////        if tabBarIsVisible() {
////            self.tabBarController?.tabBar.isHidden = false
//////            setTabBarVisible(visible: false, animated: true)
////        } else {
////            self.tabBarController?.tabBar.isHidden = true
//////            setTabBarVisible(visible: true, animated: true)
////        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadTVC), name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("handleSaveButton-DVMultipleTodoitemtaskItemsVC"), object: nil)
        
        tableView.tableFooterView = UIView.init()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func reloadTVC() {
        setupDataAndNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if self.isMovingFromParentViewController {
            store.filteredTag = nil
        }
    }
    
    private func setupTitleView(withTitle _titleString: String?, withSubtitle _subtitleString: String?) {
        if let titleString = _titleString {
//            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22)]
//            let _title:NSMutableAttributedString = NSMutableAttributedString(string: titleString, attributes: attrs)
            
//            if let subtitleString = _subtitleString {
//                let uppercasedSubtitleString = subtitleString.uppercased()
//                let __subAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
//                let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: uppercasedSubtitleString, attributes: __subAttrs)
//
////                _title.append(NSAttributedString(string:"\n"))
////                _title.append(__subTitle)
//
////                let size = _title.size()
//
//                let size = __subTitle.size()
//                let width = size.width
//                guard let height = navigationController?.navigationBar.frame.size.height else {return}
//
//                let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
////                titleLabel.attributedText = _title
//                titleLabel.attributedText = __subTitle
//                titleLabel.numberOfLines = 0
//                titleLabel.textAlignment = .center
//                titleLabel.theme_backgroundColor = "Global.barTintColor"
//                titleLabel.theme_textColor = "Global.textColor"
//
//                navigationItem.titleView = titleLabel
//            }
            
//            let size = _title.size()
//
//            let width = size.width
//            guard let height = navigationController?.navigationBar.frame.size.height else {return}
//
//            let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
//            titleLabel.attributedText = _title
//            titleLabel.numberOfLines = 0
//            titleLabel.textAlignment = .center
//            titleLabel.theme_backgroundColor = "Global.barTintColor"
//            titleLabel.theme_textColor = "Global.textColor"
            
//            navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: <#T##String?#>, style: .default, target: self, action: <#T##Selector?#>)
            
            let __attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: .semibold)]
//            let __attrs = [NSAttributedStringKey.font : UIFont.init(name: "AvenirNextCondensed-Regular", size: 20)!]
            let __title:NSMutableAttributedString = NSMutableAttributedString(string: titleString.uppercased(), attributes: __attrs)
            
            if let subtitleString = _subtitleString {
                __title.append(NSAttributedString(string:"\n"))
                let uppercasedSubtitleString = subtitleString.uppercased()
                let __subAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
                let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: uppercasedSubtitleString, attributes: __subAttrs)
                __title.append(__subTitle)
            }
            
            let size = __title.size()
            let width = size.width
            guard let height = navigationController?.navigationBar.frame.size.height else {return}
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            label.attributedText = __title
            label.textAlignment = .center
            label.numberOfLines = 2
            label.theme_textColor = "Global.textColor"
//            let customTitleLabel = UIBarButtonItem.init(customView: label)
//            let hideTabbarToggle = UIBarButtonItem.init(title: "H", style: .plain, target: self, action: #selector(handleHideSimpleView))
//            let hideShowTabbarToggle = UIBarButtonItem.init(title: "S", style: .plain, target: self, action: #selector(handleShowSimpleView))
//            navigationItem.leftBarButtonItems = [customTitleLabel]
            navigationItem.titleView = label
            
//            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationBar.topItem?.title = titleString
//            navigationItem.largeTitleDisplayMode = .always
//            navigationItem.title = titleString
//            navigationController?.navigationItem.largeTitleDisplayMode = .always
        } else {
            let todaysDate = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: todaysDate)
            let month = calendar.component(.month, from: todaysDate)
            let day = calendar.component(.day, from: todaysDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startOfYear = dateFormatter.date(from: "\(year)-01-01")
            let todayInYear = dateFormatter.date(from: "\(year)-\(month)-\(day)")
            let endOfYear = dateFormatter.date(from: "\(year)-12-31")
            
            let daysInCurrentYear = calendar.dateComponents([.day], from: startOfYear!, to: endOfYear!)
            let daysLeftInCurrentYear = calendar.dateComponents([.day], from: todayInYear!, to: endOfYear!)
            
            let totalDays = daysInCurrentYear.day
            let daysLeft = daysLeftInCurrentYear.day
            
            let yearProgress = Int(100 - ceil(Double(daysLeft!)/Double(totalDays!) * 100))
            let yearProgressLocalizedString = NSLocalizedString("Year progress", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND year completed **", comment: "")
            let yearProgressString = "\(yearProgressLocalizedString): \(yearProgress)%"
            let todaysDateString = dateFormatter.string(from: todaysDate)
            
            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
            let _title:NSMutableAttributedString = NSMutableAttributedString(string: todaysDateString, attributes: attrs)
            
            let __attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
            let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: "\(yearProgressString)", attributes: __attrs)
            
            _title.append(NSAttributedString(string:"\n"))
            _title.append(__subTitle)
            
            let size = _title.size()
            
            let width = size.width
            guard let height = navigationController?.navigationBar.frame.size.height else {return}
            
            let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            titleLabel.attributedText = _title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.theme_backgroundColor = "Global.barTintColor"
            titleLabel.theme_textColor = "Global.textColor"
            
            navigationItem.titleView = titleLabel
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //        return fetchedResultsController?.sections?.count ?? 1
        return taskItemsAll.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskItemsAll.count > 0 {
            return taskItemsAll[section].sectionCount()
        } else {
            return 0
        }
    }
    
    
    // gesture recognizer idea from https://d.pr/kTnQvo
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TodoItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
        }
        
        let sectionLocation = indexPath.section
        let todoItemTaskLocation = indexPath.row
        
        let todoItemTasks = taskItemsAll[sectionLocation].objects()
        let todoItem = todoItemTasks[todoItemTaskLocation]
        let dateFormatter = DateFormatter()
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
        cell.todoItemLabel.theme_textColor = "Global.textColor"
        cell.todoItemTagsLabel.theme_textColor = "Global.placeholderColor"
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        if todoItem.isCompleted {
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = .none
            
            cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText)
            
            cell.emotionsImageView.image = UIImage(named: "checkedcircle_icon_dailyvibes")
            
            if let completedDate = todoItem.completedAt {
                let fullString = NSMutableAttributedString(string: "")
                
                let dateString = dateFormatter.string(from: completedDate)
                let completedString = NSLocalizedString("Completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Completed **", comment: "")
                
                let title = NSAttributedString(string: "\(completedString) \(dateString)")
                
                fullString.append(title)
                
                if let tags = todoItem.tags, !tags.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "＃")
                    fullString.append(hasTagsString)
                }
                
                if todoItem.duedateAt != nil {
                    if let isRemindable = todoItem.isRemindable, isRemindable {
                        fullString.append(NSAttributedString(string: " • "))
                        fullString.append(NSAttributedString(string: "⌚︎"))
                    }
                }
                
                if let hasNote = todoItem.note, let hasContent = hasNote.content, !hasContent.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "✍︎")
                    fullString.append(hasTagsString)
                }
                
                cell.todoItemTagsLabel.attributedText = fullString
            } else {
                let fullString = NSMutableAttributedString(string: "")
                if let tags = todoItem.tags, !tags.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "＃")
                    fullString.append(hasTagsString)
                }
                
                if todoItem.duedateAt != nil {
                    if let isRemindable = todoItem.isRemindable, isRemindable {
                        fullString.append(NSAttributedString(string: " • "))
                        fullString.append(NSAttributedString(string: "⌚︎"))
                    }
                }
                
                if let hasNote = todoItem.note, let hasContent = hasNote.content, !hasContent.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "✍︎")
                    fullString.append(hasTagsString)
                }
                cell.todoItemTagsLabel.attributedText = fullString
            }
        } else {
            
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = .none
            
            cell.todoItemLabel.text = todoItem.todoItemText
            cell.emotionsImageView.image = UIImage(named: "emptycircle_icon_dailyvibes")
            
            if cell.emotionsImageView.gestureRecognizers?.count ?? 0 == 0 {
                // if the image currently has no gestureRecognizer
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                cell.emotionsImageView.addGestureRecognizer(tapGesture)
                cell.emotionsImageView.isUserInteractionEnabled = true
            }
            
            let fullString = NSMutableAttributedString(string: "")
            
            if let dueDate = todoItem.duedateAt, dueDate.isInThePast {
//                let fullString = NSMutableAttributedString(string: "")
                let createdString = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND CREATED **", comment: "")
                let uiTextFieldStringAttributes = [NSAttributedStringKey.foregroundColor: UIColor.red]
                let dateString = dateFormatter.string(from: dueDate)
                
                let title = NSAttributedString(string: "\(createdString) \(dateString)", attributes: uiTextFieldStringAttributes)
                
                fullString.append(title)
                
                if let tags = todoItem.tags, !tags.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "＃")
                    fullString.append(hasTagsString)
                }
                
                if todoItem.duedateAt != nil {
                    if let isRemindable = todoItem.isRemindable, isRemindable {
                        fullString.append(NSAttributedString(string: " • "))
                        fullString.append(NSAttributedString(string: "⌚︎"))
                    }
                }
                
                if let hasNote = todoItem.note, let hasContent = hasNote.content, !hasContent.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "✍︎")
                    fullString.append(hasTagsString)
                }
                
                cell.todoItemTagsLabel.attributedText = fullString
            } else if let dueDate = todoItem.duedateAt, dueDate.isInTheFuture {
//                let fullString = NSMutableAttributedString(string: "")
                let createdString = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND CREATED **", comment: "")
                
                let dateString = dateFormatter.string(from: dueDate)
                
                let title = NSAttributedString(string: "\(createdString) \(dateString)")
                
                fullString.append(title)
                
                if let tags = todoItem.tags, !tags.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "＃")
                    fullString.append(hasTagsString)
                }
                
                if todoItem.duedateAt != nil {
                    if let isRemindable = todoItem.isRemindable, isRemindable {
                        fullString.append(NSAttributedString(string: " • "))
                        fullString.append(NSAttributedString(string: "⌚︎"))
                    }
                }
                
                if let hasNote = todoItem.note, let hasContent = hasNote.content, !hasContent.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "✍︎")
                    fullString.append(hasTagsString)
                }
                
                cell.todoItemTagsLabel.attributedText = fullString
            } else {
                if let tags = todoItem.tags, !tags.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "＃")
                    fullString.append(hasTagsString)
                }
                
                if todoItem.duedateAt != nil {
                    if let isRemindable = todoItem.isRemindable, isRemindable {
                        fullString.append(NSAttributedString(string: " • "))
                        fullString.append(NSAttributedString(string: "⌚︎"))
                    }
                }
                
                if let hasNote = todoItem.note, let hasContent = hasNote.content, !hasContent.isEmpty {
                    fullString.append(NSAttributedString(string: " • "))
                    let hasTagsString = NSAttributedString(string: "✍︎")
                    fullString.append(hasTagsString)
                }
                cell.todoItemTagsLabel.attributedText = fullString
            }
        }
        
        return cell
    }
    
    @objc private func imgTapped(sender: UITapGestureRecognizer) {
        // change data model blah-blah
        //        print("testing-testing")
        //        https://guides.codepath.com/ios/Using-Gesture-Recognizers
        //        https://stackoverflow.com/a/29360703
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            // Access the image or the cell at this index path
            let section = taskItemsAll[indexPath.section]
            let todo = section.object(at: indexPath)
            doneAction(for: todo, at: indexPath)
        }
    }
    
    private func doneAction(for todoItem:DVTodoItemTaskViewModel, at indexPath:IndexPath) {
        let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
        let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
        let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
        let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
        
        if showDoneAlert {
            let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { [unowned self] _ in
                let completedTodoitemTask = self.store.completeTodoitemTask(task: todoItem)
                self.setupDataAndNavBar()
                do {
                    let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
                } catch {
                    NSLog("Streakmanager did not save")
                }
            }))
            alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let completedTodoitemTask = self.store.completeTodoitemTask(task: todoItem)
            self.setupDataAndNavBar()
            do {
                let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
            } catch {
                NSLog("Streakmanager did not save")
            }
        }
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
        case "ShowTodoItemDetail":
            guard segue.destination is UINavigationController else {
                fatalError("Unexpected destination = \(segue.destination)")
            }
            guard let selectedTodoItemCell = sender as? TodoItemTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTodoItemCell) else {
                fatalError("Selected sell is not being displayed on the table")
            }
            let section = indexPath.section
            let sectionData = taskItemsAll[section]
            let todoTaskItemViewModel = sectionData.object(at: indexPath)
            
            store.findOrCreateTodoitemTaskDeepNested(withUUID: todoTaskItemViewModel.uuid)
        case "TodoTaskItemFilters":
            if let _ = segue.destination as? TodoTaskItemFiltersViewController {
                //                controller.popoverPresentationController!.delegate = self
                //                controller.preferredContentSize = CGSize(width: 320, height: 186)
            }
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    //    // forces on iphone to display as popover
    //    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    //        return .none
    //    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let thisWeekIdentifier = NSLocalizedString("This week", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This week **", comment: "")
        
        if let hasProject = store.filteredProjectList, let projectTitle = hasProject.title, projectTitle == thisWeekIdentifier {
            if taskItemsAll.count > 0 {
                //            return taskItemsAll[section].sectionIdentifier
                let sectionID = taskItemsAll[section]
                let completedCount = sectionID.completedObjects.count
                let allCount = sectionID.allObjects.count
                
                let progress = Int(ceil((Double(completedCount)/Double(allCount)) * 100))
                let sectionString = sectionHeaderHelper(forDateString: sectionID.sectionIdentifier)!
                
                return "\(sectionString) [\(progress)%]"
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    private func sectionHeaderHelper(forDateString _date: String) -> String? {
        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "EEE d yyyy"
        dateFormatter.dateFormat = "yyyyMMdd"

        let date = dateFormatter.date(from: _date)!

        let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
        let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
        let tomorrowString = NSLocalizedString("Tomorrow", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tomorrow **", comment: "")

        if Calendar.current.isDateInToday(date) {
            return todayString
        } else if (Calendar.current.isDateInYesterday(date)) {
            return yesterdayString
        } else if (Calendar.current.isDateInTomorrow(date)) {
            return tomorrowString
        } else {
            if _date.isEmpty {
                return ""
            } else {
                return date.sectionIdentifier
            }
        }
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
    
    //    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    //        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    //    }
    
    // MARK: - Custom swipe right
    
    //    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = taskItemsAll[indexPath.section]
        let _todo = section.object(at: indexPath)
        
        var actions = [UIContextualAction]()
        
        if !_todo.isCompleted {
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
                    alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { [unowned self] _ in
                        let completedTodoitemTask = self.store.completeTodoitemTask(task: _todo)
                        self.setupDataAndNavBar()
                        do {
                            let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
                        } catch {
                            NSLog("Streakmanager did not save")
                        }
                    }))
                    alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let completedTodoitemTask = self.store.completeTodoitemTask(task: _todo)
                    self.setupDataAndNavBar()
                    do {
                        let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
                    } catch {
                        NSLog("Streakmanager did not save")
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
        let section = taskItemsAll[indexPath.section]
        let todoItemTask = section.object(at: indexPath)
        
        if !todoItemTask.isArchived {
            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
            let archiveAction = self.contextualToggleArchiveAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
            return swipeConfig
        } else {
            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipeConfig
        }
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let section = taskItemsAll[indexPath.section]
        let removable = section.object(at: indexPath)
        let deleteLabel = NSLocalizedString("Delete", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete ***", comment: "")
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
            
            let defaults = UserDefaults.standard
            let showDoneAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
            
            if showDoneAlert {
                let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
                let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
                let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
                let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
                
                let alert = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: deleteAlertConfirmation, style: .destructive , handler: { [unowned self] _ in
                    let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
                    self.setupDataAndNavBar()
                }))
                alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
                self.setupDataAndNavBar()
            }
        }
        action.title = deleteLabel
        action.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        return action
    }
    
    private func contextualToggleArchiveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let sectionVM = taskItemsAll[indexPath.section]
        let _todoItem = sectionVM.object(at: indexPath)
        
        if !_todoItem.isArchived {
            let archiveLabel = NSLocalizedString("Archive", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archive ***", comment: "")
            
            let action = UIContextualAction(style: .normal, title: archiveLabel) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                let _ = self.store.archiveTodoitemTask(task: _todoItem)
                self.setupDataAndNavBar()
                completionHandler(true)
            }
            
            // 7
            action.title = archiveLabel
            action.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
            return action
        } else {
            // if item is archived... return an empty action
            return UIContextualAction.init()
        }
    }
    
    
    // MARK: - Actions
    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
        // do nothing
        // this methods used to have a lot of logic
        // now this method does nothing
        // the logic is still here because a button in TodoItemViewController (save) calls this action
        // need to figure out how to do this action without having this method here
    }
    
    // MARK: - Helpers
    
    private func stringStrikeThrough(input: String) -> NSMutableAttributedString {
        // based on - https://stackoverflow.com/q/44152721
        let result = NSMutableAttributedString(string: input)
        let range = (input as NSString).range(of: input)
        result.addAttribute(NSAttributedStringKey.strikethroughStyle,
                            value: NSUnderlineStyle.styleSingle.rawValue,
                            range: range)
        
        if let backgroundColor = ThemeManager.value(for: "Global.barTintColor") as? String,
            let foregroundColor = ThemeManager.value(for: "Global.textColor") as? String {
            result.addAttributes([NSAttributedStringKey.backgroundColor: UIColor.from(hex: backgroundColor)], range: range)
            result.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.from(hex: foregroundColor)], range: range)
        }
        
        return result;
    }
    
    private func hideOrShowTableView() {
        if taskItemsAll.count == 0 {
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
