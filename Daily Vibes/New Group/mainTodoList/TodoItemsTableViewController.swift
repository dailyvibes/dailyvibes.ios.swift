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
import ContextMenu
import DeckTransition

enum SegmentOption {
    case inbox
    case archived
    case done
}

class TodoItemsTableViewController: ThemableTableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private var store = CoreDataManager.store
    
    private var taskItemsAll = [DVCoreSectionViewModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var customSelectionView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    private var streakManager = StreakManager()
    private var dynamicNavigationBarLabel: String?
    
    lazy var dotdotdotbtn : UIBarButtonItem = {
        let dotdotdot = #imageLiteral(resourceName: "more_icon_dailyvibes")
        
        let _color = ThemeManager.value(for: "Global.barTintColor")
        
        guard let rgba = _color as? String else {
            fatalError("could not get value from ThemeManager")
        }
        
        let color = UIColor(rgba: rgba)
        
        let colorddotdotdot = dotdotdot.tint(color: color)
        let btn = UIBarButtonItem(image: colorddotdotdot, style: .plain, target: self, action: #selector(handleEditBtn))
        
        btn.accessibilityIdentifier = "taskitemlist.dotdotdot.btn"
        
        return btn
    }()
    
    fileprivate func setupDataAndNavBar() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if store.filteredTag != nil {
            store.filterDvTodoItemTaskDataByTag()
            
            store.filterFilteredDvTodoItemTaskData(by: store.dvfilter)
            taskItemsAll = store.filteredDvTodoItemTaskData
            
//            setupVCTwoLineTitle(withTitle: store.filteredTag?.label, withSubtitle: nil)
            navigationItem.title = store.filteredTag?.label
            navigationItem.rightBarButtonItems = nil
        } else {
            store.filterDvTodoItemTaskDataByList()
            
            store.filterFilteredDvTodoItemTaskData(by: store.dvfilter)
            taskItemsAll = store.filteredDvTodoItemTaskData
            
            if let emoji = store.filteredProjectList?.emoji, let title = store.filteredProjectList?.title {
                let _title = emoji + " " + title
                navigationItem.title = _title
            }
            navigationItem.rightBarButtonItems = [dotdotdotbtn]
        }
        
        hideOrShowTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDataAndNavBar()
        setupFloatingBtn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(reloadTVC), name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: UIApplication.willEnterForegroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("handleSaveButton-DVMultipleTodoitemtaskItemsVC"), object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("handleTasksFilterChange-TodoTaskItemFiltersViewController"), object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("handleListChange-DVListTableViewController"), object: nil)
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("ListTableViewController.projectListChange"), object: nil)
        nc.addObserver(self, selector: #selector(coreProjectDataUpdated), name: Notification.Name("coreProjectDataUpdated-DVProjectList"), object: nil)
        
        if !UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            setupWhatsnew()
        }
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    lazy var newTaskBtn: AAFloatingButton = {
        let btnSize = CGFloat(48)
        let btnFrame = CGRect(x: 0, y: 0, width: btnSize, height: btnSize)
        let btn = AAFloatingButton(frame: btnFrame)
        
        let uimage = #imageLiteral(resourceName: "dvAdd002Icon")
        let coloreduiimage = uimage.tint(color: .white)
        
        btn.setImage(coloreduiimage, for: .normal)
        btn.buttonBackgroundColor = .whatsNewKitPurple
        btn.addTarget(self, action: #selector(handleNewDVTaskItemBtn), for: .touchDown)
        btn.accessibilityIdentifier = "dv_new_dvtaskitem"
        
        return btn
    }()
    
    fileprivate func setupFloatingBtn() {
        let btnSize = CGFloat(48)
        let btnOffset = CGFloat(-16)
        
        self.tableView.addSubview(newTaskBtn)
        newTaskBtn.translatesAutoresizingMaskIntoConstraints = false
        
        newTaskBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        newTaskBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        
        newTaskBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: btnOffset).isActive = true
        newTaskBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btnOffset).isActive = true
    }
    
    @objc
    func handleNewDVTaskItemBtn() {
        let btnFeedback = UIImpactFeedbackGenerator()
        btnFeedback.impactOccurred()
        
        let storyboard = UIStoryboard.init(name: "DVMultipleTodoitemtaskItems", bundle: nil)
        let tvc = storyboard.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsNC")
        
        let transitionDelegate = DeckTransitioningDelegate(isSwipeToDismissEnabled: false)
        tvc.transitioningDelegate = transitionDelegate
        tvc.modalPresentationStyle = .custom
        
        present(tvc, animated: true, completion: nil)
    }
    
    @objc
    func handleEditBtn() {
        let btnFeedback = UIImpactFeedbackGenerator()
        btnFeedback.impactOccurred()
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let filtervcidentifier = "taskitemfiltervc"
        let vc = sb.instantiateViewController(withIdentifier: filtervcidentifier)
        
        let _color = ThemeManager.value(for: "Global.barTintColor")
        
        guard let rgba = _color as? String else {
            fatalError("could not get value from ThemeManager")
        }
        
        let color = UIColor(rgba: rgba)
        
        let sourceViewController = self
        
        let alert = UIAlertController(style: .actionSheet, title: nil, message: nil)
        
        // HERE WE NEED THE PROJECT DATA
        
        if let _hasProject = store.filteredProjectList, let _projectTitle = _hasProject.title {
            if !_hasProject.isDVDefault {
                let renameStr = NSLocalizedString("Rename", tableName: "Localizable", bundle: .main, value: "** DID NOT Find Rename **", comment: "")
                
                let cancelStr = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel **", comment: "")
                let titleStr = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Title **", comment: "")
                let changeStr = NSLocalizedString("Change", tableName: "Localizable", bundle: .main, value: "** DID NOT Find Change **", comment: "")
                
                let changeTitleStr = changeStr + " " + titleStr.localizedLowercase
                
                let _alert = UIAlertController.init(style: .alert, title: "\(_projectTitle)", message: changeTitleStr)
                
                _alert.addTextField(configurationHandler: { (textfield) in
                    textfield.text = _projectTitle
                    textfield.placeholder = titleStr
                    textfield.returnKeyType = .done
                    textfield.autocorrectionType = .default
                    textfield.keyboardType = .default
                    textfield.becomeFirstResponder()
                })
                
                let renameImage = #imageLiteral(resourceName: "dvRenameItemIcon")
                let renameActionStr = "\(renameStr) \(_projectTitle)"
                let renameAction = UIAlertAction(title: renameActionStr, style: .destructive, handler: { (alertaction) in
                    sourceViewController.present(_alert, animated: true, completion: nil)
                })
                
                renameAction.isEnabled = true
                renameAction.setValue(renameImage, forKey: "image")
                
                _alert.addAction(UIAlertAction(title: cancelStr, style: .cancel, handler: nil))
                _alert.addAction(UIAlertAction(title: renameStr, style: .destructive, handler: { (alertaction) in
                    if let newTitle = _alert.textFields?.first?.text {
                        if !newTitle.isEmpty {
                            sourceViewController.store.updateDVProjectlist(for: _hasProject, newtitle: newTitle, newEmoji: nil)
                        }
                    }
                }))
                alert.addAction(renameAction)
            }
            
            let switchS = NSLocalizedString("Switch", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Switch **", comment: "")
            let iconS = NSLocalizedString("Icon", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Icon **", comment: "")
            let switchStr = switchS + " " + iconS.localizedLowercase
            
            let emoji = _hasProject.emoji ?? "🗂"
            let emojiUIImage = emoji.imageFromEmoji(24, 24)
            
            let _alertEmoji = UIAlertController.init(style: .alert, title: switchStr, message: emoji)
            
            _alertEmoji.addTextField(configurationHandler: { (tx) in
                tx.text = emoji
                tx.placeholder = switchStr
                tx.returnKeyType = .done
                tx.keyboardType = .default
                tx.autocorrectionType = .default
                tx.becomeFirstResponder()
            })
            
            let switchEmojiAction = UIAlertAction(title: switchStr, style: .destructive, handler: { (swEmojiAction) in
                sourceViewController.present(_alertEmoji, animated: true, completion: nil)
            })
            
            switchEmojiAction.isEnabled = true
            
            if let eimage = emojiUIImage {
                switchEmojiAction.setValue(eimage, forKey: "image")
            }
            
            _alertEmoji.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            _alertEmoji.addAction(UIAlertAction(title: "Switch", style: .destructive, handler: { (swEmojiAction) in
                if let newEmoji = _alertEmoji.textFields?.first?.text {
                    if !newEmoji.isEmpty {
                        sourceViewController.store.updateDVProjectlist(for: _hasProject, newtitle: _projectTitle, newEmoji: newEmoji)
                    }
                }
            }))
            
            alert.addAction(switchEmojiAction)
        }
        
        let title = NSLocalizedString("Sort by", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sort by **", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        let viewStr = NSLocalizedString("View", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND View **", comment: "")
        let notificationsStr = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notifications **", comment: "")
        
        let viewNotificationsStr = viewStr + " " + notificationsStr.localizedLowercase
        
        let notificationsImage = #imageLiteral(resourceName: "dv_bell_notifications")
        alert.addAction(image: notificationsImage, title: viewNotificationsStr, color: .black, style: .default, isEnabled: true) { (action) in
            let storyboard = UIStoryboard.init(name: "DVLocalNotifications", bundle: nil)
            let tvc = storyboard.instantiateViewController(withIdentifier: "dvLNTableViewController")
            
            ContextMenu.shared.show(sourceViewController: self, viewController: tvc, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)))
        }
        
        let filterImage = #imageLiteral(resourceName: "dvFilterIcon")
        let filterTitle = title + " " + store.dvfilter.rawValue.capitalized
        alert.addAction(image: filterImage, title: filterTitle, color: .black, style: .default, isEnabled: true) { (action) in
            ContextMenu.shared.show(sourceViewController: self, viewController: vc, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)))
        }
        
        alert.addAction(title: cancelString, style: .cancel)
        sourceViewController.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if self.isMovingFromParent {
            print("moving from parent")
//            store.filteredTag = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func reloadTVC() {
        setupDataAndNavBar()
    }
    
    @objc
    func handleShowSimpleView() {
        self.tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    @objc
    func handleHideSimpleView() {
        self.tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    @objc
    fileprivate func coreProjectDataUpdated() {
        setupDataAndNavBar()
    }
    
    func setupWhatsnew() {
//        let keyValueVersionStore = KeyValueWhatsNewVersionStore(
//            keyValueable: UserDefaults.standard,
//            prefixIdentifier: "com.getaclue.dv.whatsnewk"
//        )
//        
//        let version = WhatsNew.Version.current()
//        
//        let hasVersion = keyValueVersionStore.has(version: version)
        
//        print("version: \(version) \t hasVersion : \(hasVersion)")
        
        
        
//        var configurator = WhatsNewViewController.Configuration()
        
//        var detailBtn = WhatsNewViewController.DetailButton(title: "Leave a Review", action: .custom(action: { _ in
//            let appstoreLink = "itms-apps://itunes.apple.com/app/id1332324033?action=write-review"
//            if let url = URL.init(string: appstoreLink), UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        }))
        
//        detailBtn.hapticFeedback = .selection
        
//        configurator.backgroundColor = .white
//        configurator.titleView.titleColor = .orange
//        configurator.detailButton = detailBtn
//        configurator.detailButton?.titleColor = .orange
//        configurator.completionButton.backgroundColor = .orange
//        configurator.apply(animation: .slideLeft)
        
//        let whatsNew = WhatsNew(
//            version: version,
//            title: "What's New in Daily Vibes",
//            items: [
//                WhatsNew.Item(
//                    title: "Year 2",
//                    subtitle: "Thank you for your continued support. Expect to see some upcoming changes as I prepare for the 2.0 release.",
//                    image: #imageLiteral(resourceName: "dvNewIcon")
//                ),
//                WhatsNew.Item(
//                    title: "New feature: Daily Vibes",
//                    subtitle: "Take control of your stressors by noticing and tracking them. Add numbers to things that you cannot measure. ",
//                    image: #imageLiteral(resourceName: "heart")
//                ),
//                WhatsNew.Item(
//                    title: "Add a new vibes entry",
//                    subtitle: "Take note of exactly how you feel at a particular moment in your day. Be mindful and adjust as you see fit.",
//                    image: #imageLiteral(resourceName: "dvArrowUpGreen")
//                )
//            ]
//        )
        
//        versionStore: InMemoryWhatsNewVersionStore()
        
//        let whatsNewViewController = WhatsNewViewController(
//            whatsNew: whatsNew,
//            configuration: configurator,
//            versionStore: keyValueVersionStore
//            )
        
//        self.present(whatsNewViewController, animated: true)
//        whatsNewViewController?.present(on: self)
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
        cell.todoItemLabel.numberOfLines = 0
        cell.layer.theme_borderColor = "Global.backgroundColor"
        
        cell.selectedBackgroundView = customSelectionView
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        if todoItem.isCompleted {
            // COMPLETED ITEM
            
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = .none
            
            cell.todoItemLabel.attributedText = stringStrikeThrough(input: todoItem.todoItemText)
            
            cell.emotionsImageView.image = UIImage(named: "checkedcircle_icon_dailyvibes")
            
            if let completedDate = todoItem.completedAt {
                let fullString = NSMutableAttributedString(string: "")
                
                let dateString = dateFormatter.string(from: completedDate)
                let result = NSMutableAttributedString(string: dateString)
                let range = (dateString as NSString).range(of: dateString)

                if let _ = ThemeManager.value(for: "Global.backgroundColor") as? String,
                    let placeholderColor = ThemeManager.value(for: "Global.placeholderColor") as? String {
                    
                    result.addAttributes([NSAttributedString.Key.backgroundColor: UIColor.clear], range: range)
                    result.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.from(hex: placeholderColor)], range: range)
                }

                
                let title = result
                
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
            // NOT COMPLETED ITEM
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = .none
            
            cell.todoItemLabel.text = todoItem.todoItemText.trunc(length: 140)
            cell.emotionsImageView.image = UIImage(named: "emptycircle_icon_dailyvibes")
            
            if cell.emotionsImageView.gestureRecognizers?.count ?? 0 == 0 {
                // if the image currently has no gestureRecognizer
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                cell.emotionsImageView.addGestureRecognizer(tapGesture)
                cell.emotionsImageView.isUserInteractionEnabled = true
            }
            
            let fullString = NSMutableAttributedString(string: "")
            
            if let dueDate = todoItem.duedateAt, dueDate.isInThePast {
                let createdString = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND CREATED **", comment: "")
                let uiTextFieldStringAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
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
    
    // imgTapped
    // change data model blah-blah
    //        print("testing-testing")
    //        https://guides.codepath.com/ios/Using-Gesture-Recognizers
    //        https://stackoverflow.com/a/29360703
    
    @objc private func imgTapped(sender: UITapGestureRecognizer) {
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
            if let goto = segue.destination as? TodoTaskItemFiltersViewController {
                
                let _color = ThemeManager.value(for: "Global.barTintColor")
                
                guard let rgba = _color as? String else {
                    fatalError("could not get value from ThemeManager")
                }
                
                let color = UIColor(rgba: rgba)
                
                let sourceViewController = self
                
                let alert = UIAlertController(style: .actionSheet, title: nil, message: nil)

                
                let title = NSLocalizedString("Sort by", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sort by **", comment: "")
                let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
                
                let notificationsImage = #imageLiteral(resourceName: "dv_bell_notifications")
                alert.addAction(image: notificationsImage, title: "View Notifications", color: .black, style: .default, isEnabled: true) { (action) in
                    let storyboard = UIStoryboard.init(name: "DVLocalNotifications", bundle: nil)
                    let tvc = storyboard.instantiateViewController(withIdentifier: "dvLNTableViewController")
                    
                    ContextMenu.shared.show(sourceViewController: self, viewController: tvc, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)))
                }
                let filterImage = #imageLiteral(resourceName: "dvFilterIcon")
                let filterTitle = title + " " + store.dvfilter.rawValue.capitalized
                alert.addAction(image: filterImage, title: filterTitle, color: .black, style: .default, isEnabled: true) { (action) in
                    ContextMenu.shared.show(sourceViewController: sourceViewController, viewController: goto, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)))
                }
                
                alert.addAction(title: cancelString, style: .cancel)
                sourceViewController.present(alert, animated: true, completion: nil)
            }
        case "DVLikertScaleItemUI":
            if let nav = segue.destination as? UINavigationController, let _ = nav.topViewController as? LikertScaleDateTVC {
                
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
                
                if let sectionString = sectionHeaderHelper(forDateString: sectionID.sectionIdentifier) {
                    let uppd = sectionString.uppercased()
                    
                    let resultstr = "\(uppd) [\(progress)%]"
                    return resultstr
                } else {
                    return nil
                }
                
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
//                print(date.sectionIdentifier)
                return date.sectionIdentifier
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if taskItemsAll.count == 1 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print("taskitemallcount \(taskItemsAll.count)")
        if taskItemsAll.count == 1 {
            return nil
        } else {
            let label = UILabel.init(frame: CGRect.init(x: 17, y: 4, width: tableView.width, height: 20))
            
            label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            label.textAlignment = .left
            label.theme_textColor = "Global.textColor"
            label.theme_backgroundColor = "Global.backgroundColor"
            label.text = self.tableView(tableView, titleForHeaderInSection: section)?.localizedCapitalized
            
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.width, height: label.height))
            
            view.theme_backgroundColor = "Global.backgroundColor"
            view.addSubview(label)
            
            return view
        }
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
        result.addAttribute(NSAttributedString.Key.strikethroughStyle,
                            value: NSUnderlineStyle.single.rawValue,
                            range: range)
        
        if let _ = ThemeManager.value(for: "Global.barTintColor") as? String,
            let foregroundColor = ThemeManager.value(for: "Global.textColor") as? String {
            result.addAttributes([NSAttributedString.Key.backgroundColor: UIColor.clear], range: range)
            result.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.from(hex: foregroundColor)], range: range)
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
