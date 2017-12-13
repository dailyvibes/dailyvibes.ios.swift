//
//  ViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import CoreData

class TodoItemViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    private var todoItem: TodoItem?
    private var todoItemSettingsData: TodoItemSettingsData?
    
    private var expandingCellHeight: CGFloat = 200
    private let expandingIndexRow = 5
    
    // MARK: Outlets
    @IBOutlet private weak var todoItemTextFieldCell: NewTodoItemTableViewCell!
    @IBOutlet private weak var tagsCell: UITableViewCell!
    @IBOutlet private weak var doneCellLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet private weak var todoItemTextView: UITextView!
    @IBOutlet private weak var yellowBtn: UIButton!
    @IBOutlet private weak var orangeBtn: UIButton!
    @IBOutlet private weak var redBtn: UIButton!
    @IBOutlet private weak var greenBtn: UIButton!
    @IBOutlet private weak var blueBtn: UIButton!
    @IBOutlet private weak var purpleBtn: UIButton!
    @IBOutlet private weak var saveTodoitemButton: UIBarButtonItem!
    @IBOutlet private weak var wasCompletedSwitch: UISwitch! = UISwitch()
    
    @IBOutlet private weak var statusPicker: UIDatePicker!
    
    @IBOutlet private weak var emotionPicker: UIPickerView!
    @IBOutlet private weak var currentEmotionLabel: UILabel!
    @IBOutlet private weak var emotionPickerCell: UITableViewCell!
    @IBOutlet private weak var emotionPickerLabelCell: UITableViewCell!
    
    private var statusPickerVisible: Bool = false
    
    private var editingEmotionPicker: Bool = false
    private var editingCompletionDate: Bool = false
    private var dateFormatter: DateFormatter?
    private var showCompletedCell: Bool = false
    
    @IBOutlet private weak var completionDateLabelCell: UITableViewCell!
    
    private let emotionsList = [
        ["Love", UIColor.red],
        ["Happy", UIColor.orange],
        ["Excited", UIColor.yellow],
        ["Fear", UIColor.green],
        ["Sad", UIColor.blue],
        ["Angry", UIColor.purple]
    ]
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private var moc: NSManagedObjectContext?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagsCell.textLabel?.text = NSLocalizedString("Tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tags **", comment: "")
        doneCellLabel?.text = NSLocalizedString("Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done **", comment: "")
        completionDateLabelCell.textLabel?.text = NSLocalizedString("Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Date **", comment: "")
        emotionPickerLabelCell.textLabel?.text = NSLocalizedString("How do you feel?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND How do you feel? **", comment: "")
    }
    
    override func viewDidLoad() {
        // good place to init and setup objects used in viewController
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Handle the text field’s user input through delegate callbacks.
        todoItemTextView.delegate = self
        
        // Handle emotion picker
        emotionPicker.delegate = self
        emotionPicker.dataSource = self
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = DateFormatter.Style.short
        dateFormatter?.timeStyle = DateFormatter.Style.short
        
//        print("about to call performTodoItemSetup")
        performTodoItemSetup()
        updateSaveButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
//            fatalError("todoItemSettingsData should be set by now")
//        }
        
//        if data.isNewTodo() {
//            todoItemTextView.becomeFirstResponder()
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        performTodoItemSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(toProcess todoItem: TodoItem?, inContext context: NSManagedObjectContext?) {
//        self.moc = context
        self.moc = container?.viewContext
        self.todoItem = todoItem
    }
    
    // MARK: Actions
    @IBAction func completedAtChanged(_ sender: UIDatePicker) {
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("should be set by now")
        }
        guard data.setTodoCompleted(at: sender.date) else {
            fatalError("should be always true")
        }
        completionDateLabelCell?.detailTextLabel?.text = dateFormatter?.string(from: sender.date)
        tableView.reloadData()
    }
    
    @IBAction func setMarkCompleted(_ sender: UISwitch) {
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("should be set by now")
        }
        
        if sender.isOn && !data.wasCompleted() {
            // TODO: Remove this duplication
            
            let doneAlertTitle = NSLocalizedString("Mark this task as done?", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Mark this task as done? ***", comment: "")
            let doneAlertMessage = NSLocalizedString("This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over.", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND This action cannot be undone. Once you complete a task, you cannot undo it. Your remaining option would be to delete and start over. ***", comment: "")
            let doneAlertConfirmation = NSLocalizedString("Yes, Mark this as Done", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Yes, Mark this as Done ***", comment: "")
            let doneAlertCancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
            
            let alert = UIAlertController(title: doneAlertTitle, message: doneAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: doneAlertConfirmation, style: .destructive, handler: { _ in
                guard data.markCompleted(with: self.emotionPickerLabelCell?.detailTextLabel?.text) else {
                    fatalError("should return always true")
                }
            }))
            alert.addAction(UIAlertAction(title: doneAlertCancel, style: .default, handler: { _ in
                sender.isOn = false
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            sender.isOn = true
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
//        let isPresentingInADDMode = presentingViewController is UINavigationController
        let isPresentingInADDMode = presentingViewController is DailyVibesTabBarViewController
        
//        print("var presentingViewController: \(presentingViewController)")
        
        guard let data = todoItemSettingsData else {
            fatalError("todoItemSettingsData should be set by now")
        }
        
        guard data.processCancel(in: moc!) else {
            fatalError("cancel should have been processed")
        }
        
        if isPresentingInADDMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The TodoItemViewController is not inside a navigation controller.")
        }
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
            if !textView.isFirstResponder {
                textView.becomeFirstResponder()
            }
            
            saveTodoitemButton.isEnabled = false
            
            if textView.text == data.getTodoPlaceholderText() {
                textView.text = ""
                textView.textColor = .black
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
                textView.textColor = .lightGray
            }
            
            updateSaveButtonState()
            
            if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // stop keyboard and close it
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
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let result = emotionsList[row][0] as? String else {
            fatalError("Expected a string, did not get a string =(")
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let emotionSelection = emotionsList[row][0] as? String
        emotionPickerLabelCell.detailTextLabel?.text = emotionSelection
        
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("should be set by now")
        }
        
        if data.isNewTodo() {
            guard data.setCreatedAt(emotion: emotionSelection) else {
                fatalError("should always be true")
            }
        } else {
            if data.wasCompleted() {
                guard data.setCompletedAt(emotion: emotionSelection) else {
                    fatalError("should be always true")
                }
            } else {
                guard data.setUpdatedAt(emotion: emotionSelection) else {
                    fatalError("should be always true")
                }
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: visual view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = emotionsList[row][1] as? UIColor
        }
        let titleData = emotionsList[row][0] as! String
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        return pickerLabel!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let data = todoItemSettingsData as TodoItemSettingsData? else {
            fatalError("should definitely exist already")
        }
        if data.tagsCellIndexPath(equals: indexPath) {
            let tagsText: String?
            
            if let result = data.holdingAnyTags() as Bool?, result {
                tagsText = NSLocalizedString("view tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND view tags **", comment: "")
            } else {
                tagsText = NSLocalizedString("new tag", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
            }
            
            cell.detailTextLabel?.tintColor = .black
            cell.detailTextLabel?.text = tagsText
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 0 && !showCompletedCell) {
            return 0
        }
        if (indexPath.section == 2 && indexPath.row == 1 && !editingEmotionPicker) {
            return 0
        } else if (indexPath.section == 2 && indexPath.row == 1 && editingEmotionPicker) {
            return 216.0
        } else if (indexPath.section == 3 && indexPath.row == 1 && !editingCompletionDate) {
            return 0
        } else if (indexPath.section == 3 && indexPath.row == 1 && editingCompletionDate) {
            return 216.0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false);
        
        let cell = tableView.cellForRow(at: indexPath)
        
        self.tableView.beginUpdates()
        if (cell == self.emotionPickerLabelCell) {
            editingEmotionPicker = !editingEmotionPicker
        }
        if editingEmotionPicker {
            emotionPickerLabelCell?.detailTextLabel?.textColor = UIColor.red
        } else {
            emotionPickerLabelCell?.detailTextLabel?.textColor = UIColor.black
        }
        if (cell == self.completionDateLabelCell) {
            editingCompletionDate = !editingCompletionDate
        }
        if editingCompletionDate {
            completionDateLabelCell.detailTextLabel?.textColor = UIColor.red
        } else {
            completionDateLabelCell.detailTextLabel?.textColor = UIColor.black
        }
        self.tableView.endUpdates()
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = todoItemSettingsData?.getTodoText() ?? ""
        let isEmptyField = text.trimmingCharacters(in: .whitespaces).isEmpty
        saveTodoitemButton.isEnabled = !isEmptyField
    }
    
    fileprivate func performTodoItemSetup() {
        if todoItem != nil {
            // handle already created to do Item
            print("~~~ todo exists ~~~")
            todoItemSettingsData = TodoItemSettingsData.init(for: todoItem!, in: tableView)
        } else {
            // TODO: fix problem with tags not working
            
            // a new to do which we need to create
            print("~~~ create a new todo ~~~~")
            
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
            navigationItem.title = NSLocalizedString("Details", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Details **", comment: "")
            showCompletedCell = true
            
            if data.wasCompleted() {
                wasCompletedSwitch.isOn = true
                statusPicker.isEnabled = false
                
                if let completedEmotion = data.getTodoCompletedEmotion() {
                    emotionPicker.isUserInteractionEnabled = false
                    emotionPickerLabelCell?.detailTextLabel?.text = completedEmotion
                }
            }
            
            var strDate: String? = nil
            
            if let date = data.getTodoCompletedAt() {
                strDate = dateFormatter?.string(from: date)
            }
            
            completionDateLabelCell?.detailTextLabel?.text = strDate
        } else {
            // a new to do
            navigationItem.title = NSLocalizedString("Add a to do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Add a to do **", comment: "")
            todoItemTextView.text = data.getTodoPlaceholderText()
            todoItemTextView.textColor = .gray
            wasCompletedSwitch.isEnabled = false
            saveTodoitemButton.isEnabled = false
            showCompletedCell = false
        }
        
        let tagsText: String?
        
        if data.holdingAnyTags() {
            tagsText = NSLocalizedString("view tags", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND view tags **", comment: "")
        } else {
            tagsText = NSLocalizedString("new tag", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND new tag **", comment: "")
        }
        
        tagsCell.detailTextLabel?.tintColor = .black
        tagsCell.detailTextLabel?.text = tagsText
    }
    
}
