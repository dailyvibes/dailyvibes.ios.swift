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
import Notepad

class NotesViewController: UIViewController, UITextViewDelegate {
    
    let store = CoreDataManager.store
    var editingTodoitemTask: DVTodoItemTaskViewModel?
    
    var delegate: NotesViewControllerUpdaterDelegate?
    
    //    @IBOutlet private weak var markdownTextEditor: Notepad!
    private var noteTitle: String?
    private var noteText: String?
    private var todoItemSettingsData: TodoItemSettingsData?
    
    private weak var textViewToolbar: UIToolbar!
//    private weak var textView: Notepad!
    //    private weak var notepad: Notepad!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        editingTodoitemTask = store.editingDVTodotaskItem
        let textView = Notepad(frame: view.bounds, themeFile: "one-dark")
        
        if let _ = store.editingDVTodotaskItem?.note {
            noteText = store.editingDVTodotaskItem?.note?.content ?? ""
            textView.text = noteText
        }
        
        let numberToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.theme_barStyle = "Global.toolbarStyle"
        numberToolbar.theme_tintColor = "Global.barTextColor"
        
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideToolbarHandler))
        ]
        
        numberToolbar.sizeToFit()
        textViewToolbar = numberToolbar
        textView.inputAccessoryView = textViewToolbar
        
        textView.textContainerInset = UIEdgeInsetsMake(40, 20, 40, 20)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.becomeFirstResponder()
        textView.delegate = self
        
        self.view.addSubview(textView)
    }
    
    @objc private func hideToolbarHandler() {
        //        if var note = self.store.editingDVTodotaskItem?.note {
        //            note.content = self.noteText
        //        } else {
        //            var newNote = DVNoteViewModel.makeEmpty()
        //            newNote.content = self.noteText
        //            self.store.editingDVTodotaskItem?.note = newNote
        //        }
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleShareButton))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func handleShareButton() {
        //        let noteText = editingTodoitemTask?.note?.content ?? ""
        let noteText = self.noteText ?? ""
        //        let todoitemtaskText = editingTodoitemTask?.todoItemText ?? ""
        
        let pasteBoardText = "\(noteText)"
        
        UIPasteboard.general.string = pasteBoardText
        
        let copiedText = NSLocalizedString("Copied to clipboard", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Copied to clipboard **", comment: "")
        let alert = UIAlertController(title: "", message: copiedText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setup(title noteTitle:String, textContent note:String, for data: TodoItemSettingsData) {
        //        self.noteTitle = noteTitle
        //        self.noteText = note
        //        self.todoItemSettingsData = data
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.noteText = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.store.editingDVTodotaskItem?.note != nil {
            self.store.editingDVTodotaskItem?.note?.content = textView.text
        } else {
            var newNote = DVNoteViewModel.makeEmpty()
            newNote.content = textView.text
            self.store.editingDVTodotaskItem?.note = newNote
            //            editingTodoitemTask?.note = newNote
        }
        
        delegate?.updateTableView()
        
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
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

protocol NotesViewControllerUpdaterDelegate: class {
    func updateTableView()
}
