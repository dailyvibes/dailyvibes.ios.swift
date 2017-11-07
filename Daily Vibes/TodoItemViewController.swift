//
//  ViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-03.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import os.log

class TodoItemViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
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
    
    var statusPickerVisible: Bool = false
    
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
        
        if let todoItem = todoItem {
            todoItemTextField.text = todoItem.todoItemText
            todoItemTagsTextField.text = todoItem.tags?.joined(separator: " ")
            navigationItem.title = "Editing \(todoItem.todoItemText)"
            if todoItem.completed {
                wasCompletedSwitch.isOn = true
                self.plannedDateLabel.text = todoItem.completedAt?.description
                statusPicker.isEnabled = false
            }
            plannedDateLabel.text = todoItem.completedAt?.description ?? "Date"
        }
        
        updateSaveButtonState()
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
        
        let todoText = todoItemTextField.text ?? ""
        let todoTags = todoItemTagsTextField.text ?? ""
        
        if let todoItem = todoItem {
            os_log("todoItem exists, doin nothing", log: OSLog.default, type: .debug)
        } else {
            os_log("new todoItem, creating", log: OSLog.default, type: .debug)
            todoItem = TodoItem(todoItemText: todoText, tags: [todoTags])
        }
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = todoItemTextField.text ?? ""
        saveTodoitemButton.isEnabled = !text.isEmpty
    }

}

