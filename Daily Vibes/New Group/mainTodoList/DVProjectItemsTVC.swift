//
//  DVProjectItemsTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-02-08.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData
import SwiftTheme
import ContextMenu
import DeckTransition

class DVProjectItemsTVC: ThemableTableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private var store = CoreDataManager.store
    
//    private var taskItemsAll = [DVCoreSectionViewModel]() {
//        didSet {
//            self.tableView.reloadData()
//        }
//    }
    
    var uuid: UUID?
    var list: DailyVibesList?
    
    private var mngdctx = CoreDataManager.store.context
    var items = [TodoItem]()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    private func fetchListListItems() {
        
//        guard let searchUUID = uuid else {
        
        if uuid == nil {
            let defaultListString = "Inbox"
            let foundprojet = store.findDVList(byLabel: defaultListString)
            
            if foundprojet.isDVDefault, let _uuid = foundprojet.uuid {
                uuid = UUID(uuidString: _uuid.uuidString)
            }
        }
//            fatalError("need data's uuid")
//        }
        
        
        guard let searchUUID = uuid else {
            fatalError("need datas uuid")
        }
        
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DailyVibesList")
        
        //        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        fetchRequest.relationshipKeyPathsForPrefetching = ["listItems"]
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", argumentArray: [searchUUID])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: CoreDataManager.store.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            
            
            // ERROR HERE WHY?
            guard let result = fetchedResultsController.fetchedObjects as? [DailyVibesList],
                let topDate = result.first else {
                    fatalError("need my DailyVibesList hurr")
            }
            
            list = topDate
            
            if let e = topDate.listItems, let _entries = e.allObjects as? [TodoItem] {
                items = _entries.sorted(by: { (item1, item2) -> Bool in
                    return item1.updatedAt! > item2.updatedAt!
                })
            }
        } catch let error as NSError {
            print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
        }
    }
    
    lazy var customSelectionView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    private var streakManager = StreakManager()
    
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
        // GRAB THE DATA
        fetchListListItems()
        
        // SETUP DISPLAY
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
//        let backItem = UIBarButtonItem(title: "BACK", style: .plain, target: self, action: nil)
//        navigationItem.leftBarButtonItem = backItem
        
        // SETUP NAVBAR
        if let _list = list, let _title = _list.title {
            if let _emoji = _list.emoji {
                navigationItem.title = _emoji + " " + _title
            } else {
                navigationItem.title = _title
            }
        }
        navigationItem.rightBarButtonItems = [dotdotdotbtn]
        
        self.tableView.reloadData()
        hideOrShowTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDataAndNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
//        tableView.theme_separatorColor = "Global.backgroundColor"
        
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
        
        setupFloatingBtn()
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
        
        if let _hasProject = list, let _projectTitle = _hasProject.title {
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
                            self.list?.title = newTitle
                            self.store.saveContext()
                            
                            DispatchQueue.main.async {
                                self.navigationItem.title = self.list?.title
                            }
                            
                            let feedback = UIImpactFeedbackGenerator()
                            feedback.impactOccurred()
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
                        self.list?.emoji = newEmoji
                        self.store.saveContext()
                        
                        DispatchQueue.main.async {
                            if let _list = self.list, let emoji = _list.emoji, let title = _list.title {
                            self.navigationItem.title =  emoji + " " +  title
                            }
                        }
                        
                        let feedbck = UIImpactFeedbackGenerator()
                        feedbck.impactOccurred()
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
        
        if self.isMovingFromParent {
            print("moving from parent")
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
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sections = self.fetchedResultsController?.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        let sectionInfo = sections[section]
//        return sectionInfo.numberOfObjects
        return items.count
    }
    
    
    // gesture recognizer idea from https://d.pr/kTnQvo
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "TodoItemTableViewCell"
        
        let cellIDentifier = "dvTodoitemtaskView"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIDentifier, for: indexPath) as? DVProjectItemsTVCItemCell else {
            fatalError("need dat DVProjectItemsTVCItemCell cell")
        }
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TodoItemTableViewCell else {
//            fatalError("The dequeued cell is not an instance of TodoItemTableViewCell.")
//        }
        
//        let sectionLocation = indexPath.section
        let todoItemTaskLocation = indexPath.row
        let todoItem = items[todoItemTaskLocation]
        
//        let todoItemTasks = taskItemsAll[sectionLocation].objects()
//        let todoItem = todoItemTasks[todoItemTaskLocation]
        let dateFormatter = DateFormatter()
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
//        cell.todoItemLabel.theme_textColor = "Global.textColor"
//        cell.todoItemTagsLabel.theme_textColor = "Global.placeholderColor"
//        cell.todoItemLabel.numberOfLines = 0
        cell.title.theme_textColor = "Global.textColor"
        cell.title.theme_backgroundColor = "Global.barTintColor"
//        cell.layer.theme_borderColor = "Global.backgroundColor"
        
        cell.selectedBackgroundView = customSelectionView
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
//        cell.taskitemimageview.theme_backgroundColor = "Global.barTintColor"
        cell.completedAt.text = " "
        cell.completedAt.theme_backgroundColor = "Global.barTintColor"
        cell.emotionsImageView?.image = #imageLiteral(resourceName: "emptycircle_icon_dailyvibes")
        cell.emotionsImageView.theme_backgroundColor = "Global.barTintColor"
        cell.duedateAt.text = " "
        cell.duedateAt.theme_backgroundColor = "Global.barTintColor"
        cell.tags.text = " "
        cell.tags.theme_backgroundColor = "Global.barTintColor"
        cell.notes.text = " "
        cell.notes.theme_backgroundColor = "Global.barTintColor"
        cell.archived.text = " "
        cell.archived.theme_backgroundColor = "Global.barTintColor"
        
//        cell.layer.theme_borderColor = "Global.backgroundColor"
//        cell.layer.borderWidth = 3
//        cell.layer.masksToBounds = true
        
        // if not completed - completed at == due at
        // if completed - completed at == completed at
        // duedateat = lastupdatedat
        
        if let text = todoItem.todoItemText {
            if todoItem.completed {
                // COMPLETED ITEM
                
//                dateFormatter.dateStyle = DateFormatter.Style.short
//                dateFormatter.timeStyle = .none
                
                cell.title.attributedText = stringStrikeThrough(input: text.trunc(length: 140))
                cell.emotionsImageView?.image = #imageLiteral(resourceName: "checkedcircle_icon_dailyvibes")
            } else {
                cell.title.text = text.trunc(length: 140)
                
                if cell.emotionsImageView.gestureRecognizers?.count ?? 0 == 0 {
                    // if the image currently has no gestureRecognizer
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                    cell.emotionsImageView.addGestureRecognizer(tapGesture)
                    cell.emotionsImageView.isUserInteractionEnabled = true
                }
            }
            
            if let updatedat = todoItem.updatedAt {
//                cell.duedateAt.theme_backgroundColor = "Pill.backgroundColor"
                cell.duedateAt.theme_textColor = "Global.placeholderColor"
                cell.duedateAt.maskToBounds = true
                cell.duedateAt.cornerRadius = 3.0
                cell.duedateAt.text = " " + updatedat.since() + " "
                cell.duedateAt.textAlignment = .center
//                cell.archived.sizeToFit()
            }
            
            cell.completedAt.theme_backgroundColor = "Global.barTintColor"
            cell.completedAt.text = " "
            cell.completedAt.textAlignment = .center
//                cell.completedAt.sizeToFit()
            
            if let duedateat = todoItem.duedateAt {
//                    cell.completedAt.backgroundColor = UIColor.orange
                if duedateat.isInPast {
//                        cell.completedAt.textColor = UIColor.orange
                    cell.completedAt.backgroundColor = UIColor.orange
                    cell.completedAt.textColor = UIColor.black
                } else if duedateat.isInFuture {
//                        cell.completedAt.textColor = UIColor.whatsNewKitBlue
                    cell.completedAt.backgroundColor = UIColor.whatsNewKitBlue
                    cell.completedAt.textColor = UIColor.white
                }
                cell.completedAt.layer.masksToBounds = true
                cell.completedAt.layer.cornerRadius = 3.0
//                    cell.completedAt.theme_backgroundColor = "Pill.backgroundColor"
                cell.completedAt.text = " " + duedateat.since() + " "
//                    cell.completedAt.sizeToFit()
            }
            
//            if let updatedat = todoItem.updatedAt {
//                cell.duedateAt.text = "Last updated " + dateFormatter.string(from: updatedat) + " "
//            }
            
//            if let duedateat = todoItem.duedateAt {
//                cell.duedateAt.backgroundColor = UIColor.orange
//                cell.duedateAt.textColor = UIColor.black
//                cell.duedateAt.layer.masksToBounds = true
//                cell.duedateAt.layer.cornerRadius = 3.0
//                cell.duedateAt.textAlignment = .center
//                cell.duedateAt.text = " " + dateFormatter.string(from: duedateat) + " "
//                cell.duedateAt.sizeToFit()
//            } else {
//                cell.duedateAt.theme_backgroundColor = "Global.barTintColor"
//                cell.duedateAt.text = ""
//            }
            
            if let tags = todoItem.tags, tags.count > 0 {
                cell.tags.text = " 🔖 "
                cell.tags.textAlignment = .center
                cell.tags.theme_backgroundColor = "Global.barTintColor"
                cell.tags.layer.masksToBounds = true
                cell.tags.layer.cornerRadius = 3.0
            } else {
                cell.tags.theme_backgroundColor = "Global.barTintColor"
                cell.tags.text = " "
                cell.tags.textAlignment = .center
                cell.tags.layer.masksToBounds = true
                cell.tags.layer.cornerRadius = 3.0
            }
            
            if let _notes = todoItem.notes, let content = _notes.content, !content.isEmpty {
                let contentcount = content.components(separatedBy: " ").count
                cell.notes.text = "\(contentcount)words"
                cell.notes.textAlignment = .center
                cell.notes.theme_backgroundColor = "Global.barTintColor"
                cell.notes.theme_textColor = "Global.placeholderColor"
                cell.notes.maskToBounds = true
                cell.notes.layer.cornerRadius = 3.0
            } else {
                cell.notes.theme_backgroundColor = "Global.barTintColor"
                cell.notes.theme_textColor = "Global.placeholderColor"
                cell.notes.text = " "
                cell.notes.textAlignment = .center
                cell.notes.maskToBounds = true
                cell.notes.layer.cornerRadius = 3.0
            }
            
//            if todoItem.isArchived {
//                cell.archived.text = " 💼 "
//                cell.archived.textAlignment = .center
//                cell.archived.theme_backgroundColor = "Global.barTintColor"
//            } else {
//                cell.archived.theme_backgroundColor = "Global.barTintColor"
//                cell.archived.text = " "
//                cell.archived.textAlignment = .center
//            }
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
            
//            let section = taskItemsAll[indexPath.section]
//            let todo = section.object(at: indexPath)
            let todo = items[indexPath.row]
            
            doneAction(for: todo, at: indexPath)
        }
    }
    
    private func doneAction(for todoItem:TodoItem, at indexPath:IndexPath) {
        let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
        let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
        let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
        let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
        
        if showDoneAlert {
            let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .default , handler: { [unowned self] _ in
                
                let curDate = Date()
                
                todoItem.completed = true
                todoItem.updatedAt = curDate
                todoItem.completedAt = curDate
                todoItem.list?.updatedAt = curDate
                
                self.store.saveContext()
                
                let result = self.streakManager.process(item: todoItem)
                
                if result {
                    let feedback = UIImpactFeedbackGenerator()
                    feedback.impactOccurred()
                }
                
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.tableView.endUpdates()
            }))
            
            alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let curDate = Date()
            
            todoItem.completed = true
            todoItem.updatedAt = curDate
            todoItem.completedAt = curDate
            todoItem.list?.updatedAt = curDate
            
            self.store.saveContext()
            
            let result = self.streakManager.process(item: todoItem)
            
            if result {
                let feedback = UIImpactFeedbackGenerator()
                feedback.impactOccurred()
            }
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
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
        case "ShowDetailView":
            guard segue.destination is UINavigationController else {
                fatalError("Unexpected destination = \(segue.destination)")
            }
            guard let selectedTodoItemCell = sender as? TodoItemTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTodoItemCell) else {
                fatalError("Selected sell is not being displayed on the table")
            }
            
//            let section = indexPath.section
            let item = items[indexPath.row]
            
            if let uuid = item.id {
                store.findOrCreateTodoitemTaskDeepNested(withUUID: uuid)
            }
            
        case "ShowNewDetailView":
            guard segue.destination is UINavigationController else {
                fatalError("Unexpected destination = \(segue.destination)")
            }
            guard let selectedTodoItemCell = sender as? DVProjectItemsTVCItemCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTodoItemCell) else {
                fatalError("Selected sell is not being displayed on the table")
            }
            
            //            let section = indexPath.section
            let item = items[indexPath.row]
            
            if let uuid = item.id {
                store.findOrCreateTodoitemTaskDeepNested(withUUID: uuid)
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
        
        if let hasProject = list,
            let projectTitle = hasProject.title,
            projectTitle == thisWeekIdentifier {
            
            if items.count > 0 {
                //            return taskItemsAll[section].sectionIdentifier
//                let sectionID = taskItemsAll[section]
//                let completedCount = sectionID.completedObjects.count
//                let allCount = sectionID.allObjects.count
//
//                let progress = Int(ceil((Double(completedCount)/Double(allCount)) * 100))
//
//                if let sectionString = sectionHeaderHelper(forDateString: sectionID.sectionIdentifier) {
//                    let uppd = sectionString.uppercased()
//
//                    let resultstr = "\(uppd) [\(progress)%]"
//                    return resultstr
//                } else {
//                    return nil
//                }
                
                Log("NEED TO FIX THIS titleForHeaderInSection METHOD")
                
                return nil
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func sectionHeaderHelper(forDateString _date: String) -> String? {
        let dateFormatter = DateFormatter()
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if items.count == 1 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        print("taskitemallcount \(taskItemsAll.count)")
        if items.count == 1 {
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
    
    // MARK: - Custom swipe right
    
    //    https://developerslogblog.wordpress.com/2017/06/28/ios-11-swipe-leftright-in-uitableviewcell/
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let section = taskItemsAll[indexPath.section]
//        let _todo = section.object(at: indexPath)
        
        let _todo = items[indexPath.row]
        
        var actions = [UIContextualAction]()
        
        if !_todo.completed {
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

                        let curDate = Date()

                        _todo.completed = true
                        _todo.updatedAt = curDate
                        _todo.completedAt = curDate
                        _todo.list?.updatedAt = curDate

                        self.store.saveContext()

                        let result = self.streakManager.process(item: _todo)

                        if result {
                            let feedback = UIImpactFeedbackGenerator()
                            feedback.impactOccurred()
                        }

//                        self.tableView.beginUpdates()
//                        self.tableView.reloadRows(at: [indexPath], with: .fade)
//                        self.tableView.endUpdates()
                        self.setupDataAndNavBar()

                    }))
                    alert.addAction(UIAlertAction(title: doneAlertCancel, style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {

                    let curDate = Date()

                    _todo.completed = true
                    _todo.updatedAt = curDate
                    _todo.completedAt = curDate
                    _todo.list?.updatedAt = curDate

                    self.store.saveContext()

                    let result = self.streakManager.process(item: _todo)

                    if result {
                        let feedback = UIImpactFeedbackGenerator()
                        feedback.impactOccurred()
                    }

                    self.setupDataAndNavBar()
                }
            })
            
            actions.append(closeAction)
            closeAction.title = doneLabel
            closeAction.backgroundColor = UIColor.whatsNewKitGreen
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // MARK: - Overwriting trailingSwipeAction
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let section = taskItemsAll[indexPath.section]
//        let todoItemTask = section.object(at: indexPath)
        
        let todoItemTask = items[indexPath.row]
        
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
//        let section = taskItemsAll[indexPath.section]
//        let removable = section.object(at: indexPath)
        
        let removable = items[indexPath.row]
        
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
                    if let uuid = removable.id {
                        self.deleteEntry(using: uuid)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                
                if let uuid = removable.id {
                    self.deleteEntry(using: uuid)
                }
            }
        }
        action.title = deleteLabel
        action.backgroundColor = UIColor.whatsNewKitRed
        return action
    }
    
    fileprivate func deleteEntry(using uuid:UUID) {
        //        let request: NSFetchRequest<LikertItemEntry> = LikertItemEntry.fetchRequest()
        let request: NSFetchRequest<TodoItem> = NSFetchRequest(entityName: "TodoItem")
        
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [uuid])
        request.fetchLimit = 1
        
        do {
            guard var result = try? mngdctx.fetch(request) else {
                fatalError("failed on the delete")
            }
            
            guard let tobedeleted = result.popLast() else {
                fatalError("didn't find by uuid")
            }
            
            tobedeleted.list?.updatedAt = Date()
            mngdctx.delete(tobedeleted)
            
            try mngdctx.save()
            
            setupDataAndNavBar()
            self.tableView.reloadData()
            
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
        } catch let error as NSError {
            print("error: \(error) with \(error.userInfo)")
        }
    }
    
    private func contextualToggleArchiveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
//        let sectionVM = taskItemsAll[indexPath.section]
//        let _todoItem = sectionVM.object(at: indexPath)
        
        let _todoItem = items[indexPath.row]
        
        if !_todoItem.isArchived {
            let archiveLabel = NSLocalizedString("Archive", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archive ***", comment: "")
            
            let action = UIContextualAction(style: .normal, title: archiveLabel) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
//                let _ = self.store.archiveTodoitemTask(task: _todoItem)
//                self.setupDataAndNavBar()
//                completionHandler(true)
                
                let curDate = Date()
                
                _todoItem.isArchived = true
                _todoItem.updatedAt = curDate
                _todoItem.archivedAt = curDate
                _todoItem.list?.updatedAt = curDate
                
                self.store.saveContext()
                
                let feedback = UIImpactFeedbackGenerator()
                feedback.impactOccurred()
                
                completionHandler(true)
            }
            
            // 7
            action.title = archiveLabel
            action.backgroundColor = UIColor.whatsNewKitBlue
            return action
        } else {
            // if item is archived... return an empty action
            return UIContextualAction()
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
        
        return result
    }
    
    private func hideOrShowTableView() {
        if items.count == 0 {
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
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//        case .delete:
//            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//        case .move:
//            break
//        case .update:
//            break
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
}
