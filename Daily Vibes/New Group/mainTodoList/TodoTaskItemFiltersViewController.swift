//
//  TodoTaskItemFiltersViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-08.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class TodoTaskItemFiltersViewController: ThemableTableViewController {
    
    let store = CoreDataManager.store
    
    weak var selectedCell: UITableViewCell! {
        didSet {
            switch selectedCell {
            case filterSHOWALLCell:
                store.dvfilter = .all
            case filterSHOWCOMPLETEDONLYCell:
                store.dvfilter = .completed
            case filterSHOWUPCOMINGCell:
                store.dvfilter = .upcoming
            default:
                store.dvfilter = .all
            }
            tableView.reloadData()
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("handleTasksFilterChange-TodoTaskItemFiltersViewController"), object: nil)
        }
    }
    
    @IBOutlet private weak var filterSHOWALLCell: UITableViewCell!
    @IBOutlet private weak var filterSHOWCOMPLETEDONLYCell: UITableViewCell!
    @IBOutlet private weak var filterSHOWUPCOMINGCell: UITableViewCell!
    
    lazy var customSelectedView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    lazy var cancelBtn : UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelBtn))
        
        btn.accessibilityIdentifier = "dvlistitem.filtervc.cancel.btn"
        
        return btn
    }()
    
    @objc
    func handleCancelBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let incomingCellLabel = NSLocalizedString("All", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND All **", comment: "")
        let completedCellLabel = NSLocalizedString("Completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Completed **", comment: "")
        let archivedCellLabel = NSLocalizedString("Upcoming", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Upcoming **", comment: "")
        
        filterSHOWALLCell.textLabel?.text = incomingCellLabel
        filterSHOWALLCell.theme_backgroundColor = "Global.barTintColor"
        filterSHOWALLCell.textLabel?.theme_textColor = "Global.textColor"
        filterSHOWALLCell.selectedBackgroundView = customSelectedView
        
        filterSHOWCOMPLETEDONLYCell.textLabel?.text = completedCellLabel
        filterSHOWCOMPLETEDONLYCell.theme_backgroundColor = "Global.barTintColor"
        filterSHOWCOMPLETEDONLYCell.textLabel?.theme_textColor = "Global.textColor"
        filterSHOWCOMPLETEDONLYCell.selectedBackgroundView = customSelectedView
        
        filterSHOWUPCOMINGCell.textLabel?.text = archivedCellLabel
        filterSHOWUPCOMINGCell.theme_backgroundColor = "Global.barTintColor"
        filterSHOWUPCOMINGCell.textLabel?.theme_textColor = "Global.textColor"
        filterSHOWUPCOMINGCell.selectedBackgroundView = customSelectedView
        
        navigationItem.leftBarButtonItems = [cancelBtn]
        
//        if store.filteredTag == nil {
//            let projectlistFilter = UIBarButtonItem.init(image: #imageLiteral(resourceName: "list_baritem_icon_dailyvibes"), style: .plain, target: self, action: #selector(handleListChange))
            
//            navigationItem.rightBarButtonItem = projectlistFilter
//        }
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
    }
    
//    @objc func handleListChange() {
//        let storyboard = UIStoryboard.init(name: "DVProjectListStoryboard", bundle: nil)
//        let tvc = storyboard.instantiateViewController(withIdentifier: "DVListTableViewController")
//        navigationController?.pushViewController(tvc, animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch store.dvfilter {
        case .all:
            selectedCell = filterSHOWALLCell
        case .completed:
            selectedCell = filterSHOWCOMPLETEDONLYCell
        case .upcoming:
            selectedCell = filterSHOWUPCOMINGCell
        }
        
        let title = NSLocalizedString("Sort by", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sort by **", comment: "")
        setupNavigationTitleText(title: title, subtitle: nil)
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return NSLocalizedString("Sort by", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sort by **", comment: "")
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
//        view.theme_backgroundColor = "Global.backgroundColor"
//        let label = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: self.tableView.frame.size.width, height: 18))
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.theme_textColor = "Global.barTextColor"
//        label.text = self.tableView(tableView, titleForHeaderInSection: section)
//        view.addSubview(label)
//        return view
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.theme_tintColor = "Global.barTextColor"
        
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
        
        // viewFilter = store.dvfilter
        
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
