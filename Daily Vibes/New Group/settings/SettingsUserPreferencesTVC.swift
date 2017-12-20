//
//  ProgressUserPreferencesTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-19.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class SettingsUserPreferencesTVC: UITableViewController {
    
    @IBOutlet private weak var doneAlertCell: UITableViewCell!
    @IBOutlet private weak var doneAlertLabel: UILabel!
    @IBOutlet private weak var doneAlertSwitch: UISwitch!
    @IBOutlet private weak var deleteAlertCell: UITableViewCell!
    @IBOutlet private weak var deleteAlertLabel: UILabel!
    @IBOutlet private weak var deleteAlertSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationLabel = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND User Preferences **", comment: "")
        let alertLabel = NSLocalizedString("Alert", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Alert **", comment: "")
        
        self.navigationItem.title = navigationLabel
        doneAlertLabel?.text = alertLabel
        deleteAlertLabel?.text = alertLabel
        
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDoneAlert")
        let showDeleteAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
        
        doneAlertSwitch.isOn = showDoneAlert
        deleteAlertSwitch.isOn = showDeleteAlert
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        
//        let navigationLabel = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND User Preferences **", comment: "")
//        let alertLabel = NSLocalizedString("Alert", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Alert **", comment: "")
//
//        self.navigationItem.title = navigationLabel
//        doneAlertCell?.textLabel?.text = alertLabel
//        deleteAlertCell?.textLabel?.text = alertLabel

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
                NSLog("Sender is on")
                defaults.set(true, forKey: doneKey)
            } else {
                NSLog("Sender is off")
                defaults.set(false, forKey: doneKey)
            }
            
            defaults.synchronize()
            NSLog("Saved")
        }
    }
    
    
    @IBAction func deleteAlertSwitchAction(_ sender: UISwitch) {
        if sender == deleteAlertSwitch {
//            fatalError("not implemented yet")
            let defaults = UserDefaults.standard
            let deleteKey = "todo.showOnDeleteAlert"
            
            if sender.isOn {
                NSLog("Sender is on")
                defaults.set(true, forKey: deleteKey)
            } else {
                NSLog("Sender is off")
                defaults.set(false, forKey: deleteKey)
            }
            
            defaults.synchronize()
            NSLog("Saved")
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

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
