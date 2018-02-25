//
//  DVListTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-28.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

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
        
        tableView.tableFooterView = UIView()
        
        setupNavigationTitleText(title: "Change Project", subtitle: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ThemableBaseTableViewCell.self, forCellReuseIdentifier: "defaultThemableCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
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
        
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (defaultProjectList?.count)!
        } else {
            return (customProjectList?.count)!
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultThemableCell", for: indexPath) as! ThemableBaseTableViewCell
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.theme_tintColor = "Global.barTextColor"
        
        cell.textLabel?.theme_textColor = "Global.textColor"

        // Configure the cell...
        let section = indexPath.section
        
        if section == 0 {
            if let projectList = defaultProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                cell.textLabel?.text = projectList.title
                if projectList.uuid == currentFilteredProjectlist.uuid {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        } else {
            if let projectList = customProjectList?[indexPath.row], let currentFilteredProjectlist = store.filteredProjectList {
                cell.textLabel?.text = projectList.title
                if projectList.uuid == currentFilteredProjectlist.uuid {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
