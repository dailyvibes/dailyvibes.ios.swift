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

class TodoItemViewController: ThemableTableViewController,
    UITextViewDelegate,
    UINavigationControllerDelegate,
    UIPickerViewDataSource,
UIPickerViewDelegate {
    // MARK: Properties
//    private var todoItem: TodoItem?
    
//    private var todoItemSettingsData: TodoItemSettingsData?
    private var todoItemTaskViewModel: DVTodoItemTaskViewModel? {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var store = CoreDataManager.store
    
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
    
    fileprivate func refreshNotesInlineCell() {
        let notesContent = todoItemTaskViewModel?.note?.content
        
        if notesContent == nil {
            let emptyNotesText = NSLocalizedString("Notes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notes **", comment: "")
            notesInlineCell.setText(text: emptyNotesText)
        } else {
//            notesInlineCell.setText(text: notesContent)
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
        
        if todoItemTaskViewModel == nil {
            store.findOrCreateTodoitemTaskDeepNested(withUUID: nil)
            todoItemTaskViewModel = store.editingDVTodotaskItem
            todoItemTaskViewModel?.todoItemText = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND TITLE STRING **", comment: "")
            let _title = "Add a to-do"
            setupNavigationTitleText(title: _title, subtitle: nil)
        } else {
            let _title = "Details"
            let actionButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleActionButton))
            
            navigationItem.rightBarButtonItems = [saveTodoitemButton, actionButton]
            
            setupNavigationTitleText(title: _title, subtitle: nil)
        }
        
        tagsCell.textLabel?.text = NSLocalizedString("Tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tags **", comment: "")

        setupTheming()
        updateSaveButtonState()
        refreshNotesInlineCell()
    }
    
    @objc func handleActionButton() {
        var tagsText: String = ""
        let todoitemTaskText = todoItemTaskViewModel?.todoItemText ?? ""
        
        UIPasteboard.general.string = todoItemTaskViewModel?.todoItemText
        
        if let hasTags = todoItemTaskViewModel?.tags, hasTags.count > 0 {
            tagsText = hasTags.map { tag in "#" + tag.label } .joined(separator: " ")
        }
        
        let pasteBoardText = "\(todoitemTaskText) \(tagsText)"
         
        UIPasteboard.general.string = pasteBoardText
        
        let copiedText = NSLocalizedString("Copied to clipboard", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Copied to clipboard **", comment: "")
        let alert = UIAlertController(title: "", message: copiedText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleSaveButton() {
        store.saveEditingDVTodotaskItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(ThemableBaseTableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        // Handle the text field’s user input through delegate callbacks.
        todoItemTextView.delegate = self
        deleteCell.delegate = self
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = DateFormatter.Style.short
        dateFormatter?.timeStyle = DateFormatter.Style.short
        
        showOrHideKeyboard()
    }
    
    private func showOrHideKeyboard() {
        if let isNew = todoItemTaskViewModel?.isNew, isNew {
            todoItemTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.endEditing(true)
    }
    
    // MARK: Navigation
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
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        store.editingDVTodotaskItem = nil
        closeView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let saveButtonSegueIdentifier = "saveButtonSegue"
        
        if segue.identifier == saveButtonSegueIdentifier {
            store.saveEditingDVTodotaskItem()
        }
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
            
            if textView.text == emptyString {
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
            
            if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
                textView.text = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND TITLE STRING **", comment: "")
                textView.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
                textView.theme_tintColor = "Global.textColor"
                textView.theme_textColor = "Global.textColor"
            }
            
            updateSaveButtonState()
            
            if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            updateSaveButtonState()
        }
        return true;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == todoItemTextView {
            todoItemTaskViewModel?.todoItemText = textView.text
            
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
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == todoItemTextFieldCell {
            todoItemTextView.text = todoItemTaskViewModel?.todoItemText
        }
        
        if cell == duedateAtDateCell {
            cell.textLabel?.text = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Due **", comment: "")
            
            let dueDateLabelString = todoItemTaskViewModel?.duedateAt
            
            if dueDateLabelString != nil {
                duedateAtDateCell?.detailTextLabel?.text = dateFormatter?.string(from: dueDateLabelString!)
            } else {
                duedateAtDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
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
                reminderToggle.isEnabled = false
                reminderToggle.isOn = false
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
        }
        
        if cell == listsCell {
            cell.textLabel?.text = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
            
            let listLabel = todoItemTaskViewModel?.list?.title ?? ""
            let isEmpty = listLabel.trimmingCharacters(in: .whitespaces).isEmpty
            
            if isEmpty {
                let emptyLabel = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND None **", comment: "")
                cell.detailTextLabel?.text = emptyLabel
            } else {
                cell.detailTextLabel?.text = listLabel
            }
        }
        
        if cell == notesInlineCell {
            refreshNotesInlineCell()
        }
        
        if cell == deleteCell {
            let isNew = todoItemTaskViewModel?.isNew ?? true
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
            datePickerTappedForDuedateAtDateCell()
        }
        
        self.tableView.endUpdates()
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
    
    // MARK: - Datepickertapped
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
                                self.todoItemTaskViewModel?.duedateAt = dt
                                self.duedateAtDateCell.detailTextLabel?.text = self.dateFormatter?.string(from: dt)
                                self.tableView.reloadData()
                            }
        }
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = todoItemTaskViewModel?.todoItemText ?? ""
        let isEmptyField = text.trimmingCharacters(in: .whitespaces).isEmpty
        saveTodoitemButton.isEnabled = !isEmptyField
    }
    
//    fileprivate func performTodoItemSetup() {
//        if todoItemTaskViewModel != nil {
//            todoItemSettingsData = TodoItemSettingsData.init(forViewModel: todoItemTaskViewModel!)
//        } else {
//            todoItemSettingsData = TodoItemSettingsData.init(forViewModel: nil)
//        }
//
//        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
//            fatalError("todoItemSettingsData should be set by now")
//        }
//
//        if !data.isNewTodo() {
//            // handle already created to do Item
//            todoItemTextView.text = data.getTodoText()
//            let _title = "Details"
//            setupNavigationTitleText(title: _title)
//        } else {
//            // a new to do
//            let _title = "Add a to do"
//            setupNavigationTitleText(title: _title)
//            todoItemTextView.text = data.getTodoPlaceholderText()
//            saveTodoitemButton.isEnabled = false
//        }
//
////        if let duedateAtDate = todoItemSettingsData?.getTodoDuedateAt() {
////            duedateAtDateCell?.detailTextLabel?.text = dateFormatter?.string(from: duedateAtDate)
////        } else {
////            duedateAtDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
////        }
//
////        let tagsText: String?
////
////        if data.holdingAnyTags() {
////            tagsText = NSLocalizedString("view tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND view tags **", comment: "")
////        } else {
////            tagsText = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
////        }
////
////        tagsCell.detailTextLabel?.text = tagsText
//    }
    
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
