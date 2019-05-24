//
//  ViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

// Emotion section footer text for later
// Whenever you are here, feel free to update your emotion while working on this task. Over time, you'll be able to see if this task is worth doing for you.

import UIKit
import CoreData
import UserNotifications
import SwiftyChrono
import SwiftTheme
import ContextMenu

class TodoItemViewController:
    ThemableTableViewController,
    UITextViewDelegate,
    UINavigationControllerDelegate,
    UIPickerViewDataSource,
    UIPickerViewDelegate {
    
    private var todoItemTaskViewModel: DVTodoItemTaskViewModel?
    private var store = CoreDataManager.store
    private var chrono = Chrono()
    
    // MARK: Outlets
    @IBOutlet private weak var todoItemTextFieldCell: NewTodoItemTableViewCell!
    @IBOutlet private weak var tagsCell: UITableViewCell!
    @IBOutlet private weak var listsCell: UITableViewCell!
    @IBOutlet private weak var notesInlineCell: NotesInlineTableViewCell!
    @IBOutlet private weak var deleteCell: DeleteTableViewCell!
    
    @IBOutlet private weak var todoItemTextView: UITextView!
    @IBOutlet private weak var saveTodoitemButton: UIBarButtonItem!
    
    @IBOutlet private weak var createdAtDateCell: UITableViewCell!
    @IBOutlet private weak var duedateAtDateCell: UITableViewCell!
    @IBOutlet private weak var completedAtDateCell: UITableViewCell!
    @IBOutlet private weak var archivedAtDateCell: UITableViewCell!
    
    @IBOutlet private weak var reminderCell: UITableViewCell!
    @IBOutlet private weak var reminderCellLabel: UILabel!
    @IBOutlet private weak var reminderToggle: UISwitch!
    @IBOutlet weak var startDateCell: UITableViewCell!
    @IBOutlet weak var endDateCell: UITableViewCell!
    
    
    private var statusPickerVisible: Bool = false
    
    private var editingEmotionPicker: Bool = false
    private var editingCompletionDate: Bool = false
    private var dateFormatter: DateFormatter?
    private var showCompletedCell: Bool = false
    
    private let emotionsList = [
        ["Love", UIColor.red],
        ["Happy", UIColor.orange],
        ["Excited", UIColor.yellow],
        ["Fear", UIColor.green],
        ["Sad", UIColor.blue],
        ["Angry", UIColor.purple]
    ]
    
    lazy var customSelectionView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    fileprivate func refreshNotesInlineCell() {
        let notesContent = store.editingDVTodotaskItem?.note?.content
        
        if notesContent == nil {
//            let emptyNotesText = NSLocalizedString("Notes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notes **", comment: "")
//            notesInlineCell.setText(text: emptyNotesText)
            let txt = """
            # Add Notes

            ## Optionally use Markdown
            
            Use **Markdown** to create beautiful *notes*.
            
            Write code : ` let str = "Hello World" `

            Jot down quotes like this and [reference them](https://dailyvibes.ca):

            > Here is an important quote

            * Quickly make lists
            - Breakdown large ideas
            + Reduce stress by writing things down

            [ ] create a sample demo list
            [X] show a completed task
            """
//            var string = "# "+emptyNotesText
            notesInlineCell.setAttributedText(text: txt)
        } else {
            notesInlineCell.setAttributedText(text: notesContent)
        }
    }
    
    func setData(withViewModel: DVTodoItemTaskViewModel) {
        store.findOrCreateTodoitemTaskDeepNested(withUUID: withViewModel.uuid)
        todoItemTaskViewModel = store.editingDVTodotaskItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        todoItemTaskViewModel = store.editingDVTodotaskItem
        
        let _title = "Details"
        
        if let curProject = todoItemTaskViewModel?.list {
            self.store.editingDVTodotaskItemListPlaceholder = DVListViewModel.copyWithoutListItems(list: curProject)
        }
        
        navigationItem.rightBarButtonItems = [saveTodoitemButton]
        
        setupNavigationTitleText(title: _title, subtitle: nil)
        
        self.tableView.reloadData()
        
        let cancelBn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBn.accessibilityIdentifier = "details_cancel_btn"
        navigationItem.leftBarButtonItems = [cancelBn]
        
        tagsCell.textLabel?.text = NSLocalizedString("Tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tags **", comment: "")
        
        setupTheming()
        updateSaveButtonState()
        refreshNotesInlineCell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(ThemableBaseTableViewCell.self, forCellReuseIdentifier: "DefaultCell")

        todoItemTextView.delegate = self
        deleteCell.delegate = self
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = DateFormatter.Style.short
        dateFormatter?.timeStyle = DateFormatter.Style.short
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadTVC), name: Notification.Name("ListTableViewController.projectListChange"), object: nil)
        
        showOrHideKeyboard()
    }
    
    @objc
    func reloadTVC() {
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showOrHideKeyboard() {
        if let isNew = todoItemTaskViewModel?.isNew, isNew {
            todoItemTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        store.editingDVTodotaskItem = todoItemTaskViewModel
        if todoItemTextView.isFirstResponder {
            todoItemTextView.resignFirstResponder()
        }
        self.view.endEditing(true)
    }
    
    // MARK: Navigation
    fileprivate func closeView() {
        self.store.editingDVTodotaskItem = nil
        self.todoItemTaskViewModel = nil
        self.store.editingDVTodotaskItemListPlaceholder = nil
        
            let isPresentingInADDMode = self.presentingViewController is DailyVibesTabBarViewController
            
            if isPresentingInADDMode {
                self.dismiss(animated: true, completion: nil)
            } else if let owningNavigationController = self.navigationController {
                owningNavigationController.popViewController(animated: true)
            } else {
                fatalError("The TodoItemViewController is not inside a navigation controller.")
            }
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        closeView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let saveButtonSegueIdentifier = "saveButtonSegue"
        
        if segue.identifier == saveButtonSegueIdentifier {
            store.editingDVTodotaskItem = todoItemTaskViewModel
            self.store.saveEditingDVTodotaskItem()
        }
        
//        if segue.identifier == "newNoteSegue" {
//            if let goto = segue.destination as? NotesViewController {

//                let _color = ThemeManager.value(for: "Global.barTintColor")
//
//                guard let rgba = _color as? String else {
//                    fatalError("could not get value from ThemeManager")
//                }
//
//                let color = UIColor(rgba: rgba)
//
//                ContextMenu.shared.show(sourceViewController: self, viewController: <#T##UIViewController#>)
//
//                ContextMenu.shared.show(
//                    sourceViewController: self,
//                    viewController: goto,
//                    sourceView: self
//                )
//
//                goto.modalPresentationStyle = .pageSheet
//
//                let sourceViewController = self
//
//                if let topvc = UIApplication.shared.keyWindow?.rootViewController {
//                    ContextMenu.shared.show(sourceViewController: topvc, viewController: goto, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)))
//                }
//
//                alert.addAction(image: notificationsImage, title: "View Notifications", color: .black, style: .default, isEnabled: true) { (action) in
//                    let storyboard = UIStoryboard.init(name: "DVLocalNotifications", bundle: nil)
//                    let tvc = storyboard.instantiateViewController(withIdentifier: "dvLNTableViewController")
//
//                }
//                let navigationController = UINavigationController(rootViewController: goto)
//                navigationController.navigationBar.isTranslucent = false
//                navigationController.navigationBar.theme_barTintColor = "Global.barTintColor"
//                navigationController.navigationBar.barStyle = .blackTranslucent
//
//                present(navigationController, animated: true, completion: nil)
//        }
//    }
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emotionsList.count
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == todoItemTextView {
            saveTodoitemButton.isEnabled = false
            
            let emptyString = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND TITLE STRING **", comment: "")
            
            if textView.placeholder == emptyString {
                if todoItemTaskViewModel?.todoItemText == emptyString {
                    textView.text = ""
                } else {
                    textView.text = todoItemTaskViewModel?.todoItemText
                }
                textView.text = ""
            }
            
            if textView.text == todoItemTaskViewModel?.todoItemText {
                textView.text = todoItemTaskViewModel?.todoItemText
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == todoItemTextView {
            todoItemTaskViewModel?.todoItemText = textView.text
            
            let parsedDueDate = chrono.parseDate(text: textView.text)
            
            if parsedDueDate != nil {
                let dueDateCellindexPath = IndexPath.init(row: 0, section: 1)
                let reminderCellindexPath = IndexPath.init(row: 1, section: 1)
                todoItemTaskViewModel?.duedateAt = parsedDueDate
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [dueDateCellindexPath, reminderCellindexPath], with: .none)
                self.tableView.endUpdates()
            }
            
            if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
                textView.text = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND TITLE STRING **", comment: "")
                textView.theme_tintColor = "Global.textColor"
                textView.theme_textColor = "Global.textColor"
            }
            
            updateSaveButtonState()
            
            if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if todoItemTextView.isFirstResponder {
            todoItemTextView.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
            updateSaveButtonState()
        }
        return true
    }
    
    var runningText: String = ""
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == todoItemTextView {
            runningText = textView.text
            
            let newHeight = todoItemTextFieldCell.frame.size.height + textView.contentSize.height
            todoItemTextFieldCell.frame.size.height = newHeight
            updateTableViewContentOffsetForTextView()
        }
    }
    
    func updateTableViewContentOffsetForTextView() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == todoItemTextFieldCell {
            todoItemTextView.text = todoItemTaskViewModel?.todoItemText
        }
        
        if cell == duedateAtDateCell {
            cell.textLabel?.text = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Due **", comment: "")
            cell.selectedBackgroundView = customSelectionView
            
            let dueDateLabelString = todoItemTaskViewModel?.duedateAt
            
            if dueDateLabelString != nil {
                duedateAtDateCell?.detailTextLabel?.text = dateFormatter?.string(from: dueDateLabelString!)
            } else {
                if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
                    let cal = Calendar.current
                    var customtime = DateComponents()
                    let now = Date().add(days:1)
                    
                    customtime.year = now.year
                    customtime.day = now.day
                    customtime.month = now.month
                    customtime.hour = 09
                    customtime.minute = 41
                    
                    if let date = cal.date(from: customtime) {
                        let dformatter = DateFormatter()
                        dformatter.dateStyle = .short
                        dformatter.timeStyle = .short
                        
                        duedateAtDateCell.detailTextLabel?.text = dformatter.string(from: date)
                    }
                } else {
                    duedateAtDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
                }
            }
        }
        
        if cell == startDateCell {
            cell.textLabel?.text = NSLocalizedString("Start", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Start **", comment: "")
            cell.selectedBackgroundView = customSelectionView
            
            let startdateLabelString = todoItemTaskViewModel?.startdateAt
            
            if let duedate = startdateLabelString {
                startDateCell?.detailTextLabel?.text = dateFormatter?.string(from: duedate)
            } else {
                if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
                    let cal = Calendar.current
                    var customtime = DateComponents()
                    let now = Date()
                    
                    customtime.year = now.year
                    customtime.day = now.day
                    customtime.month = now.month
                    customtime.hour = 09
                    customtime.minute = 41
                    
                    if let date = cal.date(from: customtime) {
                        let dformatter = DateFormatter()
                        dformatter.dateStyle = .short
                        dformatter.timeStyle = .short
                        
                        startDateCell.detailTextLabel?.text = dformatter.string(from: date)
                    }
                } else {
                    startDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
                }
            }
        }
        
        if cell == endDateCell {
            cell.textLabel?.text = NSLocalizedString("End", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND End **", comment: "")
            cell.selectedBackgroundView = customSelectionView
            
            let enddateLabelString = todoItemTaskViewModel?.enddateAt
            
            if let duedate = enddateLabelString {
                endDateCell?.detailTextLabel?.text = dateFormatter?.string(from: duedate)
            } else {
                if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
                    let cal = Calendar.current
                    var customtime = DateComponents()
                    let now = Date().add(days: 1)
                    
                    customtime.year = now.year
                    customtime.day = now.day
                    customtime.month = now.month
                    customtime.hour = 09
                    customtime.minute = 41
                    
                    if let date = cal.date(from: customtime) {
                        let dformatter = DateFormatter()
                        dformatter.dateStyle = .short
                        dformatter.timeStyle = .short
                        
                        endDateCell.detailTextLabel?.text = dformatter.string(from: date)
                    }
                } else {
                    endDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
                }
            }
        }
        
        if cell == reminderCell {
            reminderCell.selectionStyle = .none
            reminderCellLabel.text = NSLocalizedString("Remind me", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Remind me **", comment: "")
            
            let dueDateLabelString = todoItemTaskViewModel?.duedateAt
            
            if dueDateLabelString != nil {
                reminderToggle.addTarget(self, action: #selector(self.remindSwitchDidChange), for: .valueChanged)
                reminderToggle.isEnabled = true
                
                if let isRemindable = todoItemTaskViewModel?.isRemindable, isRemindable {
                    reminderToggle.isOn = isRemindable
                } else {
                    reminderToggle.isOn = false
                }
            } else {
//                reminderToggle.isEnabled = false
//                reminderToggle.isOn = false
                if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
                    reminderToggle.isEnabled = true
                    reminderToggle.isOn = true
                } else {
                    reminderToggle.isEnabled = false
                    reminderToggle.isOn = false
                }
            }
        }
        
        if cell == tagsCell {
            let tagsText: String?
            
            if let hasTags = todoItemTaskViewModel?.tags, hasTags.count > 0 {
                tagsText = hasTags.map { tag in tag.label } .joined(separator: " ")
            } else {
                tagsText = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
            }
            
            cell.detailTextLabel?.text = tagsText
            cell.selectedBackgroundView = customSelectionView
        }
        
        if cell == listsCell {
            cell.textLabel?.text = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
            
            let listLabel = store.editingDVTodotaskItemListPlaceholder?.title ?? ""
            let isEmpty = listLabel.trimmingCharacters(in: .whitespaces).isEmpty
            
            if isEmpty {
                let emptyLabel = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND None **", comment: "")
                cell.detailTextLabel?.text = emptyLabel
            } else {
//                cell.detailTextLabel?.text = listLabel
//                if let title = store.editingDVTodotaskItemListPlaceholder?.title {
                    if let _emoji = store.editingDVTodotaskItemListPlaceholder?.emoji {
                        cell.detailTextLabel?.text = listLabel + " " + _emoji
                    } else {
                        cell.detailTextLabel?.text = listLabel
                    }
//                }
            }
            cell.selectedBackgroundView = customSelectionView
        }
        
        if cell == notesInlineCell {
            refreshNotesInlineCell()
            cell.selectedBackgroundView = customSelectionView
        }
        
        if cell == deleteCell {
            let isNew = store.editingDVTodotaskItem?.isNew ?? true
            if !isNew {
                self.tableView.beginUpdates()
                deleteCell.enableDeleteButton()
                self.tableView.endUpdates()
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false);
        
        let cell = tableView.cellForRow(at: indexPath)
        
        self.tableView.beginUpdates()
        
        if (cell == self.duedateAtDateCell) {
            let btnfeedback = UIImpactFeedbackGenerator()
            btnfeedback.impactOccurred()
            
            datePickerTappedForDuedateAtDateCell()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if (cell == self.startDateCell) {
            let btnfeedback = UIImpactFeedbackGenerator()
            btnfeedback.impactOccurred()
            
            datePickerTappedForStartDateCell()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if (cell == self.endDateCell) {
            let btnfeedback = UIImpactFeedbackGenerator()
            btnfeedback.impactOccurred()
            
            datePickerTappedForEndDateCell()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if cell == self.listsCell {
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let tvc = storyboard.instantiateViewController(withIdentifier: "ListTableViewController")
            
            if let goto = tvc as? ListTableViewController {
                
                let _color = ThemeManager.value(for: "Global.backgroundColor")
                
                guard let rgba = _color as? String else {
                    fatalError("could not get value from ThemeManager")
                }
                
                let color = UIColor(rgba: rgba)
                
                goto.inModalView = true
                
                ContextMenu.shared.show(sourceViewController: self, viewController: goto, options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: color)), delegate: self)
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        self.tableView.endUpdates()
    }
    
    func datePickerTappedForStartDateCell() {
        let setDueDateTitle = NSLocalizedString("Set Start Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set Start Date ***", comment: "")
        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        let resetString = NSLocalizedString("Reset", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reset **", comment: "")
        
        let alert = UIAlertController(style: .actionSheet, title: setDueDateTitle, message: nil)
        
        alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: nil, maximumDate: nil) { date in
            self.todoItemTaskViewModel?.startdateAt = date
            self.tableView.beginUpdates()
            self.startDateCell.detailTextLabel?.text = self.dateFormatter?.string(from: date)
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        
        if let _ = self.todoItemTaskViewModel?.startdateAt {
            alert.addAction(title: resetString, style: .destructive, handler: { data in
                self.todoItemTaskViewModel?.startdateAt = nil
                self.tableView.beginUpdates()
                self.startDateCell.detailTextLabel?.text = setDueDateTitle
                self.tableView.endUpdates()
                self.tableView.reloadData()
            })
        }
        
        alert.addAction(title: setString, style: .default)
        alert.addAction(title: cancelString, style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func datePickerTappedForEndDateCell() {
        let setDueDateTitle = NSLocalizedString("Set End Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set End Date ***", comment: "")
        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        let resetString = NSLocalizedString("Reset", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reset **", comment: "")
        
        let suggesteddate = self.todoItemTaskViewModel?.startdateAt?.add(days:1) ?? Date()
        
        let alert = UIAlertController(style: .actionSheet, title: setDueDateTitle, message: nil)
        alert.addDatePicker(mode: .dateAndTime, date: suggesteddate, minimumDate: nil, maximumDate: nil) { date in
            //            Log(date)
            self.todoItemTaskViewModel?.enddateAt = date
            self.tableView.beginUpdates()
            self.endDateCell.detailTextLabel?.text = self.dateFormatter?.string(from: date)
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        
        if let _ = self.todoItemTaskViewModel?.enddateAt {
            alert.addAction(title: resetString, style: .destructive, handler: { data in
                self.todoItemTaskViewModel?.enddateAt = nil
//                self.todoItemTaskViewModel?.isRemindable = false
                self.tableView.beginUpdates()
                self.endDateCell.detailTextLabel?.text = setDueDateTitle
                self.tableView.endUpdates()
                self.tableView.reloadData()
            })
        }
        alert.addAction(title: setString, style: .default)
        alert.addAction(title: cancelString, style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Reminder Switch
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
                self.todoItemTaskViewModel?.isRemindable = isRemindable
            }
        }
    }
    
    private func presentGoToSettings() {
        let messageTitle = NSLocalizedString("Notifications", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notifications **", comment: "")
        let messageTxt = NSLocalizedString("Please enable Notifications to use this feature", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Please enable Notifications to use this feature **", comment: "")
        let alertCtrl = UIAlertController.init(title: messageTitle, message: messageTxt, preferredStyle: .alert)
        
        let settingsTxt = NSLocalizedString("Go to Settings", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Go to Settings **", comment: "")
        let settingsAct = UIAlertAction.init(title: settingsTxt, style: .default) { (_) in
            guard let settingsUrl = URL.init(string: UIApplication.openSettingsURLString) else { return }
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
    
    // MARK: - Datepickertapped
    func datePickerTappedForDuedateAtDateCell() {
        let setDueDateTitle = NSLocalizedString("Set Due Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set Due Date ***", comment: "")
        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        let resetString = NSLocalizedString("Reset", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Reset **", comment: "")
        
        let alert = UIAlertController(style: .actionSheet, title: setDueDateTitle, message: nil)
        alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: nil, maximumDate: nil) { date in
//            Log(date)
            self.todoItemTaskViewModel?.duedateAt = date
            self.tableView.beginUpdates()
            self.duedateAtDateCell.detailTextLabel?.text = self.dateFormatter?.string(from: date)
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        if let _ = self.todoItemTaskViewModel?.duedateAt {
            alert.addAction(title: resetString, style: .destructive, handler: { data in
                self.todoItemTaskViewModel?.duedateAt = nil
                self.todoItemTaskViewModel?.isRemindable = false
                self.tableView.beginUpdates()
                self.duedateAtDateCell.detailTextLabel?.text = setDueDateTitle
                self.tableView.endUpdates()
                self.tableView.reloadData()
            })
        }
        alert.addAction(title: setString, style: .default)
        alert.addAction(title: cancelString, style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        let text = todoItemTaskViewModel?.todoItemText ?? ""
        let isEmptyField = text.trimmingCharacters(in: .whitespaces).isEmpty
        
        saveTodoitemButton.isEnabled = !isEmptyField
    }
    
    private func setupTheming() {
        todoItemTextView.theme_textColor = "Global.textColor"
        todoItemTextView.theme_tintColor = "Global.textColor"
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        todoItemTextFieldCell.theme_backgroundColor = "Global.barTintColor"
        
        tagsCell.theme_backgroundColor = "Global.barTintColor"
        tagsCell.theme_tintColor = "Global.textColor"
        tagsCell.textLabel?.theme_textColor = "Global.textColor"
        tagsCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        listsCell.theme_backgroundColor = "Global.barTintColor"
        listsCell.theme_tintColor = "Global.textColor"
        listsCell.textLabel?.theme_textColor = "Global.textColor"
        listsCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        duedateAtDateCell.theme_backgroundColor = "Global.barTintColor"
        duedateAtDateCell.theme_tintColor = "Global.textColor"
        duedateAtDateCell.textLabel?.theme_textColor = "Global.textColor"
        duedateAtDateCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        reminderCell.theme_backgroundColor = "Global.barTintColor"
        reminderCellLabel.theme_textColor = "Global.textColor"
        reminderToggle.theme_onTintColor = "Global.barTextColor"
        
        startDateCell.theme_backgroundColor = "Global.barTintColor"
        startDateCell.theme_tintColor = "Global.textColor"
        startDateCell.textLabel?.theme_textColor = "Global.textColor"
        startDateCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        endDateCell.theme_backgroundColor = "Global.barTintColor"
        endDateCell.theme_tintColor = "Global.textColor"
        endDateCell.textLabel?.theme_textColor = "Global.textColor"
        endDateCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
    }
    
}

extension TodoItemViewController: NotesViewControllerUpdaterDelegate {
    func updateTableView() {
        self.tableView.reloadData()
    }
}


extension TodoItemViewController : DeleteButtonTableViewCellDelegate {
    func processDeleteButtonClick() {
        showDeleteAction()
    }
    
    func showDeleteAction() {
        let deleteAlertTitle = NSLocalizedString("Are you sure?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Are you sure? ***", comment: "")
        let deleteAlertMessage = NSLocalizedString("You're about to delete forever", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You're about to delete forever ***", comment: "")
        let deleteAlertConfirmation = NSLocalizedString("Yes, Delete Forever.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Delete Forever. ***", comment: "")
        
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
        
        if showDoneAlert {
            let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { [unowned self] _ in
                guard self.store.destroyTodoItemTask(withUUID: self.todoItemTaskViewModel?.uuid) else { fatalError("failed to delete") }
                self.closeView()
            })
            //
            let cancelLabel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
            let cancel = UIAlertAction(title: cancelLabel, style: .cancel, handler: nil)
            //
            alertController.addAction(delete)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            guard self.store.destroyTodoItemTask(withUUID: self.todoItemTaskViewModel?.uuid) else { fatalError("failed to delete") }
            self.dismiss(animated: true, completion: nil)
            self.closeView()
        }
    }
}

extension TodoItemViewController : ContextMenuDelegate {
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
        //        super.contextMen
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
//        cookDatData()
        print("exiting context menu")
    }
}
