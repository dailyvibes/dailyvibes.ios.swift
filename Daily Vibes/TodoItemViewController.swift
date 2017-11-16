//
//  ViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import os.log
import CoreData
import WSTagsField

class TodoItemViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Properties
    var todoItem: TodoItem?
    
    // MARK: Outlets
    @IBOutlet weak var plannedDateLabel: UILabel! // EDIT THIS ONE
    @IBOutlet weak var todoItemTextField: UITextField!
    @IBOutlet weak var todoItemTagsTextField: UITextField!
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
    
    var statusPickerVisible: Bool = false
    
    private var editingEmotionPicker: Bool = false
    private var editingCompletionDate: Bool = false
    private var dateFormatter: DateFormatter?
    
    @IBOutlet weak var completionDateLabelCell: UITableViewCell!
    
    
    let emotionsList = [
        ["Love", UIColor.red],
        ["Happy", UIColor.orange],
        ["Excited", UIColor.yellow],
        ["Fear", UIColor.green],
        ["Sad", UIColor.blue],
        ["Angry", UIColor.purple]
    ]
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var moc: NSManagedObjectContext?
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveTodoitemButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        updateSaveButtonState()
        if textField === todoItemTextField {
            todoItem?.todoItemText = textField.text
            updateSaveButtonState()
        }
        
        if textField === todoItemTagsTextField {
            todoItem?.tags = textField.text
            updateSaveButtonState()
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.statusPickerVisible = false
//        self.statusPicker.isHidden = true
////        self.statusPicker.translatesAutoresizingMaskIntoConstraints = false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Handle the text field’s user input through delegate callbacks.
        todoItemTextField.delegate = self
        todoItemTagsTextField.delegate = self
        
        // Handle emotion picker
        emotionPicker.delegate = self
        emotionPicker.dataSource = self
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = DateFormatter.Style.short
        dateFormatter?.timeStyle = DateFormatter.Style.short
        
        if todoItem != nil {
            todoItemTextField.text = todoItem!.todoItemText
//            todoItemTagsTextField.text = todoItem.tags?.joined(separator: " ")
            todoItemTagsTextField.text = todoItem!.tags
            if !(todoItem!.isNew) {
                navigationItem.title = "Details"
            } else {
                // a new todoItem
                // don't allow them to set the completed value on creation
                // don't allow them to save without filling out the data
                wasCompletedSwitch.isEnabled = false
                saveTodoitemButton.isEnabled = false
            }
            if todoItem!.completed {
                wasCompletedSwitch.isOn = true
                emotionPickerLabelCell?.detailTextLabel?.text = todoItem?.completedAtEmotion
//                plannedDateLabel.text = todoItem!.completedAt?.description
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
//            print("ON")
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
        
        moc?.rollback()
        
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
        
        guard let button = sender as? UIBarButtonItem, button === saveTodoitemButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        todoItem?.updatedAt = Date()
        
        do {
            todoItem?.isNew = false
            try moc!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
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
        let text = todoItemTextField.text ?? ""
        saveTodoitemButton.isEnabled = !text.isEmpty
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 2 && indexPath.row == 1 && !editingEmotionPicker) {
            return 0
        } else if (indexPath.section == 2 && indexPath.row == 1 && editingEmotionPicker) {
            return 216
        } else if (indexPath.section == 3 && indexPath.row == 1 && !editingCompletionDate) {
            return 0
        } else if (indexPath.section == 3 && indexPath.row == 1 && editingCompletionDate) {
            return 216
        } else {
            return 44
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
    
}
