//
//  TagsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-20.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

struct TagCreator {
    private var location = IndexPath(row: 0, section:0)
    
    func isLocated(at indexPath: IndexPath?) -> Bool {
        if indexPath!.row == location.row && indexPath!.section == location.section {
            return true
        } else {
            return false
        }
    }
}

class TagsTableViewController: ThemableTableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    private var tagCreator = TagCreator()
    
//    private var todoItemSettingsData: TodoItemSettingsData?
    private var store = CoreDataManager.store
    private var editingTodotaskItem: DVTodoItemTaskViewModel? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var tagsVM = [DVTagViewModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var addingNewCell: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleString = "Tags"
        setupNavigationTitleText(title: titleString, subtitle: nil)
        
        store.fetchTagsViewModel()
        tagsVM = store.dvTagsVM
        editingTodotaskItem = store.editingDVTodotaskItem
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.editingDVTodotaskItem = editingTodotaskItem
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsVM.count + 1;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let displayCell = "tagsDisplayCell"
        let createCell = "tagsCreateCell"
        
        if tagCreator.isLocated(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: createCell, for: indexPath) as! TagsCreationTableViewCell
            cell.tagLabeler.delegate = self
            return cell
        } else {
            // display
            let cell = tableView.dequeueReusableCell(withIdentifier: displayCell, for: indexPath)
            // we need adjustedIndexPath b/c our initial row is set to input row
            // so we just need to adjust for the row that we are getting
            // and we are only having 1 section for the forseable future
            let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: indexPath.section)
            
            let tag = tagsVM[adjustedIndexPath.row]
            
            cell.imageView?.image = #imageLiteral(resourceName: "tagsFilledinCircle")
            cell.textLabel?.text = tag.label
            
            if let existingTags = editingTodotaskItem?.tags, existingTags.count > 0 {
                if let hasTag = editingTodotaskItem?.tagsContains(tag: tag), hasTag {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            } else {
                cell.accessoryType = .none
            }
            
            cell.theme_backgroundColor = "Global.barTintColor"
            cell.textLabel?.theme_textColor = "Global.textColor"
            cell.theme_tintColor = "Global.barTextColor"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // removed this because we would need to adjust the indexPath
        // and coredata should be doing this update via calling cellForRowAt after the save
        let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: 0)
        
        if !tagCreator.isLocated(at: indexPath) {
            let tag = tagsVM[adjustedIndexPath.row]
            
            if let hasTag = editingTodotaskItem?.tagsContains(tag: tag), hasTag {
                if let existingTags = editingTodotaskItem?.tags {
                    // remove tag
                    editingTodotaskItem?.tags = existingTags.filter {_tag in _tag.uuid != tag.uuid }
//                    self.tableView.reloadData()
                } else {
                    editingTodotaskItem?.tags?.append(DVTagViewModel.copyWithoutTagged(tag: tag))
//                    self.tableView.reloadData()
                }
            } else {
                editingTodotaskItem?.tags?.append(DVTagViewModel.copyWithoutTagged(tag: tag))
//                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if tagCreator.isLocated(at: indexPath) {
            return false
        }
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let adjustedIndexPath = IndexPath.init(row: adjustedRow(indexPath.row), section: indexPath.section)
            let removableTag = tagsVM[adjustedIndexPath.row]
            if let hasTag = editingTodotaskItem?.tagsContains(tag: removableTag), hasTag {
                if let existingTags = editingTodotaskItem?.tags {
                    editingTodotaskItem?.tags = existingTags.filter {_tag in _tag.uuid != removableTag.uuid }
                }
            }
            guard store.destroyTag(withUUID: removableTag.uuid) else { fatalError("failed at destroying a tag") }
            store.fetchTagsViewModel()
            tagsVM = store.dvTagsVM
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tagLabel = textField.text, !tagLabel.isEmpty {
            let tag = store.createTag(withLabel: tagLabel)
            
            if let hasTag = editingTodotaskItem?.tagsContains(tag: tag), hasTag {
                if let existingTags = editingTodotaskItem?.tags {
                    editingTodotaskItem?.tags = existingTags.filter {_tag in _tag.uuid != tag.uuid }
                }
            } else {
                editingTodotaskItem?.tags?.append(DVTagViewModel.copyWithoutTagged(tag: tag))
            }
            
            store.fetchTagsViewModel()
            tagsVM = store.dvTagsVM
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
