//
//  SettingsTableVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-10.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class SettingsTableVC: ThemableTableViewController {
    
    // MARK: Properties
    @IBOutlet private weak var madeInTorontoLabel: UILabel!
    @IBOutlet private weak var userPreferencesCell: UITableViewCell!
    @IBOutlet private weak var aboutCell: UITableViewCell!
    @IBOutlet private weak var supportCell: UITableViewCell!
    @IBOutlet private weak var acknowledgementCell: UITableViewCell!
//         @IBOutlet private weak var languageCell: UITableViewCell!
    @IBOutlet private weak var themesCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userPreferencesCell.textLabel?.text = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Preferences **", comment: "")
        themesCell.textLabel?.text = NSLocalizedString("Themes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Themes **", comment: "")
        aboutCell.textLabel?.text = NSLocalizedString("About", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND About **", comment: "")
        supportCell.textLabel?.text = NSLocalizedString("Support", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Support **", comment: "")
        acknowledgementCell.textLabel?.text = NSLocalizedString("Acknowledgement", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Acknowledgement **", comment: "")
        madeInTorontoLabel.text = NSLocalizedString("Made in Toronto", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Made in Toronto **", comment: "")
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        userPreferencesCell.theme_backgroundColor = "Global.barTintColor"
        userPreferencesCell.textLabel?.theme_textColor = "Global.textColor"
        themesCell.theme_backgroundColor = "Global.barTintColor"
        themesCell.textLabel?.theme_textColor = "Global.textColor"
        aboutCell.theme_backgroundColor = "Global.barTintColor"
        aboutCell.textLabel?.theme_textColor = "Global.textColor"
        supportCell.theme_backgroundColor = "Global.barTintColor"
        supportCell.textLabel?.theme_textColor = "Global.textColor"
        acknowledgementCell.theme_backgroundColor = "Global.barTintColor"
        acknowledgementCell.textLabel?.theme_textColor = "Global.textColor"
        
        madeInTorontoLabel.theme_textColor = "Global.textColor"
        
        let titleString = "Settings"
        setupNavigationTitleText(title: titleString)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
