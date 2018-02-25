//
//  ProgressUserPreferencesTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-19.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class SettingsUserPreferencesTVC: ThemableTableViewController {
    
    @IBOutlet private weak var doneAlertCell: UITableViewCell!
    @IBOutlet private weak var doneAlertLabel: UILabel!
    @IBOutlet private weak var doneAlertSwitch: UISwitch!
    @IBOutlet private weak var deleteAlertCell: UITableViewCell!
    @IBOutlet private weak var deleteAlertLabel: UILabel!
    @IBOutlet private weak var deleteAlertSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationLabel = "Notifications"
        let alertLabel = NSLocalizedString("Alert", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Alert **", comment: "")
        
        setupNavigationTitleText(title: navigationLabel, subtitle: nil)
        
        doneAlertLabel?.text = alertLabel
        deleteAlertLabel?.text = alertLabel
        
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
        let showDeleteAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        doneAlertCell.theme_backgroundColor = "Global.barTintColor"
        doneAlertLabel.theme_textColor = "Global.textColor"
        doneAlertSwitch.theme_onTintColor = "Global.barTextColor"
        deleteAlertCell.theme_backgroundColor = "Global.barTintColor"
        deleteAlertLabel.theme_textColor = "Global.textColor"
        deleteAlertSwitch.theme_onTintColor = "Global.barTextColor"
        
        doneAlertSwitch.isOn = showDoneAlert
        deleteAlertSwitch.isOn = showDeleteAlert
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView.init()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneAlertSwitchAction(_ sender: UISwitch) {
        if sender == doneAlertSwitch {
            let defaults = UserDefaults.standard
            let doneKey = "todo.showOnDoneAlert"
            
            if sender.isOn {
                defaults.set(true, forKey: doneKey)
            } else {
                defaults.set(false, forKey: doneKey)
            }
            
            defaults.synchronize()
        }
    }
    
    
    @IBAction func deleteAlertSwitchAction(_ sender: UISwitch) {
        if sender == deleteAlertSwitch {
            let defaults = UserDefaults.standard
            let deleteKey = "todo.showOnDeleteAlert"
            
            if sender.isOn {
                defaults.set(true, forKey: deleteKey)
            } else {
                defaults.set(false, forKey: deleteKey)
            }
            
            defaults.synchronize()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            let doneSectionLabel = NSLocalizedString("Done Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done Notifications **", comment: "")
            return doneSectionLabel
        case 1:
            let deleteSectionLabel = NSLocalizedString("Delete Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete Notifications", comment: "")
            return deleteSectionLabel
        default:
            return String()
        }
    }

}
