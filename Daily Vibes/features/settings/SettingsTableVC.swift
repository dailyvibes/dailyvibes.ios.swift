//
//  SettingsTableVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-10.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {
    
    // MARK: Properties
    @IBOutlet private weak var madeInTorontoLabel: UILabel!
    @IBOutlet private weak var aboutCell: UITableViewCell!
    @IBOutlet private weak var supportCell: UITableViewCell!
    @IBOutlet private weak var acknowledgementCell: UITableViewCell!
    @IBOutlet private weak var languageCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        aboutCell.textLabel?.text = NSLocalizedString("About", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND About **", comment: "")
        supportCell.textLabel?.text = NSLocalizedString("Support", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Support **", comment: "")
        acknowledgementCell.textLabel?.text = NSLocalizedString("Acknowledgement", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Acknowledgement **", comment: "")
        languageCell.textLabel?.text = NSLocalizedString("Language", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Language **", comment: "")
        languageCell.detailTextLabel?.text = NSLocalizedString("English", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND English **", comment: "")
        madeInTorontoLabel.text = NSLocalizedString("Made in Toronto", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Made in Toronto **", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Settings", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Settings **", comment: "")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
