//
//  NotesViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-13.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//
//import Foundation
//import CoreData
import UIKit

class NotesViewController: UIViewController, UITextViewDelegate {
    
    var delegate: NotesViewControllerUpdaterDelegate?
    
    @IBOutlet private weak var markdownTextEditor: ThemableBaseTextView!
    private var noteTitle: String?
    private var noteText: String?
    private var todoItemSettingsData: TodoItemSettingsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let note = noteText {
//            markdownTextEditor.text = note
            markdownTextEditor.setAttributed(text: note)
        }
        self.markdownTextEditor.becomeFirstResponder()
        self.markdownTextEditor.delegate = self
    }
    
    func setup(title noteTitle:String, textContent note:String, for data: TodoItemSettingsData) {
        self.noteTitle = noteTitle
        self.noteText = note
        self.todoItemSettingsData = data
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
//        guard let data = todoItemSettingsData else {
//            fatalError("todoItemSettingsData should be init by now")
//        }
        if textView == markdownTextEditor {
            if !textView.isFirstResponder {
                textView.becomeFirstResponder()
            }
            
//            saveTodoitemButton.isEnabled = false
            
//            if textView.text == data.getTodoPlaceholderText() {
//                textView.text = ""
//                //                textView.textColor = .black
////                textView.theme_textColor = "Global.textColor"
////                textView.theme_tintColor = "Global.textColor"
//            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == markdownTextEditor {
            guard let data = todoItemSettingsData as TodoItemSettingsData? else {
                fatalError("todoItemSettingsData should be set by now")
            }
            
            self.noteText = textView.text
            
            guard data.setTodoNoteText(title: self.noteTitle, content: self.noteText) else {
                fatalError("should always be true")
            }
            
            delegate?.updateTableView()
            
            if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
//                textView.text = data.getTodoPlaceholderText()
                textView.text = ""
                textView.theme_tintColor = "Global.textColor"
                textView.theme_textColor = "Global.textColor"
            }
            
            if textView.isFirstResponder {
                textView.resignFirstResponder()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

protocol NotesViewControllerUpdaterDelegate: class {
    func updateTableView()
}
