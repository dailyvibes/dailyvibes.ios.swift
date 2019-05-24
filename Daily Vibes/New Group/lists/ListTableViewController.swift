//
//  ListTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-12.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit
import DeckTransition

//import QuartzCore

import CoreData

struct ListCreator {
    private var location = IndexPath(row: 0, section:0)
    
    func isLocated(at indexPath: IndexPath?) -> Bool {
        if indexPath!.row == location.row && indexPath!.section == location.section {
            return true
        } else {
            return false
        }
    }
}

class ListTableViewController: ThemableTableViewController {
    
    // MARK: - Properties
    private var listCreator = ListCreator()
    
////    private var editingTodotaskItem: DVTodoItemTaskViewModel? {
////        didSet {
////            self.tableView.reloadData()
////        }
//    }
//
    
    lazy var newTaskBtn: AAFloatingButton = {
        let btnSize = CGFloat(48)
        let btnFrame = CGRect(x: 0, y: 0, width: btnSize, height: btnSize)
        let btn = AAFloatingButton(frame: btnFrame)
        
        let uiimage = #imageLiteral(resourceName: "dvAdd002Icon")
        let coloreduiimage = uiimage.tint(color: .white)
        
        btn.setImage(coloreduiimage, for: .normal)
        btn.buttonBackgroundColor = .whatsNewKitPurple
        btn.addTarget(self, action: #selector(handleNewDVTaskItemBtn), for: .touchDown)
        btn.accessibilityIdentifier = "dv_list_new_dvtaskitem"
        
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
        
        let sb = UIStoryboard(name: "DVMultipleTodoitemtaskItems", bundle: nil)
        let tvc = sb.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsNC")
        
        let transitionDelegate = DeckTransitioningDelegate(isSwipeToDismissEnabled: false)
        tvc.transitioningDelegate = transitionDelegate
        tvc.modalPresentationStyle = .custom
        
        present(tvc, animated: true, completion: nil)
    }
    
    private var listVM = [DVListViewModel]() {
        didSet {
            defaultProjectList = listVM.filter({ (listVM) -> Bool in
                return listVM.isDVDefault == true
            })
            
//            defaultProjectList = defaultProjectList?.sorted(by: { (dvlistmodel1, dvlistmodel2) -> Bool in
//                return dvlistmodel1.updatedAt < dvlistmodel2.updatedAt
//            })
            
            customProjectList = listVM.filter({ (listVM) -> Bool in
                return listVM.isDVDefault == false
            })
            
//            customProjectList = customProjectList?.sorted(by: { (dvlistmodel1, dvlistmodel2) -> Bool in
//                return dvlistmodel1.updatedAt > dvlistmodel2.updatedAt
//            })
            
            self.tableView.reloadData()
        }
    }
    
    var inModalView: Bool = false
    
    let store = CoreDataManager.store
    var currentProjectlist: DVListViewModel?
    var allProjectList: [DVListViewModel]?
    var defaultProjectList: [DVListViewModel]?
    var customProjectList: [DVListViewModel]?
    
    private var addingNewCell: Bool = false
    
    lazy var customSelectedView : UIView = {
        let view = UIView(frame: .zero)
        
        view.borderWidth = 3
        view.layer.theme_borderColor = "Global.backgroundColor"
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    lazy var cancelBtn : UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        btn.accessibilityIdentifier = "DVListViewModel.cancel.btn"
        
        return btn
    }()
    
    @objc
    func handleCancel(){
        dismiss(animated: true, completion: nil)
//        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func cookData() {
        store.fetchListsViewModel()
        
        currentProjectlist = store.filteredProjectList
        allProjectList = store.dvListsVM
        
        if let projects = allProjectList {
            var ddata = [DVListViewModel]()
            var cdata = [DVListViewModel]()
            
            for project in projects {
                if project.isDVDefault {
                    if let title = project.title {
                        if (title == "Today") || (title == "This week") {
                            if !inModalView {
                                ddata.append(project)
                            }
                        } else {
                            ddata.append(project)
                        }
                    }
                } else {
                    cdata.append(project)
                }
            }
            
            defaultProjectList = ddata
            customProjectList = cdata
        }
        
//        for project in allProjectList {
//            if pr
//        }
        
//        defaultProjectList = allProjectList?.filter({ (listVM) -> Bool in
//            return listVM.isDVDefault == true
//        })
//
////        defaultProjectList = defaultProjectList?.sorted(by: { (list1, list2) -> Bool in
////            return list1.createdAt > list2.createdAt
////        })
//
//        customProjectList = allProjectList?.filter({ (listVM) -> Bool in
//            return listVM.isDVDefault == false
//        })
        
//        customProjectList = customProjectList?.sorted(by: { (list1, list2) -> Bool in
//            return list1.createdAt < list2.createdAt
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (inModalView) {
//            let _text = "Switch Project"
            let switchStr = NSLocalizedString("Switch", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Switch **", comment: "")
//            let customNavigationTitle = NSLocalizedString(_text, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText \(_text) **", comment: "")
            let projectStr = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
            let customNavigationTitle = switchStr + " " + projectStr
            
//            setupNavigationTitleText(title: customNavigationTitle, subtitle: nil)
            navigationItem.title = customNavigationTitle
            
            navigationItem.leftBarButtonItems = [cancelBtn]
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        } else {
            let _text = "Projects"
            let customNavigationTitle = NSLocalizedString(_text, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText \(_text) **", comment: "")
            
            navigationItem.title = customNavigationTitle
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            setupFloatingBtn()
        }
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
        
        cookData()
        
        
//        self.tableView.setContentOffset(8.0, animated: true)
//        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        let tbframe = tableView.frame
//        self.tableView.frame = CGRect(x: 16, y: 0, width: tbframe.width-16, height: tbframe.height)
//        self.tableView.layer.cornerRadius = 8
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        store.editingDVTodotaskItem = editingTodotaskItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (inModalView) {
            let screenRect = UIScreen.main.bounds
            let screenWidth = screenRect.size.width
            let screenHeight = screenRect.size.height
            
            self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
        }
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        tableView.tableFooterView = UIView(frame: .zero)
        
        
//        tableView.register(ListProjectTVC.self, forCellReuseIdentifier: "listProjectCell")
//        let redColor = UIColor.whatsNewKitRed
//        self.tableView.layer.borderColor = redColor.withAlphaComponent(0.9).cgColor
//        self.tableView.layer.borderWidth = 1;
//        self.tableView.layer.cornerRadius = 4;
        
//        tableView.frame = CGRect(x: 16, y: 0, width: (tableView.frame.width - 16), height: tableView.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Magic number of 3
        // 1 = add row
        // 2 = default list
        // 3 = custom list (made via add row entrie)
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            if let hasList = defaultProjectList, hasList.count > 0 {
                return hasList.count
            } else {
                return 0
            }
        }
        if section == 2 {
            if let hasCustomList = customProjectList, hasCustomList.count > 0 {
                return hasCustomList.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 72
        } else {
            return UITableView.automaticDimension
        }
    }
    
    // we need adjustedIndexPath b/c our initial row is set to input row
    // so we just need to adjust for the row that we are getting
    // and we are only having 1 section for the forseable future
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let displayCell = "listsDisplayCell"
        let createCell = "listCreateCell"
        
        let section = indexPath.section
//        let indexPathRow = indexPath.row
        
        if section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: createCell, for: indexPath) as? ListCreationTableViewCell else {
                fatalError("need dat ListCreationTableViewCell ")
            }
            
            cell.listLabeler.delegate = self
            
            return cell
        }
        
//        if section == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
//
//            if let _defaultProjectList = defaultProjectList {
//
//                let list = _defaultProjectList[indexPathRow]
//
//                cell.textLabel?.text = list.title
//                cell.detailTextLabel?.text = ""
////                TODO THIS WAS EDITED
//
//                if store.editingDVTodotaskItemListPlaceholder != nil {
//                    if list.uuid == store.editingDVTodotaskItemListPlaceholder?.uuid {
//                        cell.accessoryType = .checkmark
//                    } else {
//                        cell.accessoryType = .none
//                    }
//                } else {
//                    cell.accessoryType = .none
//                }
//
//                cell.theme_backgroundColor = "Global.barTintColor"
//                cell.textLabel?.theme_textColor = "Global.textColor"
//                cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
//                cell.theme_tintColor = "Global.barTextColor"
//
//                return cell
//            }
//        }
//
//        if section == 2 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
//
//            if let _defaultProjectList = customProjectList {
//
//                let list = _defaultProjectList[indexPathRow]
//
//                cell.textLabel?.text = list.title
//                cell.detailTextLabel?.text = ""
//
//                // TODO REMOVE
//
//                if store.editingDVTodotaskItemListPlaceholder != nil {
//                    if list.uuid == store.editingDVTodotaskItemListPlaceholder?.uuid {
//                        cell.accessoryType = .checkmark
//                    } else {
//                        cell.accessoryType = .none
//                    }
//                } else {
//                    cell.accessoryType = .none
//                }
//
//                cell.theme_backgroundColor = "Global.barTintColor"
//                cell.textLabel?.theme_textColor = "Global.textColor"
//                cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
//                cell.theme_tintColor = "Global.barTextColor"
//
//                return cell
//            }
//        }
        
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "defaultListTVCCell")
//
//        cell.theme_backgroundColor = "Global.barTintColor"
//        cell.theme_tintColor = "Global.barTextColor"
//
//        cell.textLabel?.theme_textColor = "Global.textColor"
//        cell.selectedBackgroundView = customSelectedView
        
//        let verticalPadding: CGFloat = 8
        
//        let maskLayer = CALayer()
//        maskLayer.cornerRadius = 10    //if you want round edges
//        maskLayer.backgroundColor = UIColor.black.cgColor
//        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
//        cell.layer.mask = maskLayer
        
//        if indexPath.row == 0 {
////            cell.layer.rad
////            cell.layer.cornerRadius = 10
//            //        cell.layer.borderWidth = 3.0
////            cell.layer.theme_borderColor = "Global.backgroundColor"
//        }
        
        // Configure the cell...
//        let section = indexPath.section
        
        if section == 1 {
            guard let ccell = tableView.dequeueReusableCell(withIdentifier: "listProjectTVC", for: indexPath) as? ListProjectTVC else {
                fatalError("failed to get the ListProjectTVC")
            }
            
            ccell.theme_backgroundColor = "Global.barTintColor"
            ccell.theme_tintColor = "Global.backgroundColor"
            ccell.textLabel?.theme_textColor = "Global.textColor"
            ccell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
            ccell.selectedBackgroundView = customSelectedView
            ccell.layer.theme_borderColor = "Global.backgroundColor"
            
            if let projectList = defaultProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                
                if let title = projectList.title {
                    ccell.textLabel?.text = title
                    //                cell.imageView?.image = projectList.emoji?.imageFromEmoji()
                    if let image = projectList.emoji?.imageFromEmoji(24, 24) {
                        ccell.imageView?.image = image
                    }
                    
                    if projectList.listItemCountTotal > 0 {
                        ccell.detailTextLabel?.text = "\(projectList.listItemCountTotal)"
                        //                    print("should print count, \(projectList.listItemCountTotal), project, \(projectList.title ?? "")")
                    } else {
                        ccell.detailTextLabel?.text = ""
                    }
                    //                cell.imageView?.theme_backgroundColor = "Global.barTintColor"
                    //                                if let _items = projectList.listItems {
                    //                                    let _count = _items.count
                    //                //                    Log("count: \(_count) \t \(projectList.title)")
                    //                                    cell.detailTextLabel?.text = "\(_count)"
                    //                                }
                    if inModalView {
                        if projectList.uuid == currentFilteredProjectlist.uuid {
                            
                            let image = #imageLiteral(resourceName: "checkmark").tint(color: .whatsNewKitPurple)
                            let imageview = UIImageView(image: image)
                            //                        imageview.theme_tintColor = "Global.barTextColor"
                            
                            ccell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                            ccell.accessoryView?.addSubview(imageview)
                            //                        ccell.detailTextLabel?.text = "Y"
                        } else {
                            //                    cell.accessoryType = .none
                            ccell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                        }
                    } else {
                        ccell.accessoryType = .disclosureIndicator
                        //                    ccell.accessoryView?.theme_tintColor = "Global.backgroundColor"
                    }
                }
            }
            
            return ccell
        }
        
        if section == 2 {
            guard let ccell = tableView.dequeueReusableCell(withIdentifier: "listProjectTVC", for: indexPath) as? ListProjectTVC else {
                fatalError("failed to get the ListProjectTVC")
            }
            
            ccell.theme_backgroundColor = "Global.barTintColor"
            ccell.theme_tintColor = "Global.barTextColor"
            ccell.textLabel?.theme_textColor = "Global.textColor"
            ccell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
            ccell.selectedBackgroundView = customSelectedView
            ccell.layer.theme_borderColor = "Global.backgroundColor"
            
            if let projectList = customProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                ccell.textLabel?.text = projectList.title
                
                if let image = projectList.emoji?.imageFromEmoji(24, 24) {
                    ccell.imageView?.image = image
                }
                
                if projectList.listItemCountTotal > 0 {
//                    ccell.detailTextLabel?.text = "\(projectList.listItemCountTotal)"
//                    print("should print count, \(projectList.listItemCountTotal), project, \(projectList.title ?? "")")
                    
                    ccell.detailTextLabel?.text = "\(projectList.listItemCountTotal)"
                    
//                    let string = "\(projectList.listItemCountTotal)"
//
//                    let label = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.frame.width, height: 45))
//                    label.font = UIFont.systemFont(ofSize: 12)
//                    label.textAlignment = .right
//                    label.theme_textColor = "Global.placeholderColor"
////                    label.autoresizingMask = .flexibleLeftMargin | .flexibleHeight
//                    label.theme_backgroundColor = "Global.backgroundColor"
//                    label.text = "\(projectList.listItemCountTotal)"
//
//                    ccell.contentView.addSubview(label)
                } else {
                    ccell.detailTextLabel?.text = ""
                }
//                if let _items = projectList.listItems {
//                    let _count = _items.count
//                    cell.detailTextLabel?.text = "\(_count)"
//                }
                if inModalView {
//                    print("in modal")
                    if projectList.uuid == currentFilteredProjectlist.uuid {
//                        print("projectList.uuid == currentFilteredProjectlist.uuid")
//                        ccell.accessoryType = .checkmark
//                        let image = "✔️".imageFromEmoji(24, 24)
                        
                        let image = #imageLiteral(resourceName: "checkmark").tint(color: .whatsNewKitPurple)
                        let imageview = UIImageView(image: image)
//                        imageview.theme_tintColor = "Global.barTextColor"
                        
                        ccell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                        ccell.accessoryView?.addSubview(imageview)
//                        ccell.accessoryView?.theme_tintColor = "Global.barTextColor"
//                        ccell.detailTextLabel?.text = "📌"
                    } else {
                        //                    cell.accessoryType = .none
//                        print("projectList.uuid != currentFilteredProjectlist.uuid")
                        ccell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                    }
                } else {
                    ccell.accessoryType = .disclosureIndicator
                }
                
//                ccell.detailTextLabel?.text = "LALALA"
                
                if newListCreated, let hasuuid = newCreatedListUUID {
                    if projectList.uuid == hasuuid {
                        print("setting project to scroll to")
                        newCreatedIndexpath = IndexPath(row: indexPath.row, section: indexPath.section)
                        newListCreated = false
                        
//                        ccell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                        
                        
//                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
//                        let newImage = "🆕".imageFromEmoji(24, 24)
//                        let imageView = UIImageView(image: newImage)
//
//                        ccell.accessoryView?.addSubview(imageView)
//
//                        view.addSubview(imageView)
                        
//                        if let indexPathToScrollTo = newCreatedIndexpath {
////                            tableView.beginUpdates()
////                            ccell.theme_backgroundColor = "Global.backgroundColor"
////                            tableView.endUpdates()
//
//                            tableView.scrollToRow(at: indexPathToScrollTo, at: .top, animated: true)
//
////                            UIView.animate(withDuration: 400) {
////                                tableView.beginUpdates()
////                                ccell.theme_backgroundColor = "Global.barTintColor"
////                                tableView.endUpdates()
////                            }
//
////                            tableView.selectRow(at: indexPathToScrollTo, animated: true, scrollPosition: .top)
////                            tableView.deselectRow(at: indexPathToScrollTo, animated: true)
//
////                            print("resetting the variables after scrolling")
//                            newListCreated = false
//                            newCreatedListUUID = nil
//                            newCreatedIndexpath = nil
//
////                            ccell.accessoryView = view
//                        }
//                        print("scrolling to \(indexPath) for project : \(projectList.uuid)")
//                        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                        print("resetting the variables after scrolling")
//                        newListCreated = false
//                        newCreatedListUUID = nil
                    }
                }
            }
            
            return ccell
        }
        
//        return cell
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
//        return cell
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "defaultListTVCCell")
        
        return cell
    }
    
    var newListCreated = false
    var newCreatedListUUID : UUID?
    var newCreatedIndexpath: IndexPath? {
        didSet {
            print("set newCreatedIndexPath")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let sectionRow = indexPath.row
        
        var selected: UUID?
        
        if section == 1 {
            if let defaultProjectlist = defaultProjectList {
                let newProjectlist = defaultProjectlist[sectionRow]
                
                selected = newProjectlist.uuid
                
                store.filteredProjectList = store.findListVM(withUUID: newProjectlist.uuid)
                store.editingDVTodotaskItemListPlaceholder = store.findListVM(withUUID: newProjectlist.uuid)
            }
        }
        
        if section == 2{
            if let defaultProjectlist = customProjectList {
                let newProjectlist = defaultProjectlist[sectionRow]
                
                selected = newProjectlist.uuid
                
                store.filteredProjectList = store.findListVM(withUUID: newProjectlist.uuid)
                store.editingDVTodotaskItemListPlaceholder = store.findListVM(withUUID: newProjectlist.uuid)
            }
        }
        
        UserDefaults.standard.set(store.filteredProjectList?.title, forKey: "com.getaclue.dv.user.project")
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("ListTableViewController.projectListChange"), object: nil)
        
        if (inModalView) {
//            do nothing
            dismiss(animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let projectitemslisttvc = storyboard.instantiateViewController(withIdentifier: "DailyVibesMainTableVC") as? DVProjectItemsTVC {
                let btn = UIImpactFeedbackGenerator()
                btn.impactOccurred()
                
                projectitemslisttvc.uuid = selected
                navigationController?.pushViewController(projectitemslisttvc, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let newStr = NSLocalizedString("New", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND New **", comment: "")
            
            return newStr.localizedUppercase
        }
        
        if section == 1 {
            let defaultStr = NSLocalizedString("Default", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Default **", comment: "")
            
            return defaultStr.localizedUppercase
        }
        
        if section == 2 {
            let customStr = NSLocalizedString("Custom", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Custom **", comment: "")
            
            return customStr.localizedUppercase
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 17, y: 4, width: tableView.width, height: 20))

        label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
        label.textAlignment = .left
        label.theme_textColor = "Global.textColor"
        label.theme_backgroundColor = "Global.backgroundColor"
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.width, height: label.height))
        
        view.theme_backgroundColor = "Global.backgroundColor"
        view.addSubview(label)
        
        return view
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        
        if section == 0 {
            return false
        }
        if section == 1 {
            return false
        }
        if section == 2 {
            return true
        }
        
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete && indexPath.section == 2 {
            if let customList = customProjectList {
                promptUserToDelete(indexPath, customList)
            }
        }
    }
    
    func promptUserToDelete(_ indexPath:IndexPath, _ customList:[DVListViewModel]) {
        let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
        let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
        let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
        let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        let actioncontroller = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive) { _ in
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            self.handleListDelete(indexPath, customList)
        }
        
        let cancel = UIAlertAction(title: cancelLabel, style: .cancel) { _ in
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            actioncontroller.dismiss(animated: true, completion: nil)
        }
        
        actioncontroller.addAction(delete)
        actioncontroller.addAction(cancel)
        
        present(actioncontroller, animated: true) {
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
        }
    }
    
    func handleListDelete(_ indexPath:IndexPath, _ customList:[DVListViewModel]) {
        let indexPathRow = indexPath.row
        
        let list = customList[indexPathRow]
        
        if store.filteredProjectList?.uuid == list.uuid {
            let defaultProjectLabel = "Inbox"
            let defaultProject = store.findDVList(byLabel: defaultProjectLabel)
            store.filteredProjectList = DVListViewModel.fromCoreData(list: defaultProject)
        }
        
        guard store.destroyList(withUUID: list.uuid) else {
            fatalError("oops could not delete list")
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("ListTableViewController.projectListDeleted"), object: nil)
        
        store.fetchListsViewModel()
        listVM = store.dvListsVM
        
        self.tableView.reloadData()
    }
    
    // MARK: - private
    private func adjustedRow(_ row: Int) -> Int {
        return row - 1
    }
    
    private func clearTextfield(at textField: UITextField) {
        textField.text = String()
    }
    
}

extension ListTableViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if let tagLabel = textField.text, !tagLabel.isEmpty {
//            let listDescription = String()
//            let list = store.createProject(withTitle: tagLabel, withDescription: listDescription)
//
////            store.fetchListsViewModel()
////            listVM = store.dvListsVM
////            editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
////            self.store.editingDVTodotaskItemListPlaceholder = DVListViewModel.copyWithoutListItems(list: list)
//
//            clearTextfield(at: textField)
//        }
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let listLabel = textField.text, !listLabel.isEmpty {
            promptUserToSave(textField)
        }
    }
    
    func promptUserToSave(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text.isEmpty {
            clearTextfield(at: textField)
        }
        
        let savetxt = NSLocalizedString("Save", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Save **", comment: "")
        let saveStr = savetxt + " " + text
        
        let alertctrlr = UIAlertController(title: savetxt, message: saveStr, preferredStyle: .actionSheet)
        
        let save = UIAlertAction(title: savetxt, style: .default) { _ in
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            self.processSave(textField)
        }
        
        let resetStr = NSLocalizedString("Reset", tableName: "Localizable", bundle: .main, value: "** DID NOT Find Reset **", comment: "")
        let rst = UIAlertAction(title: resetStr, style: .destructive) { _ in
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            self.clearTextfield(at: textField)
        }
        
        let cancelStr = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Localizable **", comment: "")
        let cncl = UIAlertAction(title: cancelStr, style: .cancel) { _ in
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertctrlr.addAction(save)
        alertctrlr.addAction(rst)
        alertctrlr.addAction(cncl)
        
        present(alertctrlr, animated: true) {
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
        }
    }
    
    func processSave(_ textField: UITextField) {
        if let listLabel = textField.text, !listLabel.isEmpty {
            let listDescription = String()
            let newlist = store.createProject(withTitle: listLabel, withDescription: listDescription)
            //            store.editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
            
            newListCreated = true
            newCreatedListUUID = newlist.uuid
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("ListTableViewController.projectListCreated"), object: nil)
            
            cookData()
            
            tableView.reloadData()
            
//            if let indexPathToScrollTo = newCreatedIndexpath {
//                tableView.scrollToRow(at: indexPathToScrollTo, at: .top, animated: true)
//                tableView.selectRow(at: indexPathToScrollTo, animated: true, scrollPosition: .top)
//                tableView.deselectRow(at: indexPathToScrollTo, animated: true)
//
//                print("resetting the variables after scrolling")
//                newListCreated = false
//                newCreatedListUUID = nil
//                newCreatedIndexpath = nil
//            }
            
            clearTextfield(at: textField)
        }
    }
    
//    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
}

//extension DVMultipleTodoitemtaskItemsVC : ContextMenuDelegate {
//    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
//        //        super.contextMen
//    }
//
//    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
//        self.tableView.reloadData()
//    }
//
//
//}
