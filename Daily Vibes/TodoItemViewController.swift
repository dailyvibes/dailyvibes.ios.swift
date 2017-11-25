//
//  ViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
//import os.log
import CoreData
//import WSTagsField

class TodoItemViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Properties
    var todoItem: TodoItem?
    
    private var expandingCellHeight: CGFloat = 200
    private let expandingIndexRow = 5
    
    // MARK: Outlets
    @IBOutlet weak var todoItemTextFieldCell: NewTodoItemTableViewCell!
    @IBOutlet weak var tagsCell: UITableViewCell!
    
    @IBOutlet weak var todoItemTextView: UITextView!
    @IBOutlet weak var yellowBtn: UIButton!
    @IBOutlet weak var orangeBtn: UIButton!
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var greenBtn: UIButton!
    @IBOutlet weak var blueBtn: UIButton!
    @IBOutlet weak var purpleBtn: UIButton!
    @IBOutlet weak var saveTodoitemButton: UIBarButtonItem!
    @IBOutlet weak var wasCompletedSwitch: UISwitch! = UISwitch()
    
    @IBOutlet weak var statusPicker: UIDatePicker!
    
    @IBOutlet weak var emotionPicker: UIPickerView!
    @IBOutlet weak var currentEmotionLabel: UILabel!
    @IBOutlet weak var emotionPickerCell: UITableViewCell!
    @IBOutlet weak var emotionPickerLabelCell: UITableViewCell!
    
    private var statusPickerVisible: Bool = false
    
    private var editingEmotionPicker: Bool = false
    private var editingCompletionDate: Bool = false
    private var dateFormatter: DateFormatter?
    private var showCompletedCell: Bool = false
    
    @IBOutlet weak var completionDateLabelCell: UITableViewCell!
    
    private let emotionsList = [
        ["Love", UIColor.red],
        ["Happy", UIColor.orange],
        ["Excited", UIColor.yellow],
        ["Fear", UIColor.green],
        ["Sad", UIColor.blue],
        ["Angry", UIColor.purple]
    ]
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var moc: NSManagedObjectContext?

    override func viewDidLoad() {
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
        
        if todoItem != nil {
            todoItemTextView.text = todoItem!.todoItemText
            
            var tagsText = String()
            
            if let tagsCount = todoItem?.tagz?.count, tagsCount > 0 {
//                let tags = todoItem?.tagz?.allObjects as! [Tag]
//
//                for tag in tags {
//                    tagsText += tag.label!
//                    print("~~~~~~~~~~ tag label = \(tag.label!)")
//                }
                tagsText = "view tags"
            } else {
                tagsText = "new tag"
            }
            
            tagsCell.detailTextLabel?.tintColor = .black
            tagsCell.detailTextLabel?.text = tagsText
            
            print("tagText = \(tagsText)")
            
            if !(todoItem!.isNew) {
                // not new todo
                navigationItem.title = "Details"
                showCompletedCell = true
            } else {
                // a new todoItem
                todoItemTextView.becomeFirstResponder()
                wasCompletedSwitch.isEnabled = false
                saveTodoitemButton.isEnabled = false
                showCompletedCell = false
            }
            if todoItem!.completed {
                wasCompletedSwitch.isOn = true
                emotionPickerLabelCell?.detailTextLabel?.text = todoItem?.completedAtEmotion
                if let completedEmotion = todoItem?.completedAtEmotion {
                    statusPicker.isEnabled = false
                    emotionPicker.isUserInteractionEnabled = false
                    emotionPickerLabelCell?.detailTextLabel?.text = completedEmotion
                }
            }
            
            var strDate: String? = nil
            
            if let date = todoItem?.completedAt {
                strDate = dateFormatter?.string(from: date)
            }
            
            completionDateLabelCell?.detailTextLabel?.text = strDate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func completedAtChanged(_ sender: UIDatePicker) {
        if let todoItem = todoItem {
            todoItem.completedAt = sender.date
            completionDateLabelCell?.detailTextLabel?.text = dateFormatter?.string(from: sender.date)
            tableView.reloadData()
        }
    }
    
    @IBAction func setMarkCompleted(_ sender: UISwitch) {
        if let todoItem = todoItem {
        if sender.isOn {
            todoItem.markCompleted()
            todoItem.completedAtEmotion = emotionPickerLabelCell?.detailTextLabel?.text
        } else {
            sender.isOn = true
            }
        } else {
            sender.isOn = false
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInADDMode = presentingViewController is UINavigationController
        
        if (todoItem?.isNew)! {
            // the item was saved because we called save context on the new tag
            // so we have to remove it... delete it now
            // have to fetch the todos
            // remove this particular todo from that list
            removefromTodos(this: todoItem, in: moc)
            // a better way to approach this is:
            // create a structure for the new to do screen
            // have two properties on this structure
            // todo property
            // tags to attach property
            // if todo has tags -> populate this property with these tags
            // manipulate those tags there
            // on save or cancel either add the tags or not
            // this way the tags get auto created/ attached but the todo does not
            // unless the person clicks save
        } else {
            moc?.rollback()
        }
        
        if isPresentingInADDMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The TodoItemViewwController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "saveButtonSegue":
            todoItem?.updatedAt = Date()
            
            do {
                todoItem?.isNew = false
                try moc!.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        case "newTagSegue":
            //todo process new todos
            // get the vc for the segue destination
            guard let tagsTVC = segue.destination as? TagsTableViewController else {
                fatalError("wasn't a TagsTableViewController segue")
            }
            // setup the todo so that tags know what to work with
            tagsTVC.configure(task: todoItem!, managedObjectContext: moc!)
        default:
            fatalError("Should not be here")
        }
        
//        let button = sender
//        
//        if button as! UIBarButtonItem === saveTodoitemButton {
//            todoItem?.updatedAt = Date()
//            
//            do {
//                todoItem?.isNew = false
//                try moc!.save()
//            } catch {
//                fatalError("Failure to save context: \(error)")
//            }
//        }
        
//        guard let button = sender as? UIBarButtonItem, button === saveTodoitemButton else {
//            fatalError("save button was not pressed, cancelling")
//        }
//
//        todoItem?.updatedAt = Date()
//
//        do {
//            todoItem?.isNew = false
//            try moc!.save()
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
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
        saveTodoitemButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == todoItemTextView {
            todoItem?.todoItemText = textView.text
            updateSaveButtonState()
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
            todoItem?.todoItemText = textView.text
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
//        currentEmotionLabel!.text = emotionsList[row][0] as? String
//        emotionPickerCell.detailTextLabel?.text = emotionsList[row][0] as? String
        emotionPickerLabelCell.detailTextLabel?.text = emotionsList[row][0] as? String
        if todoItem!.isNew {
            todoItem?.createdAtEmotion = emotionsList[row][0] as? String
        } else {
            if todoItem!.completed {
                todoItem?.completedAtEmotion = emotionsList[row][0] as? String
            } else {
                todoItem?.updatedAtEmotion = emotionsList[row][0] as? String
            }
        }
        tableView.reloadData()
    }
    
    //MARK: visual view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
//            let hue = CGFloat(row)/CGFloat(emotionsList.count)
//            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
//            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            pickerLabel?.backgroundColor = emotionsList[row][1] as? UIColor
        }
        let titleData = emotionsList[row][0] as! String
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        return pickerLabel!
    }
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return emotionsList.count
//    }
//
//    //MARK: Delegates
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return emotionsList[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        //myLabel.text = emotionsList[row]
//    }
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = todoItemTextView.text ?? ""
        saveTodoitemButton.isEnabled = !text.isEmpty
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return showCompletedCell ? nil : super.tableView(tableView, titleForFooterInSection: section)
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return showCompletedCell ? 0 : UITableViewAutomaticDimension
//    }
    
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
    
    private func removefromTodos(this todo: TodoItem!, in managedObjectcontext: NSManagedObjectContext!) {
        managedObjectcontext.delete(todo)
        do {
            try managedObjectcontext.save()
        } catch {
            managedObjectcontext.rollback()
            fatalError("removefromTodos failed")
        }
    }
    
}
