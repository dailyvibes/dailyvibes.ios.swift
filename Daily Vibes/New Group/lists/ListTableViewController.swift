//
//  ListTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-12.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

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

class ListTableViewController: ThemableTableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private var listCreator = ListCreator()
    
    private let store = CoreDataManager.store
    private var editingTodotaskItem: DVTodoItemTaskViewModel? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var listVM = [DVListViewModel]() {
        didSet {
            defaultProjectList = listVM.filter({ (listVM) -> Bool in
                return listVM.isDVDefault == true
            })
            
            customProjectList = listVM.filter({ (listVM) -> Bool in
                return listVM.isDVDefault == false
            })
            
            self.tableView.reloadData()
        }
    }
    
    var defaultProjectList: [DVListViewModel]?
    var customProjectList: [DVListViewModel]?
    
    // flip to ensure that the cell at position 0 in cellForRowAt is only used once
    private var addingNewCell: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleString = "Change Project"
        setupNavigationTitleText(title: titleString, subtitle: nil)
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        store.fetchListsViewModel()
        listVM = store.dvListsVM
        editingTodotaskItem = store.editingDVTodotaskItem
        
        defaultProjectList = listVM.filter({ (listVM) -> Bool in
            return listVM.isDVDefault == true
        })
        
        customProjectList = listVM.filter({ (listVM) -> Bool in
            return listVM.isDVDefault == false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
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
    
    
    // we need adjustedIndexPath b/c our initial row is set to input row
    // so we just need to adjust for the row that we are getting
    // and we are only having 1 section for the forseable future
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let displayCell = "listsDisplayCell"
        let createCell = "listCreateCell"
        
        let section = indexPath.section
        let indexPathRow = indexPath.row
        
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: createCell, for: indexPath) as! ListCreationTableViewCell
            cell.listLabeler.delegate = self
            return cell
        }
        
        if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
            
            if let _defaultProjectList = defaultProjectList {
                
                let list = _defaultProjectList[indexPathRow]
                
                cell.textLabel?.text = list.title
                cell.detailTextLabel?.text = ""
                
                if let existingList = editingTodotaskItem?.list {
                    if list.uuid == existingList.uuid {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    cell.accessoryType = .none
                }
                
                cell.theme_backgroundColor = "Global.barTintColor"
                cell.textLabel?.theme_textColor = "Global.textColor"
                cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
                cell.theme_tintColor = "Global.barTextColor"
                return cell
            }
        }
        
        if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
            
            if let _defaultProjectList = customProjectList {
                
                let list = _defaultProjectList[indexPathRow]
                
                cell.textLabel?.text = list.title
                cell.detailTextLabel?.text = ""
                
                if let existingList = editingTodotaskItem?.list {
                    if list.uuid == existingList.uuid {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    cell.accessoryType = .none
                }
                
                cell.theme_backgroundColor = "Global.barTintColor"
                cell.textLabel?.theme_textColor = "Global.textColor"
                cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
                cell.theme_tintColor = "Global.barTextColor"
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let indexPathRow = indexPath.row
        
        if section == 1 {
            if let defaultList = defaultProjectList {
                let list = defaultList[indexPathRow]
                
                if let existingList = editingTodotaskItem?.list {
                    
                    if list.uuid != existingList.uuid {
                        editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
                    }
                } else {
                    editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        if section == 2 {
            if let defaultList = customProjectList {
                let list = defaultList[indexPathRow]
                
                if let existingList = editingTodotaskItem?.list {
                    
                    if list.uuid != existingList.uuid {
                        editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
                    }
                } else {
                    editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let indexPathRow = indexPath.row
        
        if editingStyle == .delete && section == 2 {
            if let customList = customProjectList {
                let list = customList[indexPathRow]
                
                if store.filteredProjectList?.uuid == list.uuid {
                    let defaultProjectLabel = "Inbox"
                    let defaultProject = store.findDVList(byLabel: defaultProjectLabel)
                    store.filteredProjectList = DVListViewModel.fromCoreData(list: defaultProject)
                }
                
                guard store.destroyList(withUUID: list.uuid) else { fatalError("oops could not delete list") }
                
                if let existingList = editingTodotaskItem?.list {
                    if list.uuid == existingList.uuid {
                        editingTodotaskItem?.list = nil
                        self.tableView.reloadData()
                    }
                }
                
                store.fetchListsViewModel()
                listVM = store.dvListsVM
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tagLabel = textField.text, !tagLabel.isEmpty {
            let listDescription = String()
            let list = store.createProject(withTitle: tagLabel, withDescription: listDescription)
            
            store.fetchListsViewModel()
            listVM = store.dvListsVM
            editingTodotaskItem?.list = DVListViewModel.copyWithoutListItems(list: list)
            
            clearTextfield(at: textField)
        }
    }
    
    // MARK: - private
    private func adjustedRow(_ row: Int) -> Int {
        return row - 1
    }
    
    private func clearTextfield(at textField: UITextField) {
        textField.text = String()
    }
    
}

