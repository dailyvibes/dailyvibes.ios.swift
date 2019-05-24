//
//  DVLNTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-05-21.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import SwiftTheme
import UIKit
import UserNotifications

class DVLNTableViewController: ThemableTableViewController, UNUserNotificationCenterDelegate {
    
    var isGrantedNotificationAccess: Bool = false
    var requestData: [UNNotificationRequest]?
    
    lazy var customSelectionView: UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        
        cancelButton.accessibilityIdentifier = "dvln_cancel_btn"
        self.navigationItem.leftBarButtonItem = cancelButton
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
                if !granted{
                    //add alert to complain
                }
        })
        
//        self.title = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notifications String **", comment: "")
        let vctitle = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notifications String **", comment: "")
        setupVCTwoLineTitle(withTitle: vctitle, withSubtitle: nil)
        UNUserNotificationCenter.current().delegate = self
        
        navigationController?.navigationBar.isTranslucent = false
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
//        tableView.tableFooterView = UIView.init(coder: .init())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests -> () in
            //            print("\(requests.count) requests -------")
            
            for request in requests {
                if self.requestData == nil {
                    self.requestData = [UNNotificationRequest]()
                }
                
                guard var _requestData = self.requestData else {
                    return;
                }
                
                _requestData.append(request)
                self.requestData = _requestData
                //                print(request.identifier)
            }
            //            print(self.requestData)
        })
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
        
        //        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifications -> () in
        //            print("\(deliveredNotifications.count) Delivered notifications-------")
        //            for notification in deliveredNotifications{
        //                print(notification.request.identifier)
        //            }
        //        })
    }
    
    @objc func handleCancelButton() {
        closeView()
    }
    
    fileprivate func closeView() {
        let isPresentingInADDMode = presentingViewController is DailyVibesTabBarViewController
        
        if isPresentingInADDMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("DVLNTableViewController is not inside a navigation controller.")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _requestData = requestData else { return 0 }
        return _requestData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicNotificationCell", for: indexPath)
        
        cell.theme_backgroundColor = "Global.barTintColor"
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        cell.selectedBackgroundView = customSelectionView
        
        if let _requestData = requestData {
            let cellData = _requestData[indexPath.row]
            
            cell.textLabel?.text = "\(cellData.content.title): \(cellData.content.body)"
            cell.detailTextLabel?.text = cellData.content.categoryIdentifier
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deleteNotificationID = self.requestData?.remove(at: indexPath.row) {
                let toDelete = deleteNotificationID.identifier
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [toDelete])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
