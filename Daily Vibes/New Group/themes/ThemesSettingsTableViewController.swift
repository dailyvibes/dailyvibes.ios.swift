//
//  ThemesSettingsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-06.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class ThemesSettingsTableViewController: ThemableTableViewController {
    
    private let themes = [
        NSLocalizedString("Default", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Default", comment: ""),
        NSLocalizedString("Night Blue", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Default", comment: ""),
        NSLocalizedString("Night", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Default", comment: ""),
        NSLocalizedString("Orange", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Default", comment: "")
    ]
    
    private var selectedEnumTheme = MyThemes.current {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var customSelectedView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    private weak var selectedTheme: ThemableBaseTableViewCell?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleString = "Themes"
        setupNavigationTitleText(title: titleString, subtitle: nil)
        
        syncThemePreferences()
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
    }
    
    fileprivate func syncThemePreferences() {
        selectedEnumTheme = MyThemes(rawValue: UserDefaults.standard.integer(forKey: "themeSelected"))!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ThemableBaseTableViewCell.self, forCellReuseIdentifier: "DefaultCell")

//        tableView.tableFooterView = UIView.init(coder: .init())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell") as! ThemableBaseTableViewCell
        let currentCellTheme = MyThemes.init(rawValue: indexPath.row)
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
        
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.textLabel?.text = themes[indexPath.row]
        cell.selectedBackgroundView = customSelectedView
        
        if currentCellTheme == selectedEnumTheme {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedEnumTheme = MyThemes.init(rawValue: indexPath.row)!
    
            let defaults = UserDefaults.standard
            
            switch selectedEnumTheme {
            case .DVDefault:
                defaults.set(MyThemes.DVDefault.rawValue, forKey: "themeSelected")
                MyThemes.switchTo(.DVDefault)
            case .night:
                defaults.set(MyThemes.night.rawValue, forKey: "themeSelected")
                MyThemes.switchTo(.night)
            case .nightBlue:
                defaults.set(MyThemes.nightBlue.rawValue, forKey: "themeSelected")
                MyThemes.switchTo(.nightBlue)
            case .lightOrange:
                defaults.set(MyThemes.lightOrange.rawValue, forKey: "themeSelected")
                MyThemes.switchTo(.lightOrange)
            }
        }
    
}
