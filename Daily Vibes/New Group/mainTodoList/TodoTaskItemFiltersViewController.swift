//
//  TodoTaskItemFiltersViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-08.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class TodoTaskItemFiltersViewController: UITableViewController {
    
    weak var delegate:TodoTaskItemFiltersViewControllerDelegate?
    
    var selectedSegment: SegmentOption!
    
    weak var selectedCell: UITableViewCell! {
        didSet {
            switch selectedCell {
            case incomingCell:
                selectedSegment = .inbox
            case completedCell:
                selectedSegment = .done
            case archivedCell:
                selectedSegment = .archived
            default:
                selectedSegment = .inbox
            }
            delegate?.selectedFilterProperties(sender: self)
            tableView.reloadData()
        }
    }
    
    @IBOutlet private weak var incomingCell: UITableViewCell!
    @IBOutlet private weak var completedCell: UITableViewCell!
    @IBOutlet private weak var archivedCell: UITableViewCell!
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        if selectedSegment != nil {
    //            switch selectedSegment! {
    //            case .inbox:
    //                incomingCell.accessoryType = .checkmark
    //            case .done:
    //                completedCell.accessoryType = .checkmark
    //            case .archived:
    //                archivedCell.accessoryType = .checkmark
    //            }
    //        }
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let incomingCellLabel = NSLocalizedString("To-do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND To-do **", comment: "")
        let completedCellLabel = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done **", comment: "")
        let archivedCellLabel = NSLocalizedString("Archived", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Archived **", comment: "")
        
        incomingCell.textLabel?.text = incomingCellLabel
        incomingCell.theme_backgroundColor = "Global.barTintColor"
        incomingCell.textLabel?.theme_textColor = "Global.textColor"
        completedCell.textLabel?.text = completedCellLabel
        completedCell.theme_backgroundColor = "Global.barTintColor"
        completedCell.textLabel?.theme_textColor = "Global.textColor"
        archivedCell.textLabel?.text = archivedCellLabel
        archivedCell.theme_backgroundColor = "Global.barTintColor"
        archivedCell.textLabel?.theme_textColor = "Global.textColor"
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch selectedSegment! {
        case .inbox:
            selectedCell = incomingCell
        case .done:
            selectedCell = completedCell
        case .archived:
            selectedCell = archivedCell
        }
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(tapCancel))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: "tapCancel")
        //        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(TodoTaskItemFiltersViewController.tapCancel))
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell == selectedCell {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { fatalError("this should not fail") }
        self.selectedCell = cell
        self.navigationController?.popViewController(animated: true)
    }
    
//    @objc func tapCancel(_ : UIBarButtonItem) {
//        //tap cancel
//        dismiss(animated: true, completion:nil);
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

protocol TodoTaskItemFiltersViewControllerDelegate: class {
    func selectedFilterProperties(sender: TodoTaskItemFiltersViewController)
}
