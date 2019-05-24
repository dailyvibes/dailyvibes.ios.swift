//
//  DVListTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-28.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import ContextMenu
import SwiftEntryKit

class DVListTableViewController: ThemableTableViewController {
    
    let store = CoreDataManager.store
    var currentProjectlist: DVListViewModel?
    var allProjectList: [DVListViewModel]?
    var defaultProjectList: [DVListViewModel]?
    var customProjectList: [DVListViewModel]?
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        store.fetchListsViewModel()
        
        currentProjectlist = store.filteredProjectList
        allProjectList = store.dvListsVM
        
        defaultProjectList = allProjectList?.filter({ (listVM) -> Bool in
            return listVM.isDVDefault == true
        })
        
        customProjectList = allProjectList?.filter({ (listVM) -> Bool in
            return listVM.isDVDefault == false
        })
        
        tableView.tableFooterView = UIView.init(frame: .init())
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let _text = "Change Project"
        let customNavigationTitle = NSLocalizedString(_text, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText \(_text) **", comment: "")
        navigationItem.title = customNavigationTitle
        
//        let addNewList = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButon))
//        let addNewList = UIBarButtonItem(title: "Add Project", style: .plain, target: self, action: nil)
        
//        navigationItem.rightBarButtonItems = [addNewList]
        
        tableView.register(ThemableBaseTableViewCell.self, forCellReuseIdentifier: "defaultThemableCell")
    }
    
    @objc func handleAddButon() {
//        let screenRect = UIScreen.main.bounds
//        let screenWidth = screenRect.size.width
//        let screenHeight = screenRect.size.height
        
        showInput()
        
//        var attributes = EKAttributes.topFloat
//        attributes.entryBackground = .gradient(gradient: .init(colors: [.red, .green], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
//        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.statusBar = .dark
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: screenWidth), height: .intrinsic)
//
//        let title = EKProperty.LabelContent(text: "Add Project", style: .init(font: .boldSystemFont(ofSize: 17), color: .darkText))
//        let description = EKProperty.LabelContent(text: "ex: Secret Project 001", style: .init(font: .systemFont(ofSize: 15), color: .darkGray))
//        let image = EKProperty.ImageContent(image: #imageLiteral(resourceName: "dvNewIcon"), size: CGSize(width: 35, height: 35))
//        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
//        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
//
//        let contentView = EKNotificationMessageView(with: notificationMessage)
//        SwiftEntryKit.display(entry: contentView, using: attributes)
        
//        showSignupForm(attributes: &attributes, style: .dark)
    }
    
    struct PresetDescription {
        let title: String
        let description: String
        let thumb: String
        let attributes: EKAttributes
        
        init(with attributes: EKAttributes, title: String, description: String = "", thumb: String) {
            self.attributes = attributes
            self.title = title
            self.description = description
            self.thumb = thumb
        }
    }
    
    private func showInput() {
        
        let style: FormStyle = .dark
        var attributes: EKAttributes
        var description: PresetDescription
        var descriptionString: String
        var descriptionThumb: String
        
        attributes = .toast
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
        
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        
        attributes.entryBackground = .gradient(gradient: .init(colors: [EKColor.Netflix.light, EKColor.Netflix.dark], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
        attributes.screenBackground = .color(color: .dimmedDarkBackground)
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.statusBar = .light
        
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 0, screenEdgeResistance: 0))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        descriptionString = "Add new project or list and group similar tasks together."
//        descriptionThumb = ThumbDesc.bottomPopup.rawValue
//        descriptionThumb = "ic_bottom_popup"
//        description = .init(with: attributes, title: "Add new project or list", description: descriptionString, thumb: descriptionThumb)
        
//        let style = EKProperty.LabelStyle(font: MainFont.light.with(size: 14), color: .white, alignment: .center)
        
        let title = EKProperty.LabelContent(text: "Add new project or list", style: style.title)
//        let textFields = FormFieldPresetFactory.fields(by: [.fullName, .mobile, .email, .password], style: style)
        let textFields = FormFieldPresetFactory.fields(by: [.projectList], style: style)
        let button = EKProperty.ButtonContent(label: .init(text: "Add", style: style.buttonTitle), backgroundColor: style.buttonBackground, highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8)) {
            SwiftEntryKit.dismiss()
        }
        
        let contentView = EKFormMessageView(with: title, textFieldsContent: textFields, buttonContent: button)
        attributes.lifecycleEvents.didAppear = {
            contentView.becomeFirstResponder(with: 0)
        }
        
        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let _customPL = customProjectList, _customPL.count > 0 {
            // default project list and custom project list
            return 2
        } else {
            // just the default projects list
            return 1
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { fatalError("this should not fail") }
//        self.selectedCell = cell
        let section = indexPath.section
        let sectionRow = indexPath.row
        
        if section == 0 {
            if let defaultProjectlist = defaultProjectList {
                let newProjectlist = defaultProjectlist[sectionRow]
                store.filteredProjectList = store.findListVM(withUUID: newProjectlist.uuid)
            }
        } else {
            if let defaultProjectlist = customProjectList {
                let newProjectlist = defaultProjectlist[sectionRow]
                store.filteredProjectList = store.findListVM(withUUID: newProjectlist.uuid)
            }
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("handleListChange-DVListTableViewController"), object: nil)

        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if let _defaultPL = defaultProjectList {
                return _defaultPL.count
            }
        } else {
            if let _customPL = customProjectList {
                return _customPL.count
            }
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultThemableCell", for: indexPath) as! ThemableBaseTableViewCell
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "defaultListTVCCell")
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
        
        cell.textLabel?.theme_textColor = "Global.textColor"

        // Configure the cell...
        let section = indexPath.section
        
        if section == 0 {
            if let projectList = defaultProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                cell.textLabel?.text = projectList.title
//                if let _items = projectList.listItems {
//                    let _count = _items.count
////                    Log("count: \(_count) \t \(projectList.title)")
//                    cell.detailTextLabel?.text = "\(_count)"
//                }
                if projectList.uuid == currentFilteredProjectlist.uuid {
                    cell.accessoryType = .checkmark
                } else {
//                    cell.accessoryType = .none
                    cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                }
            }
        } else {
            if let projectList = customProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                cell.textLabel?.text = projectList.title
//                if let _items = projectList.listItems {
//                    let _count = _items.count
//                    cell.detailTextLabel?.text = "\(_count)"
//                }
                if projectList.uuid == currentFilteredProjectlist.uuid {
                    cell.accessoryType = .checkmark
                } else {
//                    cell.accessoryType = .none
                    cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                }
            }
        }

        return cell
    }
}

extension UIScreen {
    var minEdge: CGFloat {
        return UIScreen.main.bounds.minEdge
    }
}

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
