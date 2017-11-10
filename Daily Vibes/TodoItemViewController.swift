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

class TodoItemViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Properties
    var todoItem: TodoItem?
    
    // MARK: Outlets
    @IBOutlet weak var plannedDateLabel: UILabel!
    @IBOutlet weak var _todoItemTextField: UITextField!
    @IBOutlet weak var todoItemTextField: UITextField!
    @IBOutlet weak var _todoItemTagsTextField: UITextField!
    @IBOutlet weak var todoItemTagsTextField: UITextField!
    @IBOutlet weak var _yellowBtn: UIButton!
    @IBOutlet weak var yellowBtn: UIButton!
    @IBOutlet weak var _orangeBtn: UIButton!
    @IBOutlet weak var orangeBtn: UIButton!
    @IBOutlet weak var _redBtn: UIButton!
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var _greenBtn: UIButton!
    @IBOutlet weak var greenBtn: UIButton!
    @IBOutlet weak var _blueBtn: UIButton!
    @IBOutlet weak var blueBtn: UIButton!
    @IBOutlet weak var _purpleBtn: UIButton!
    @IBOutlet weak var purpleBtn: UIButton!
    @IBOutlet weak var _saveTodoitemButton: UIBarButtonItem!
    @IBOutlet weak var saveTodoitemButton: UIBarButtonItem!
    @IBOutlet weak var _wasCompletedSwitch: UISwitch!
    @IBOutlet weak var wasCompletedSwitch: UISwitch!
    @IBOutlet weak var statusPicker: UIDatePicker!
    
    @IBOutlet weak var emotionPicker: UIPickerView!
    @IBOutlet weak var currentEmotionLabel: UILabel!
    
    var statusPickerVisible: Bool = false
    
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
        
        // Handle the text field’s user input through delegate callbacks.
        todoItemTextField.delegate = self
        todoItemTagsTextField.delegate = self
        
        // Handle picker
        emotionPicker.delegate = self
        emotionPicker.dataSource = self
        
        if todoItem != nil {
            todoItemTextField.text = todoItem!.todoItemText
//            todoItemTagsTextField.text = todoItem.tags?.joined(separator: " ")
            todoItemTagsTextField.text = todoItem!.tags
            if !(todoItem!.isNew) {
                navigationItem.title = "Details"
            }
            if todoItem!.completed {
                wasCompletedSwitch.isOn = true
                plannedDateLabel.text = todoItem!.completedAt?.description
                statusPicker.isEnabled = false
            }
            plannedDateLabel.text = todoItem!.completedAt?.description ?? "Date"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func completedAtChanged(_ sender: UIDatePicker) {
        plannedDateLabel.text = sender.date.description
        if let todoItem = todoItem {
            todoItem.completedAt = sender.date
        }
    }
    
    @IBAction func setMarkCompleted(_ sender: UISwitch) {
        if let todoItem = todoItem {
        if sender.isOn {
            todoItem.markCompleted()
            print("ON")
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
        currentEmotionLabel.text = emotionsList[row][0] as! String
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
            pickerLabel?.backgroundColor = emotionsList[row][1] as! UIColor
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

}

