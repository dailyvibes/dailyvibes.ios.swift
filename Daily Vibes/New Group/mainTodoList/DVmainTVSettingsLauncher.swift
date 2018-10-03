//
//  DVmainTVSettingsLauncher.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-28.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class SettingsData: NSObject {
    var isProject: Bool?
    var label: String?
    var sectionFilterStatus: DVSectionVMStatus?
    
    init(isProject: Bool, label: String, sectionFilterStatus: DVSectionVMStatus?) {
        self.isProject = isProject
        self.label = label
        self.sectionFilterStatus = sectionFilterStatus
    }
}

class DVmainTVSettingsLauncher: NSObject {
    
    let store = CoreDataManager.store
    
    let blackView = UIView.init(frame: .zero)
    private var myArray = [[SettingsData]]()
    
    private var myTableView: UITableView = {
        let style = UITableViewStyle.plain
        let tv = UITableView.init(frame: .zero, style: style)
        return tv
    }()
    
    func showDVmainTVSettings() {
        
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            if store.filteredTag == nil {
                myArray = [
                    [
                        SettingsData.init(isProject: false, label: NSLocalizedString("All", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND All **", comment: ""), sectionFilterStatus: DVSectionVMStatus.all),
                        SettingsData.init(isProject: false, label: NSLocalizedString("Completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Completed **", comment: ""), sectionFilterStatus: DVSectionVMStatus.completed),
                        SettingsData.init(isProject: false, label: NSLocalizedString("Upcoming", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Upcoming **", comment: ""), sectionFilterStatus: DVSectionVMStatus.completed)
                ],
                    [SettingsData.init(isProject: true, label: (store.filteredProjectList?.title!)!, sectionFilterStatus: nil)]
            ]
            } else {
                myArray = [
                    [
                        SettingsData.init(isProject: false, label: NSLocalizedString("All", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND All **", comment: ""), sectionFilterStatus: DVSectionVMStatus.all),
                        SettingsData.init(isProject: false, label: NSLocalizedString("Completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Completed **", comment: ""), sectionFilterStatus: DVSectionVMStatus.completed),
                        SettingsData.init(isProject: false, label: NSLocalizedString("Upcoming", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Upcoming **", comment: ""), sectionFilterStatus: DVSectionVMStatus.completed)
                    ]
                ]
            }
            
            window.addSubview(blackView)
            window.addSubview(myTableView)
            
            let height: CGFloat = myTableView.contentSize.height
            let y = window.frame.height - height
            
            myTableView.frame = CGRect.init(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleDVmainTVSettingsDismiss)))
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: [.curveEaseInOut],
                           animations: {
                            self.blackView.alpha = 1.0
                            self.myTableView.frame = CGRect.init(x: 0, y: y, width: self.myTableView.frame.width, height: self.myTableView.frame.height)
            },
                           completion: nil)
        }
    }
    
    @objc func handleDVmainTVSettingsDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.myTableView.frame = CGRect.init(x: 0, y: window.frame.height, width: self.myTableView.frame.width, height: self.myTableView.frame.height)
            }
        }
    }
    
    let cellId = "cellId"
    
    override init() {
        super.init()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
}

extension DVmainTVSettingsLauncher: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 18))
        view.theme_backgroundColor = "Global.backgroundColor"
        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.myTableView.frame.size.width, height: 18))
        label.font = UIFont.systemFont(ofSize: 14)
        label.theme_textColor = "Global.barTextColor"
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Sort by"
        } else {
            return "Project"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let section = myArray[indexPath.section]
        let sectionCellContent = section[indexPath.row]
        
        if let isProject = sectionCellContent.isProject, isProject {
            
        } else {
            if sectionCellContent.sectionFilterStatus == store.dvfilter {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(filterCellTapped(sender:))))
        }
        
        cell.textLabel!.text = sectionCellContent.label
        
        return cell
    }
    
    @objc private func filterCellTapped(sender: UITapGestureRecognizer) {
        let touch = sender.location(in: myTableView)
        if let indexPath = myTableView.indexPathForRow(at: touch) {
            let section = myArray[indexPath.section]
            let newFilter = section[indexPath.row]
            store.dvfilter = newFilter.sectionFilterStatus!
            myTableView.reloadData()
            handleDVmainTVSettingsDismiss()
        }
    }
}
