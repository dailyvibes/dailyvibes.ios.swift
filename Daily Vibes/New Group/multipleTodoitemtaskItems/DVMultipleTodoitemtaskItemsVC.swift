//
//  DVMultipleTodoitemtaskItemsVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-02-18.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import GrowingTextView
import SwiftTheme
import UserNotifications
import SwiftyChrono

class DVMultipleTodoitemtaskItemsVC: ThemableViewController {
    
    @IBOutlet weak var oldTexview: RegeributedTextView!
    @IBOutlet weak var textView: RegeributedTextView!
    @IBOutlet weak var tableView: UITableView!
    
    private let store = CoreDataManager.store
    private var data = DVMultipleTodoitemtaskItemsVM()
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private var remindMeSwitch: UISwitch!
    private var inputToolbar: UIView!
    private var textViewBottomConstraint: NSLayoutConstraint!
    private let chrono = Chrono()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if data.curProject == nil {
            data.curProject = store.filteredProjectList
            data.prevProject = store.filteredProjectList
        } else {
            data.curProject = store.filteredProjectList
        }
        
        if data.cookedData == nil {
            data.cookedData = [DVMultipleTodoitemtaskItemVM]()
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupNavigationTitleText(title: "Add Multiple To-do Items")
        
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(handleSaveButton))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.view.theme_backgroundColor = "Global.backgroundColor"
        
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        //
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        // *** Customize GrowingTextView ***
        //        textView.layer.cornerRadius = 4.0
        
        let firstInputText = NSLocalizedString("One new to-do item task per line", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND One new to-do item task per line **", comment: "")
//        let secondInputText = NSLocalizedString("You can also include #tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You can also include #tags **", comment: "")
        
        let joinedPlaceHolderString = "- \(firstInputText)"

        textView.text = joinedPlaceHolderString
        
        textView.theme_backgroundColor = "Global.barTintColor"
        textView.theme_textColor = "Global.textColor"
        textView.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        textView.addAttribute(.hashTag, attribute: .bold)

        textView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableHeight?.constant = self.tableView.contentSize.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = view.bounds.height - endFrame.origin.y
            if keyboardHeight > 0 {
                keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
            }
            textViewBottomConstraint.constant = -keyboardHeight - 8
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func tapGestureHandler() {
        self.view.endEditing(true)
    }
    
    @objc func handleCancelButton() {
        if data.prevProject != nil {
            store.filteredProjectList = data.prevProject
        }
        self.view.endEditing(true)
        closeView()
    }
    
    @objc func handleSaveButton() {
        let project = data.curProject
        //        let projectText = project?.title ?? ""
        
        data.rawMultipleTaskText = textView.text
        
        data.parsedText = DVMultipleTodoitemtaskItemsVC.parseMultipleTodos(data: data, todosInput: data.rawMultipleTaskText!)
        
        if let hasParsedText = data.parsedText, hasParsedText.count > 0 {
            for item in hasParsedText {
                let temp = DVMultipleTodoitemtaskItemVM.init()
                temp.isRemindable = true
                temp.text = item
                
                if let parsedDate = chrono.parseDate(text: item) {
                    temp.dueDate = parsedDate
                }
                
                data.cookedData?.append(temp)
//                print("data.cookedData.count = \(data.cookedData?.count)")
                
//                if var establishedCookedData = data.cookedData {
//                    establishedCookedData.append(temp)
//                } else {
//                    fatalError("y u crash")
//                }
//                let tempParsedDate = chrono.parseDate(text: item)
//                print(tempParsedDate)
            }
        }
        
        store.processMultipleTodoitemTasks(forProject: project!, todoItemTasksData: data)
        
        //        let rawmultipletakitemtodoText = textView.text ?? ""
        
        //        print("project to add to: \(projectText)")
        //        print("data to parse: \(data.parsedText?.joined())")
        self.view.endEditing(true)
        closeView()
    }
    
    class func parseMultipleTodos(data: DVMultipleTodoitemtaskItemsVM, todosInput:String) -> [String] {
        
        let firstPass = todosInput.split(separator: "\n")
        var secondPass = [String]()
        //        var thirdPass = [String]()
        
        var hasTags: Bool = false
        
        if firstPass.count == 1 {
            let result = firstPass[0].trimmingCharacters(in: ["-"]).trimmingCharacters(in: [" "])
            let words = result.components(separatedBy: " ")
            let tags = words.filter { $0.hasPrefix("#") }
            
            if !hasTags {
                hasTags = !tags.isEmpty
                data.hasTags = !tags.isEmpty
            }
            
            if hasTags {
                let tagsStringText = tags.joined(separator: " ")
                data.tagListText = [tagsStringText]
            }
            
            secondPass = [result]
        } else {
            for (_,item) in firstPass.enumerated() {
                let result = item.trimmingCharacters(in: ["-"]).trimmingCharacters(in: [" "])
                let words = result.components(separatedBy: " ")
                let tags = words.filter { $0.hasPrefix("#") }
                
                if !hasTags {
                    hasTags = !tags.isEmpty
                    data.hasTags = !tags.isEmpty
                }
                
                secondPass.append(result)
            }
        }
        
        return secondPass
    }
    
    fileprivate func closeView() {
        let isPresentingInADDMode = presentingViewController is DailyVibesTabBarViewController
        
        if isPresentingInADDMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The TodoItemViewController is not inside a navigation controller.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//extension DVMultipleTodoitemtaskItemsVC: GrowingTextViewDelegate {
//
//    // *** Call layoutIfNeeded on superview for animation when changing height ***
//
//    //    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
//    //        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
//    //            self.view.layoutIfNeeded()
//    //        }, completion: nil)
//    //    }
//    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
//        UIView.setAnimationsEnabled(false)
//        let caret = tableView.convert(textView.caretRect(for: textView.selectedTextRange!.start), from: textView)
//        let keyboardTopBorder = textView.bounds.size.height - tableView.frame.width
//        if caret.origin.y > keyboardTopBorder && textView.isFirstResponder {
//            tableView.scrollRectToVisible(caret, animated: true)
//        }
//        UIView.setAnimationsEnabled(true)
//    }
//}

extension DVMultipleTodoitemtaskItemsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
        view.theme_backgroundColor = "Global.backgroundColor"
        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
        label.font = UIFont.systemFont(ofSize: 14)
        label.theme_textColor = "Global.barTextColor"
        //        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.text = ""
        view.addSubview(label)
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cell: = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
        
        var cell = UITableViewCell()
        let section = indexPath.section
        
        if section == 0 {
            // project
            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
            
            cell.theme_backgroundColor = "Global.barTintColor"
            cell.textLabel?.theme_textColor = "Global.textColor"
            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
            
            let projectLabelText = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
            
            cell.textLabel?.text = projectLabelText
            cell.detailTextLabel?.text = data.curProject?.title
            
            cell.accessoryType = .disclosureIndicator
        }
        
        if section == 1 {
            // due date
            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
            
            cell.theme_backgroundColor = "Global.barTintColor"
            cell.textLabel?.theme_textColor = "Global.textColor"
            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
            
            cell.textLabel?.text = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Due **", comment: "")
            
            if data.duedateAt == nil {
                cell.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
            } else {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                if let dt = data.duedateAt {
                    cell.detailTextLabel?.text = dateFormatter.string(from:dt)
                }
            }
            
            cell.accessoryType = .disclosureIndicator
        }
        
        if section == 2 {
            // remind me cell
            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
            
            cell.selectionStyle = .none
            
//            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
            
            cell.theme_backgroundColor = "Global.barTintColor"
            cell.textLabel?.theme_textColor = "Global.textColor"
            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
            cell.detailTextLabel?.text = ""
            
            cell.textLabel?.text = NSLocalizedString("Remind me", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Remind me **", comment: "")
            
            let remindersSwitch = UISwitch.init(frame: CGRect.init())
            remindMeSwitch = remindersSwitch
            
            cell.addSubview(remindersSwitch)
            cell.accessoryView = remindersSwitch
            remindMeSwitch.theme_onTintColor = "Global.barTextColor"
            
            if data.duedateAt == nil {
                remindersSwitch.isEnabled = false
                remindMeSwitch.isOn = false
            } else {
                remindersSwitch.isEnabled = true
                remindMeSwitch.addTarget(self, action: #selector(self.remindSwitchDidChange), for: .valueChanged)
                
                remindMeSwitch.isOn = data.isRemindable
            }
        }
        
        return cell
    }
    
    // MARK: - Remind me Switch
    @objc func remindSwitchDidChange(sender:UISwitch!) {
        hasAccess(isRemindable: sender.isOn)
    }
    
    private func hasAccess(isRemindable:Bool) {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted || error != nil {
                self.presentGoToSettings()
            } else {
                self.data.isRemindable = isRemindable
            }
        }
    }
    
    private func presentGoToSettings() {
        let messageTitle = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notifications **", comment: "")
        let messageTxt = NSLocalizedString("Please enable Notifications to use this feature", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Please enable Notifications to use this feature **", comment: "")
        let alertCtrl = UIAlertController.init(title: messageTitle, message: messageTxt, preferredStyle: .alert)
        
        let settingsTxt = NSLocalizedString("Go to Settings", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Go to Settings **", comment: "")
        let settingsAct = UIAlertAction.init(title: settingsTxt, style: .default) { (_) in
            guard let settingsUrl = URL.init(string: UIApplicationOpenSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
        
        let cancelTxt = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel **", comment: "")
        let cancelAct = UIAlertAction.init(title: cancelTxt, style: .cancel, handler: nil)
        
        alertCtrl.addAction(settingsAct)
        alertCtrl.addAction(cancelAct)
        
        present(alertCtrl, animated: true, completion: nil)
    }
    
    // MARK: - DatePicker
    func datePickerTappedForDuedateAtDateCell() {
        let datePicker = DatePickerDialog()
        
        let setDueDateTitle = NSLocalizedString("Set Due Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set Due Date ***", comment: "")
        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        datePicker.show(setDueDateTitle,
                        doneButtonTitle: setString,
                        cancelButtonTitle: cancelString,
                        defaultDate: Date().endTime()) { [unowned self] (date) in
                            if let dt = date {
                                self.data.duedateAt = dt
                                self.tableView.reloadData()
                            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if section == 0 {
            let storyboard = UIStoryboard.init(name: "DVProjectListStoryboard", bundle: nil)
            let tvc = storyboard.instantiateViewController(withIdentifier: "DVListTableViewController")
            navigationController?.pushViewController(tvc, animated: true)
        }
        
        if section == 1 {
            datePickerTappedForDuedateAtDateCell()
        }
    }
}

extension DVMultipleTodoitemtaskItemsVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //        if touch.view.isDescendantOf(tableView) {
        //            return false
        //        }
        //
        return true
    }
}

extension DVMultipleTodoitemtaskItemsVC: RegeributedTextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let _textView = textView as! RegeributedTextView
        
        if let barTextColor = ThemeManager.value(for: "Global.barTextColor") as? String {
            _textView.addAttribute("#[a-zA-Z0-9]+", attribute: .textColor(UIColor.from(hex: barTextColor)), values: ["URL": "https://google.com"])
        }
        
        return true
    }
    
    func regeributedTextView(_ textView: RegeributedTextView, didSelect text: String, values: [String : Any]) {
        print("Selected word: \(text)")
        //        selectedLabel.text = text
        
        // You can get the emmbeded url from values
//        if let url = values["URL"] as? String {
//            // e.g.
//            // UIApplication.shared.openURL(URL(string: url)!)
//        }
    }
    
}
