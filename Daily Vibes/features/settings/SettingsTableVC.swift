//
//  SettingsTableVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-10.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme
import Disk
import MessageUI

class SettingsTableVC: ThemableTableViewController {
    
    private let store = CoreDataManager.store
    
    // MARK: Properties
    @IBOutlet private weak var madeInTorontoLabel: UILabel!
    @IBOutlet private weak var userPreferencesCell: UITableViewCell!
    @IBOutlet private weak var aboutCell: UITableViewCell!
    @IBOutlet private weak var supportCell: UITableViewCell!
    @IBOutlet private weak var acknowledgementCell: UITableViewCell!
    @IBOutlet private weak var madeInTorontoCell: UITableViewCell!
    @IBOutlet private weak var themesCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userPreferencesCell.textLabel?.text = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Preferences **", comment: "")
        themesCell.textLabel?.text = NSLocalizedString("Themes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Themes **", comment: "")
        aboutCell.textLabel?.text = NSLocalizedString("About", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND About **", comment: "")
        supportCell.textLabel?.text = NSLocalizedString("Support", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Support **", comment: "")
        acknowledgementCell.textLabel?.text = NSLocalizedString("Acknowledgement", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Acknowledgement **", comment: "")
        madeInTorontoLabel.text = NSLocalizedString("Made in Toronto", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Made in Toronto **", comment: "")
        madeInTorontoCell.selectionStyle = UITableViewCellSelectionStyle.none
        
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
        setupNavigationTitleText(title: titleString, subtitle: nil)
        
        let starButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "starFilled_icon_daily_vibes"), style: .plain, target: self, action: #selector(handleRateButton))
        starButton.accessibilityIdentifier = "settings_rate_us_btn"
        navigationItem.leftBarButtonItem = starButton
        
//        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleExport))
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleExport(sender:)))
        shareButton.accessibilityIdentifier = "settings_export_btn"
        navigationItem.rightBarButtonItem = shareButton
    }
    
    fileprivate func handleExportToText() {
        let all = store.getTodoItemTasks(ascending: false)
        let result = all?.map({ (todoItem) -> String in
            return todoItem.encodedString()
        })
        
        let string = result?.joined(separator: "\n") ?? ""
//        let stringData = string.data(using: .utf8)
        
//        print(string)
        
        let activityVC = UIActivityViewController.init(activityItems: [string], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = self.view
        }
//        let result = all?.map { todoItem in
//
//            var resultString = ""
//
//
//            return todoItem.isCompleted == true
//        }
    }
    
    fileprivate func handleExportToEmail() {
            let allData = store.getTodoItemTasks(ascending: false)
            let allDataEncoded = allData?.map({ (todoItem) -> String in
                return todoItem.encodedString()
            })
            let allDataToString = allDataEncoded?.joined(separator: "\n") ?? ""
            let allDataAsData = allDataToString.data(using: .utf8)
            let timeNowString = Date().timeIntervalSince1970
            let fileName = "dailyvibes-iOS-backup-\(timeNowString).txt"
        
//            try Disk.save(allDataAsData, to: .temporary, as: fileName)
//            let fileUrl = try Disk.getURL(for: fileName, in: .temporary)
        
//        https://d.pr/AGgech
//        https://d.pr/b3Bu0o
        
            if MFMailComposeViewController.canSendMail() {
                let email = MFMailComposeViewController()
                let dateFormatter = DateFormatter()
                let dateNow = Date.init(timeIntervalSince1970: timeNowString)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                email.mailComposeDelegate = self
                email.setSubject("DailyVibes Export - \(dateFormatter.string(from: dateNow))")
                let message = """
                Data Export from Daily Vibes \n
                Please see attached file for easy access.
                """
                email.setMessageBody(message, isHTML: true)
                
                if let hasallDataAsData = allDataAsData {
                    email.addAttachmentData(hasallDataAsData, mimeType: "text/txt", fileName: fileName)
                }
                self.present(email, animated: true, completion: nil)
            }
    }
    
    fileprivate func handleExportToDisk() {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            jsonEncoder.dateEncodingStrategy = .iso8601
            let jsonData = try jsonEncoder.encode(store.filteredDvTodoItemTaskData)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            if let convertedStr = jsonString {
                print(convertedStr)
            }
            //            func getCompletedTodoItemTasks(ascending: Bool = false) -> [DVTodoItemTaskViewModel]? {
            //                let all = getTodoItemTasks(ascending: ascending)
            //                let result = all?.filter { todoItem in
            //                    return todoItem.isCompleted == true
            //                }
            //                return result
            //            }
            //            let allData = store.getTodoItemTasks(ascending: false)
            //            let jsonData = try jsonEncoder.encode(allData)
            //            let jsonString = String(data: jsonData, encoding: .utf8)
            //            if let convertedStr = jsonString {
            //                print(convertedStr)
            //            }
            
            // increment backup number
            
//            do {
//                let timeNow = Date()
//                let timeNowString = timeNow.timeIntervalSince1970
//                let fileName = "Archives/dv-archive-\(timeNowString).json"
//                try Disk.save(jsonData, to: .documents, as: fileName)
//            } catch let error as NSError {
//                fatalError("""
//                    Domain: \(error.domain)
//                    Code: \(error.code)
//                    Description: \(error.localizedDescription)
//                    Failure Reason: \(error.localizedFailureReason ?? "")
//                    Suggestions: \(error.localizedRecoverySuggestion ?? "")
//                    """)
//            }
        } catch {
            fatalError("handleExport failed")
        }
    }
    
    @objc func handleExport(sender:UIBarButtonItem) {
        let exportTextTitle = NSLocalizedString("Export", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Export **", comment: "")
        let exportTitleText = NSLocalizedString("How would you like to export your data?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND How would you like to export your data? **", comment: "")
        let actionController = UIAlertController.init(title: exportTextTitle, message: exportTitleText, preferredStyle: .actionSheet)
        let exportToTextText = NSLocalizedString("Export to Text", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Export to Text **", comment: "")
        let exportToText = UIAlertAction.init(title: exportToTextText, style: .default) { (_) in
            self.handleExportToText()
        }
        let exportToEmailText = NSLocalizedString("Export to Email", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Export to Email **", comment: "")
        let exportToEmail = UIAlertAction.init(title: exportToEmailText, style: .default) { (_) in
            self.handleExportToEmail()
        }
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel **", comment: "")
        let cancelAction = UIAlertAction.init(title: cancelString, style: .cancel, handler: nil)
        
        let exportToJson = UIAlertAction.init(title: "Export to JSON", style: .default) { (_) in
            self.handleExportToDisk()
        }
        
        actionController.addAction(cancelAction)
        actionController.addAction(exportToText)
        actionController.addAction(exportToEmail)
        actionController.addAction(exportToJson)
        
        if let popOver = actionController.popoverPresentationController {
//            popOver.sourceView = self.view
//            popOver.sourceRect = navigationItem.rightBarButtonItems["settings_export_btn"]
            popOver.barButtonItem = sender
        }
        
        present(actionController, animated: true, completion: nil)
    }
    
    @objc func handleRateButton() {
        let appstoreLink = "itms-apps://itunes.apple.com/app/id1332324033?action=write-review"
        if let url = URL.init(string: appstoreLink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension SettingsTableVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
