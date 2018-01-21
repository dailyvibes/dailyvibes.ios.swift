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

class TodoItemViewController: ThemableTableViewController,
    UITextViewDelegate,
    UINavigationControllerDelegate,
    UIPickerViewDataSource,
UIPickerViewDelegate {
    // MARK: Properties
    private var todoItem: TodoItem?
    private var todoItemSettingsData: TodoItemSettingsData?
    
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
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.store.persistentContainer
    private var moc: NSManagedObjectContext?
    
    fileprivate func refreshNotesInlineCell() {
        let notesContent = todoItemSettingsData?.getNoteText()
        let isEmptyField = notesContent?.trimmingCharacters(in: .whitespaces).isEmpty
        
        if let isEmpty = isEmptyField, isEmpty {
            let emptyNotesText = NSLocalizedString("Notes", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Notes **", comment: "")
            notesInlineCell.setText(text: emptyNotesText)
        } else {
            notesInlineCell.setText(text: notesContent)
        }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagsCell.textLabel?.text = NSLocalizedString("Tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tags **", comment: "")
        
        setupTheming()
        refreshNotesInlineCell()
    }
    
    override func viewDidLoad() {
        // good place to init and setup objects used in viewController
        
        super.viewDidLoad()
        
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Handle the text field’s user input through delegate callbacks.
        todoItemTextView.delegate = self
        deleteCell.delegate = self
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = DateFormatter.Style.short
        dateFormatter?.timeStyle = DateFormatter.Style.short
        
        performTodoItemSetup()
        updateSaveButtonState()
        
        showOrHideKeyboard()
    }
    
    private func showOrHideKeyboard() {
        if let isNew = todoItemSettingsData?.isNewTodo(), isNew {
            todoItemTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setData(toProcess todoItem: TodoItem?, inContext context: NSManagedObjectContext?) {
        //        self.moc = context
        self.moc = container?.viewContext
        self.todoItem = todoItem
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
        guard let data = todoItemSettingsData else {
            fatalError("todoItemSettingsData should be set by now")
        }
        
        guard data.processCancel(in: moc!) else {
            fatalError("cancel should have been processed")
        }
        
        closeView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let data = todoItemSettingsData else {
            fatalError("todoItemSettingsData should be set by now")
        }
        
        switch segue.identifier ?? "" {
        case "saveButtonSegue":
            guard data.processSave(in: moc!) else {
                fatalError("processSave should have been successful")
            }
        case "newTagSegue":
            guard let tagsTVC = segue.destination as? TagsTableViewController else {
                fatalError("wasn't a TagsTableViewController segue")
            }
            tagsTVC.configure(todoItemSettingsData: data)
        case "listsSegue":
            guard let listsTVC = segue.destination as? ListTableViewController else {
                fatalError("wasnt a ListTableViewController segue")
            }
            listsTVC.configure(todoItemSettingsData: data)
        case "newNoteSegue":
            guard let notesVC = segue.destination as? NotesViewController else {
                fatalError("wasnt a NotesViewController segue")
            }
            
            let noteTextTitle = data.getNoteTitle()
            let noteTextString = data.getNoteText()
            
            //            notesVC.setup(title: noteTextTitle, textContent: noteTextString)
            notesVC.delegate = self
            notesVC.setup(title: noteTextTitle, textContent: noteTextString, for: data)
        default:
            fatalError("Should not be here")
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
        guard let data = todoItemSettingsData else {
            fatalError("todoItemSettingsData should be init by now")
        }
        if textView == todoItemTextView {
//            if !textView.isFirstResponder {
//                textView.becomeFirstResponder()
//            }
//            
            saveTodoitemButton.isEnabled = false
            
            if textView.text == data.getTodoPlaceholderText() {
                textView.text = ""
//                textView.textColor = .black
//                textView.theme_textColor = "Global.textColor"
//                textView.theme_tintColor = "Global.textColor"
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == todoItemTextView {
            guard let data = todoItemSettingsData as TodoItemSettingsData? else {
                fatalError("todoItemSettingsData should be set by now")
            }
            
            guard data.setTodoText(to: textView.text) else {
                fatalError("should always be true")
            }
            
            if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
                textView.text = data.getTodoPlaceholderText()
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
            guard let data = todoItemSettingsData as TodoItemSettingsData? else {
                fatalError("todoItemSettingsData should be set by now")
            }
            guard data.setTodoText(to: textView.text) else {
                fatalError("should always be true")
            }
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
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("should definitely exist already")
        }
        
        if cell == tagsCell {
            let tagsText: String?
            
            if let result = data.holdingAnyTags() as Bool?, result {
                tagsText = data.getTagsLabels().joined(separator: " ")
            } else {
                tagsText = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
            }
            
            cell.detailTextLabel?.text = tagsText
        }
        
        if cell == listsCell {
            let listLabel = data.getListLabel()
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
            if !data.isNewTodo() {
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
    
    // MARK: Datepickertapped
    func datePickerTappedForDuedateAtDateCell() {
        let datePicker = DatePickerDialog()
        
        let setDueDateTitle = NSLocalizedString("Set Due Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set Due Date ***", comment: "")
        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        datePicker.show(setDueDateTitle,
                        doneButtonTitle: setString,
                        cancelButtonTitle: cancelString,
                        defaultDate: Date().endTime()) { (date) in
                            if let dt = date {
                                guard let data = self.todoItemSettingsData as TodoItemSettingsData? else {
                                    fatalError("should be set by now")
                                }
                                guard data.setTodoDueDate(at: dt) else {
                                    fatalError("should be always true")
                                }
                                self.duedateAtDateCell.detailTextLabel?.text = self.dateFormatter?.string(from: dt)
                                self.tableView.reloadData()
                            }
        }
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = todoItemSettingsData?.getTodoText() ?? ""
        let isEmptyField = text.trimmingCharacters(in: .whitespaces).isEmpty
        saveTodoitemButton.isEnabled = !isEmptyField
    }
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        let _title = NSLocalizedString("Settings", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Settings **", comment: "")
    //        setupTitleView(withString: _title)
    //    }
    
    //    private func setupTitleView(withString string: String) {
    //        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
    //        let _title:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrs)
    //
    //        let size = _title.size()
    //
    //        let width = size.width
    //        guard let height = navigationController?.navigationBar.frame.size.height else {return}
    //
    //        let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    //        titleLabel.attributedText = _title
    //        titleLabel.numberOfLines = 0
    //        titleLabel.textAlignment = .center
    //        titleLabel.theme_backgroundColor = "Global.barTintColor"
    //        titleLabel.theme_textColor = "Global.textColor"
    //
    //        navigationItem.titleView = titleLabel
    //    }
    
    fileprivate func performTodoItemSetup() {
        if todoItem != nil {
            // handle already created to do Item
            todoItemSettingsData = TodoItemSettingsData.init(for: todoItem!, in: tableView)
        } else {
            guard let _moc = container?.viewContext as NSManagedObjectContext? else {
                fatalError("this should not happen")
            }
            
            self.moc = _moc
            todoItemSettingsData = TodoItemSettingsData.init(for: nil, in: tableView)
        }
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("todoItemSettingsData should be set by now")
        }
        
        if !data.isNewTodo() {
            // handle already created to do Item
            todoItemTextView.text = data.getTodoText()
            let _title = "Details"
            //            setupTitleView(withString:
            setupNavigationTitleText(title: _title)
            
        } else {
            // a new to do
            let _title = "Add a to do"
            setupNavigationTitleText(title: _title)
            
            todoItemTextView.text = data.getTodoPlaceholderText()
            //            todoItemTextView.textColor = .gray
            //            todoItemTextView.textColor = UIColor.lightText
            todoItemTextView.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
            saveTodoitemButton.isEnabled = false
//            showCompletedCell = false
        }
        
        if let duedateAtDate = todoItemSettingsData?.getTodoDuedateAt() {
            duedateAtDateCell?.detailTextLabel?.text = dateFormatter?.string(from: duedateAtDate)
        } else {
            duedateAtDateCell?.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
        }
        
        let tagsText: String?
        
        if data.holdingAnyTags() {
            tagsText = NSLocalizedString("view tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND view tags **", comment: "")
        } else {
            tagsText = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
        }
        
        tagsCell.detailTextLabel?.text = tagsText
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
        //
        //        let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
        //
        let defaults = UserDefaults.standard
        let showDoneAlert = defaults.bool(forKey: "todo.showOnDeleteAlert")
        //
        if showDoneAlert {
            let alertController = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: deleteAlertConfirmation, style: .destructive, handler: { [unowned self] _ in
                guard let data = self.todoItemSettingsData else { fatalError("could not find TodoItemSettingsData") }
                guard data.destroy() else { fatalError("could not delete") }
//                self.dismiss(animated: true, completion: nil)
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
            guard let data = self.todoItemSettingsData else { fatalError("could not find TodoItemSettingsData") }
            guard data.destroy() else { fatalError("could not delete") }
            self.dismiss(animated: true, completion: nil)
            self.closeView()
        }
    }
}
