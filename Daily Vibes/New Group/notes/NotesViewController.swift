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
    
//    private weak var markdownTextEditor: Notepad!
//    private weak var notepad: Notepad!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editingTodoitemTask = store.editingDVTodotaskItem
//        noteText = editingTodoitemTask?.note?.content ?? ""
//        markdownTextEditor.setAttributed(text: noteText!)
        let notepad = Notepad(frame: view.bounds, themeFile: "one-dark")
        
        if let note = editingTodoitemTask?.note, let contentText = note.content {
            notepad.text = contentText
        }
        
        notepad.textContainerInset = UIEdgeInsetsMake(40, 20, 40, 20)
        notepad.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        notepad.becomeFirstResponder()
        notepad.delegate = self
        self.view.addSubview(notepad)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleShareButton))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func handleShareButton() {
        let noteText = editingTodoitemTask?.note?.content ?? ""
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if var note = editingTodoitemTask?.note {
            note.content = textView.text
        } else {
            var newNote = DVNoteViewModel.makeEmpty()
            newNote.content = textView.text
            editingTodoitemTask?.note = newNote
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
