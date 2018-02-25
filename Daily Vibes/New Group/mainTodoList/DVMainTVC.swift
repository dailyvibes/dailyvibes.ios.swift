////
////  TodoItemsTableViewController.swift
////  Daily Vibes
////
////  Created by Alex Kluew on 2017-11-04.
////  Copyright © 2017 Alex Kluew. All rights reserved.
////
//
//import UIKit
//import CoreData
//import SwiftTheme
//
//enum DVSegmentOption {
//    case inbox
//    case archived
//    case done
//}
//
//class DVMainTVC: UITableViewController, UIPopoverPresentationControllerDelegate {
//
//    private enum FilteredOption {
//        case none
//        case byTag
//    }
//
//    private struct FiltrationData {
//        var tag: Tag?
//    }
//
//    // MARK: Properties
//    private var segmentPosition = SegmentOption.inbox
//    private var filteredOption = FilteredOption.none
//    private var filtrationData = FiltrationData()
//
//    private var store = CoreDataManager.store
//    private var taskItemsAll = [DVCoreSectionViewModel]()
//    private var taskItemsPendingOnly = [DVCoreSectionViewModel]()
//
//    private var streakManager = StreakManager()
//
//    @IBOutlet private weak var segmentController: UISegmentedControl!
//
//    private var dynamicNavigationBarLabel: String?
//
//    fileprivate func setNavigationBarStringGeneric() {
//        switch segmentPosition {
//        case .inbox:
//            dynamicNavigationBarLabel = NSLocalizedString("To-do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND To-do", comment: "")
//        case .done:
//            dynamicNavigationBarLabel = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done", comment: "")
//        case .archived:
//            dynamicNavigationBarLabel = NSLocalizedString("Archived", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archived", comment: "")
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        switch filteredOption {
//        case .byTag:
//            dynamicNavigationBarLabel = filtrationData.tag?.label ?? ""
//        case .none:
//            setNavigationBarStringGeneric()
//        }
//
//        self.tableView.theme_backgroundColor = "Global.backgroundColor"
//        self.tableView.theme_separatorColor = "ListViewController.separatorColor"
//
//        taskItemsAll = store.getGroupedTodoItemTasks(ascending: false)!
//
//        //        if let data = store.getGroupedTodoItemTasks(ascending: false) {
//        //            taskItemsAll = data
//        //        }
//
//        let navigationBarLabel = "Daily Vibes \n \(dynamicNavigationBarLabel ?? String())"
//        setupTitleView(withString: navigationBarLabel)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTVC), name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
//
//        tableView.tableFooterView = UIView.init()
//        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
//
//        hideOrShowTableView()
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc private func reloadTVC() {
//        print("reloading tVC")
//        taskItemsAll = store.getGroupedTodoItemTasks(ascending: false)!
//        self.tableView.reloadData()
//        hideOrShowTableView()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//    }
//
//    private func setupTitleView(withString string: String) {
//        //        let topText = NSLocalizedString("key", comment: "")
//        //        let bottomText = NSLocalizedString("key", comment: "")
//
//        //        let titleParameters = [NSForegroundColorAttributeName : UIColor.<Color>(),
//        //                               NSFontAttributeName : UIFont.<Font>]
//        //        let subtitleParameters = [NSForegroundColorAttributeName : UIColor.<Color>(),
//        //                                  NSFontAttributeName : UIFont.<Font>]
//
//        //        let title:NSMutableAttributedString = NSMutableAttributedString(string: topText, attributes: titleParameters)
//        //        let subtitle:NSAttributedString = NSAttributedString(string: bottomText, attributes: subtitleParameters)
//
//        //        title.appendAttributedString(NSAttributedString(string: "\n"))
//        //        title.appendAttributedString(subtitle)
//
//        //        let titleParameters =
//        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
//        let _title:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrs)
//
//        //        let title = NSAttributedString(string: string)
//
//        let size = _title.size()
//
//        let width = size.width
//        guard let height = navigationController?.navigationBar.frame.size.height else {return}
//
//        //        let titleLabel = UILabel(frame: CGRectMake(0,0, width, height))
//        let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        titleLabel.attributedText = _title
//        titleLabel.numberOfLines = 0
//        titleLabel.textAlignment = .center
//        titleLabel.theme_backgroundColor = "Global.barTintColor"
//        titleLabel.theme_textColor = "Global.textColor"
//
//        navigationItem.titleView = titleLabel
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        //        return fetchedResultsController?.sections?.count ?? 1
//        return taskItemsAll.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if taskItemsAll.count > 0 {
//            return taskItemsAll[section].sectionCount
//        } else {
//            return 0
//        }
//    }
//
//
//    // gesture recognizer idea from https://d.pr/kTnQvo
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "TodoItemTableViewCell"
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
//            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
//        }
//
//        let sectionLocation = indexPath.section
//        let todoItemTaskLocation = indexPath.row
//
//        let todoItemTasks = taskItemsAll[sectionLocation].objects
//        let todoItem = todoItemTasks[todoItemTaskLocation]
//        let dateFormatter = DateFormatter()
//
//        cell.theme_backgroundColor = "Global.barTintColor"
//        cell.theme_tintColor = "Global.barTextColor"
//        cell.todoItemLabel.theme_textColor = "Global.textColor"
//        cell.todoItemTagsLabel.theme_textColor = "Global.placeholderColor"
//
//        dateFormatter.dateStyle = DateFormatter.Style.short
//        dateFormatter.timeStyle = DateFormatter.Style.short
//
//        if todoItem.isCompleted {
//            cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText)
//            cell.emotionsImageView.image = UIImage(named: "checkedcircle_icon_dailyvibes")
//            if let completedDate = todoItem.completedAt {
//                let dateString = dateFormatter.string(from: completedDate)
//                cell.todoItemTagsLabel.text = "Completed \(dateString)"
//            }
//        } else {
//            let dateString = dateFormatter.string(from: todoItem.createdAt)
//
//            cell.todoItemLabel.text = todoItem.todoItemText
//            cell.emotionsImageView.image = UIImage(named: "emptycircle_icon_dailyvibes")
//
//            if cell.emotionsImageView.gestureRecognizers?.count ?? 0 == 0 {
//                // if the image currently has no gestureRecognizer
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
//                cell.emotionsImageView.addGestureRecognizer(tapGesture)
//                cell.emotionsImageView.isUserInteractionEnabled = true
//            }
//
//            cell.todoItemTagsLabel.text = "Created \(dateString)"
//        }
//        return cell
//    }
//
//    @objc private func imgTapped(sender: UITapGestureRecognizer) {
//        // change data model blah-blah
//        //        print("testing-testing")
//        //        https://guides.codepath.com/ios/Using-Gesture-Recognizers
//        //        https://stackoverflow.com/a/29360703
//
//        let touch = sender.location(in: tableView)
//        if let indexPath = tableView.indexPathForRow(at: touch) {
//            // Access the image or the cell at this index path
//            let section = taskItemsAll[indexPath.section]
//            let todo = section.object(at: indexPath)
//            doneAction(for: todo, at: indexPath)
//        }
//    }
//
//    private func doneAction(for todoItem:DVTodoItemTaskViewModel, at indexPath:IndexPath) {
//        let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
//        let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
//        let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
//        let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
//
//        let defaults = UserDefaults.standard
//        let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
//
//        if showDoneAlert {
//            let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { [unowned self] _ in
//                let completedTodoitemTask = self.store.completeTodoitemTask(task: todoItem)
//                //                self.tableView.beginUpdates()
//                let section = self.taskItemsAll[indexPath.section]
//                section.switchDVTodoItemTask(viewModel: todoItem, at: indexPath)
//                do {
//                    let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
//                } catch {
//                    NSLog("Streakmanager did not save")
//                }
//                //                self.tableView.reloadRows(at: [indexPath], with: .automatic)
//                //                self.tableView.endUpdates()
//            }))
//            alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        } else {
//            let completedTodoitemTask = self.store.completeTodoitemTask(task: todoItem)
//            //            self.tableView.beginUpdates()
//            let section = self.taskItemsAll[indexPath.section]
//            section.switchDVTodoItemTask(viewModel: todoItem, at: indexPath)
//            do {
//                let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
//            } catch {
//                NSLog("Streakmanager did not save")
//            }
//            //            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//            //            self.tableView.endUpdates()
//        }
//    }
//
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        switch(segue.identifier ?? "") {
//        case "ShowTodoItemDetail":
//            guard let todoItemDetailViewController = segue.destination as? TodoItemViewController else {
//                fatalError("Unexpected destination = \(segue.destination)")
//            }
//            guard let selectedTodoItemCell = sender as? TodoItemTableViewCell else {
//                fatalError("Unexpected sender: \(String(describing: sender))")
//            }
//            guard let indexPath = tableView.indexPath(for: selectedTodoItemCell) else {
//                fatalError("Selected sell is not being displayed on the table")
//            }
//            //            let _todoItem = fetchedResultsController?.object(at: indexPath)
//            let section = indexPath.section
//            let sectionData = taskItemsAll[section]
//            let todoTaskItemViewModel = sectionData.object(at: indexPath)
//
//            //            todoItemDetailViewController.setData(toProcess: _todoItem, inContext: moc)
//            todoItemDetailViewController.setData(withViewModel: todoTaskItemViewModel)
//        case "TodoTaskItemFilters":
//            if let controller = segue.destination as? TodoTaskItemFiltersViewController {
//                controller.delegate = self
//                controller.selectedSegment = segmentPosition
//                //                controller.popoverPresentationController!.delegate = self
//                //                controller.preferredContentSize = CGSize(width: 320, height: 186)
//            }
//        default:
//            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
//        }
//    }
//
//    //    // forces on iphone to display as popover
//    //    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//    //        return .none
//    //    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if taskItemsAll.count > 0 {
//            return taskItemsAll[section].sectionIdentifier
//        } else {
//            return nil
//        }
//    }
//
//    private func sectionHeaderHelper(for item:TodoItem, numericSection section: Int?) -> String? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE d yyyy"
//
//        switch segmentPosition {
//        case .inbox:
//            guard let numericSection = section else { return "Nothing" }
//
//            //            let date = dateFormatter.string(from: item.createdAt!)
//            let year = numericSection / 10000
//            let month = (numericSection / 100) % 100
//            let day = numericSection % 100
//
//            // Reconstruct the date from these components.
//            var components = DateComponents()
//            components.calendar = Calendar.current
//            components.day = day
//            components.month = month
//            components.year = year
//
//            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
//            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
//
//            if let date = components.date {
//                if Calendar.current.isDateInToday(date) {
//                    return todayString
//                }
//                if Calendar.current.isDateInYesterday(date) {
//                    return yesterdayString
//                }
//                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
//            }
//            return String()
//        case .archived:
//            //            let date = dateFormatter.string(from: item.archivedAt!)
//            //            return "\(date)"
//            guard let numericSection = section else { return "Nothing" }
//
//            //            let date = dateFormatter.string(from: item.createdAt!)
//            let year = numericSection / 10000
//            let month = (numericSection / 100) % 100
//            let day = numericSection % 100
//
//            // Reconstruct the date from these components.
//            var components = DateComponents()
//            components.calendar = Calendar.current
//            components.day = day
//            components.month = month
//            components.year = year
//
//            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
//            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
//
//            if let date = components.date {
//                if Calendar.current.isDateInToday(date) {
//                    return todayString
//                }
//                if Calendar.current.isDateInYesterday(date) {
//                    return yesterdayString
//                }
//                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
//            }
//            return String()
//        case .done:
//            //            let date = dateFormatter.string(from: item.completedAt!)
//            //            return "\(date)"
//            guard let numericSection = section else { return "Nothing" }
//
//            //            let date = dateFormatter.string(from: item.createdAt!)
//            let year = numericSection / 10000
//            let month = (numericSection / 100) % 100
//            let day = numericSection % 100
//
//            // Reconstruct the date from these components.
//            var components = DateComponents()
//            components.calendar = Calendar.current
//            components.day = day
//            components.month = month
//            components.year = year
//
//            let todayString = NSLocalizedString("Today", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Today ***", comment: "")
//            let yesterdayString = NSLocalizedString("Yesterday", tableName: "Localizable", bundle: .main, value: "*** NOT FOUND YESTERDAY ***", comment: "")
//
//            if let date = components.date {
//                if Calendar.current.isDateInToday(date) {
//                    return todayString
//                }
//                if Calendar.current.isDateInYesterday(date) {
//                    return yesterdayString
//                }
//                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
//            }
//            return String()
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
//        view.theme_backgroundColor = "Global.backgroundColor"
//        //        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 18))
//        //        let label = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width, 18))
//        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.theme_textColor = "Global.barTextColor"
//        label.text = self.tableView(tableView, titleForHeaderInSection: section)
//        //        label.textAlignment = .center
//        view.addSubview(label)
//        return view
//    }
//
//    //    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//    //        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
//    //    }
//
//    // MARK: - Custom swipe right
//
//    //    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let section = taskItemsAll[indexPath.section]
//        let _todo = section.object(at: indexPath)
//
//        var actions = [UIContextualAction]()
//
//        if !_todo.isCompleted {
//            let doneLabel = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
//
//            let closeAction = UIContextualAction(style: .normal, title: doneLabel, handler: { (ac:UIContextualAction, view:UIView, success:@escaping (Bool) -> Void) in
//                let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
//                let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
//                let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
//                let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
//
//                let defaults = UserDefaults.standard
//                let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
//
//                if showDoneAlert {
//                    let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { [unowned self] _ in
//                        let completedTodoitemTask = self.store.completeTodoitemTask(task: _todo)
//                        //                        self.tableView.beginUpdates()
//                        let section = self.taskItemsAll[indexPath.section]
//                        section.switchDVTodoItemTask(viewModel: _todo, at: indexPath)
//                        do {
//                            let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
//                        } catch {
//                            NSLog("Streakmanager did not save")
//                        }
//                        //                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
//                        //                        self.tableView.endUpdates()
//                    }))
//                    alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//                    let completedTodoitemTask = self.store.completeTodoitemTask(task: _todo)
//                    //                    self.tableView.beginUpdates()
//                    let section = self.taskItemsAll[indexPath.section]
//                    section.switchDVTodoItemTask(viewModel: _todo, at: indexPath)
//                    do {
//                        let _ = try self.streakManager.process(item: self.store.findTodoItemTask(withUUID: completedTodoitemTask.uuid))
//                    } catch {
//                        NSLog("Streakmanager did not save")
//                    }
//                    //                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
//                    //                    self.tableView.endUpdates()
//                }
//
//                //                if showDoneAlert {
//                //                    let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
//                //                    alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { _ in
//                //                        do {
//                //                            _todo.markCompleted()
//                //                            try self.moc!.save()
//                //                            self.tableView.reloadData()
//                //                            guard self.streakManager.process(item: _todo) else {
//                //                                fatalError("StreakManager should not fail")
//                //                            }
//                //                        } catch {
//                //                            self.moc!.rollback()
//                //                            fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
//                //                        }
//                //                    }))
//                //                    alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: { _ in
//                //                        success(true)
//                //                    }))
//                //                    self.present(alert, animated: true, completion: nil)
//                //                } else {
//                //                    let _completedTodo = store.completeTodoitemTask(task: _todo)
//                //                    guard self.streakManager.process(item: <#T##TodoItem?#>)
//                //
//                //                    do {
//                //                        _todo.markCompleted()
//                //                        try self.moc!.save()
//                //                        self.tableView.reloadData()
//                //                        guard self.streakManager.process(item: _todo) else {
//                //                            fatalError("StreakManager should not fail")
//                //                        }
//                //                    } catch {
//                //                        self.moc!.rollback()
//                //                        fatalError("Error \(error) in leadingSwipeActionsConfigurationForRowAt")
//                //                    }
//                //                }
//            })
//
//            actions.append(closeAction)
//            closeAction.title = doneLabel
//            closeAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
//        }
//
//        return UISwipeActionsConfiguration(actions: actions)
//    }
//
//    // MARK: - Overwriting trailingSwipeAction
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let section = taskItemsAll[indexPath.section]
//        let todoItemTask = section.object(at: indexPath)
//
//        if !todoItemTask.isArchived {
//            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
//            let archiveAction = self.contextualToggleArchiveAction(forRowAtIndexPath: indexPath)
//            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, archiveAction])
//            return swipeConfig
//        } else {
//            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
//            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
//            return swipeConfig
//        }
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
//                    let section = self.taskItemsAll[indexPath.section]
//                    print("section count before remove: \(section.objects.count)")
//                    let _ = section.removeDVTodoItemTask(at: indexPath)
//                    let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
//                    print("section count after remove: \(section.objects.count)")
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
//                    self.tableView.reloadData()
//                }))
//                alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                let section = self.taskItemsAll[indexPath.section]
//                let _ = section.removeDVTodoItemTask(at: indexPath)
//                let _ = self.store.destroyTodoItemTask(withUUID: removable.uuid)
//                self.tableView.deleteRows(at: [indexPath], with: .fade)
//                self.tableView.reloadData()
//                //                if isDestroyed {
//                ////                    self.tableView.beginUpdates()
//                //                    let section = self.taskItemsAll[indexPath.section]
//                //                    let _ = section.removeDVTodoItemTask(at: indexPath)
//                ////                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                ////                    self.tableView.endUpdates()
//                //                }
//            }
//        }
//        action.title = deleteLabel
//        action.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
//        return action
//    }
//
//    private func contextualToggleArchiveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
//
//        let sectionVM = taskItemsAll[indexPath.section]
//        let _todoItem = sectionVM.object(at: indexPath)
//
//        if !_todoItem.isArchived {
//            // if item is not archived... return action for user to archive
//            let archiveLabel = NSLocalizedString("Archive", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archive ***", comment: "")
//
//            let action = UIContextualAction(style: .normal, title: archiveLabel) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
//
//                let result = self.store.archiveTodoitemTask(task: _todoItem)
//
//                if result.isArchived {
//                    let _ = sectionVM.removeDVTodoItemTask(at: indexPath)
//                    completionHandler(true)
//                } else {
//                    completionHandler(false)
//                }
//
//            }
//            action.title = archiveLabel
//            action.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
//            return action
//        } else {
//            return UIContextualAction.init()
//        }
//    }
//
//
//    // MARK: - Actions
//    @IBAction func unwindToTodoItemsList(sender: UIStoryboardSegue) {
//        // do nothing
//        // this methods used to have a lot of logic
//        // now this method does nothing
//        // the logic is still here because a button in TodoItemViewController (save) calls this action
//        // need to figure out how to do this action without having this method here
//    }
//
//    // MARK: - Helpers
//
//    private func stringStrikeThrough(input: String) -> NSMutableAttributedString {
//        // based on - https://stackoverflow.com/q/44152721
//        let result = NSMutableAttributedString(string: input)
//        let range = (input as NSString).range(of: input)
//        result.addAttribute(NSAttributedStringKey.strikethroughStyle,
//                            value: NSUnderlineStyle.styleSingle.rawValue,
//                            range: range)
//
//        if let backgroundColor = ThemeManager.value(for: "Global.barTintColor") as? String,
//            let foregroundColor = ThemeManager.value(for: "Global.textColor") as? String {
//            result.addAttributes([NSAttributedStringKey.backgroundColor: UIColor.from(hex: backgroundColor)], range: range)
//            result.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.from(hex: foregroundColor)], range: range)
//        }
//
//        return result;
//    }
//
//    private func hideOrShowTableView() {
//        if taskItemsAll.count == 0 {
//            guard let view = tableView as? TodoItemUITableView else {
//                fatalError("hideOrShowTableView - Fail couldn't claim the view as TodoItemUITableView")
//            }
//            view.showEmptyView()
//        } else {
//            guard let view = tableView as? TodoItemUITableView else {
//                fatalError("hideOrShowTableView - Fail couldn't claim the view as TodoItemUITableView")
//            }
//            view.hideEmptyView()
//        }
//    }
//
//    func setupTodoItemsTVC(using filter: Tag?) {
//        filteredOption = .byTag
//        filtrationData.tag = filter
//        let _navigationBarLabel = filter?.label ?? "BATMAN"
//        let navigationBarLabel = "Daily Vibes \n \(_navigationBarLabel)"
//        setupTitleView(withString: navigationBarLabel)
//    }
//}
//
////extension TodoItemsTableViewController: TodoTaskItemFiltersViewControllerDelegate {
////    func selectedFilterProperties(sender: TodoTaskItemFiltersViewController) {
////        if sender.selectedSegment == .inbox {
////            // handle the all view
////            segmentPosition = .inbox
////            // TODO -- LOOOK AT THIS
////            //            initializeFetchedResultsController(with: segmentPosition)
////            self.tableView.reloadData()
////            hideOrShowTableView()
////        }
////        if sender.selectedSegment == .done {
////            //handle done view
////            segmentPosition = .done
////            // TODO -- LOOOK AT THIS
////            //            initializeFetchedResultsController(with: segmentPosition)
////            self.tableView.reloadData()
////            hideOrShowTableView()
////        }
////        if sender.selectedSegment == .archived {
////            //handle archived view
////            segmentPosition = .archived
////            // TODO -- LOOOK AT THIS
////            //            initializeFetchedResultsController(with: segmentPosition)
////            self.tableView.reloadData()
////            hideOrShowTableView()
////        }
////    }
////}
//
