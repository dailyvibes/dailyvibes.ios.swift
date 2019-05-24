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
import SwiftTheme

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
    }
    
    @objc private func hideToolbarHandler() {
        //        if var note = self.store.editingDVTodotaskItem?.note {
        //            note.content = self.noteText
        //        } else {
        //            var newNote = DVNoteViewModel.makeEmpty()
        //            newNote.content = self.noteText
        //            self.store.editingDVTodotaskItem?.note = newNote
        //        }
        let btnfeedback = UIImpactFeedbackGenerator()
        btnfeedback.impactOccurred()
        
        self.view.endEditing(true)
    }
    
    lazy var scrnRect : CGRect = {
        return UIScreen.main.bounds
    }()
    
    private var isPlaceholderTextShown = true
    
    lazy var sampleplaceholdertext : String = {
//        let txt = """
//
//            # Add Notes
//
//            ## Optionally use Markdown
//
//            You can even write `code`
//
//            > Your *time* is **limited**, don’t waste it living someone else’s life.
//            > Don’t be trapped by dogma, which is living the result of other
//            > people’s thinking. Don’t let the noise of other opinions drown
//            > your own inner voice. And most important, have the courage to
//            > follow your heart and intuition, they somehow already know what
//            > you truly want to become. Everything else is secondary.
//
//            [Steve Jobs](https://apple.com)
//            """
        
        let txt = """

            # Add Notes

            ## Optionally use Markdown
            
            Use **Markdown** to create beautiful *notes*.
            
            Write code : ` let str = "Hello World" `

            Jot down quotes like this and [reference them](https://dailyvibes.ca):

            > Here is an important quote

            * Quickly make lists
            - Breakdown large ideas
            + Reduce stress by writing things down

            [ ] create a sample demo list
            [X] show a completed task
            """
        
        return txt
    }()
    
    lazy var noteEditor : UITextView = {
        let screenRect = scrnRect
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
//        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
        
        let numberToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.theme_barStyle = "Global.toolbarStyle"
        numberToolbar.theme_tintColor = "Global.barTextColor"
//        numberToolbar.backgroundColor = .gray
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCloseBtn))
        closeButton.accessibilityIdentifier = "dv.notesentry.close.btn"
        
        let clearBtn = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleClearBtn))
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveBtn))
        
        
        let kbdwnimage = #imageLiteral(resourceName: "dvKeyboardDownIcon001")
        let kbdwnbtn = UIBarButtonItem(image: kbdwnimage, style: .plain, target: self, action: #selector(hideToolbarHandler))
        
        numberToolbar.items = [
            closeButton,
            clearBtn,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            saveBtn,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            kbdwnbtn
//            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideToolbarHandler))
        ]
        
        numberToolbar.sizeToFit()
        textViewToolbar = numberToolbar
        
        let containerSize = CGSize(width: self.view.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        
        let storage = Storage()
        let theme = Theme("one-dark")
        storage.theme = theme
        storage.addLayoutManager(layoutManager)
        
        let editor = UITextView(frame: self.view.bounds, textContainer: container)
        editor.backgroundColor = theme.backgroundColor
        editor.tintColor = theme.tintColor
        editor.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        editor.textContainerInset = UIEdgeInsets(top: 40, left: 20, bottom: 50, right: 20)
//        editor.becomeFirstResponder()
        editor.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        editor.delegate = self
        
        editor.inputAccessoryView = textViewToolbar
        
        if let _ = store.editingDVTodotaskItem?.note {
            noteText = store.editingDVTodotaskItem?.note?.content ?? ""
            editor.text = noteText
            isPlaceholderTextShown = false
        } else {
            editor.text = sampleplaceholdertext
        }
        
        return editor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.theme_setStatusBarStyle(ThemeStatusBarStylePicker.init(styles: .lightContent), animated: true)
        
//        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
        
//        let textView = Notepad(frame: self.view.bounds, themeFile: "one-dark")
        
//        if let _ = store.editingDVTodotaskItem?.note {
//            noteText = store.editingDVTodotaskItem?.note?.content ?? ""
//            textView.text = noteText
//        }
        
        
//        textView.inputAccessoryView = textViewToolbar
//
//        textView.textContainerInset = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
//        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        textView.becomeFirstResponder()
//        textView.delegate = self
        
//        self.view.addSubview(textView)
        
//        navigationItem.leftBarButtonItem = closeButton
        
//        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(handleShareButton))
//        navigationItem.rightBarButtonItem = shareButton
        
        
//        let screenRect = scrnRect
//        let screenWidth = screenRect.size.width
//        let screenHeight = screenRect.size.height
//        
//        self.preferredContentSize = CGSize(width: (screenWidth - 32), height: (screenHeight/2))
        self.view.addSubview(noteEditor)
        
        registerForKeyboardNotifications()
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        
        if !noteEditor.isFirstResponder {
            noteEditor.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.theme_setStatusBarStyle("UIStatusBarStyle", animated: true)
        super.viewWillDisappear(animated)
    }
    
    @objc
    func handleClearBtn() {
        noteText = ""
        noteEditor.text = ""
    }
    
    @objc
    func handleCloseBtn() {
        if noteEditor.isFirstResponder {
            noteEditor.resignFirstResponder()
        }
        dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func handleSaveBtn() {
        if self.store.editingDVTodotaskItem?.note != nil {
            self.store.editingDVTodotaskItem?.note?.content = noteEditor.text
        } else {
            var newNote = DVNoteViewModel.makeEmpty()
            newNote.content = noteEditor.text
            self.store.editingDVTodotaskItem?.note = newNote
        }
        
        delegate?.updateTableView()
        handleCloseBtn()
        
//        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
//            textView.text = ""
//            textView.theme_tintColor = "Global.textColor"
//            textView.theme_textColor = "Global.textColor"
//        }
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
//        if self.store.editingDVTodotaskItem?.note != nil {
//            self.store.editingDVTodotaskItem?.note?.content = textView.text
//        } else {
//            var newNote = DVNoteViewModel.makeEmpty()
//            newNote.content = textView.text
//            self.store.editingDVTodotaskItem?.note = newNote
//            //            editingTodoitemTask?.note = newNote
//        }
//
//        delegate?.updateTableView()
//
//        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
//            textView.text = ""
//            textView.theme_tintColor = "Global.textColor"
//            textView.theme_textColor = "Global.textColor"
//        }
        
        if textView.isFirstResponder {
            textView.resignFirstResponder()
//            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: Keyboard Handling Methods
    private func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
//        print("keyboard will show")
        if isPlaceholderTextShown {
            isPlaceholderTextShown = false
//            noteText = ""
//            noteEditor.text = ""
        }
        adjustingHeight(showing: true, notification: notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        print("keyboard will hide")
        adjustingHeight(showing: false, notification: notification)
    }
    
    private func adjustingHeight(showing: Bool, notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }
        
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
        
        let changeInHeight = keyboardSize.height * (showing ? 1 : -1)
        
        var viewingrect = self.view.bounds
        viewingrect.size.height -= changeInHeight
        
        let newinsets = UIEdgeInsets(top: 20, left: 20, bottom: changeInHeight, right: 20)
        
//        if viewingrect.contains(noteEditor.frame.origin) {
//            print("viewing rect contains noteeditor")
//        }
        
        UIView.animate(withDuration: animationDuration,
                       delay: 300,
                       options: UIView.AnimationOptions(rawValue: curve),
                       animations: {
//                        self.loginButtonBottomConstraint.constant += changeInHeight / 1.5
//                        self.labelTopConstraint.constant -= changeInHeight
                        
//                        self.textvi
//                        print("doing animation")
                        if showing {
                            self.noteEditor.textContainerInset = newinsets
                            
//                            let bottom = self.noteEditor.contentSize.height - self.noteEditor.bounds.size.height
//                            self.noteEditor.setContentOffset(CGPoint(x: 0, y: changeInHeight), animated: true)
                        } else {
                            self.noteEditor.textContainerInset = UIEdgeInsets(top: 40, left: 20, bottom: 50, right: 20)
                        }
//                        self.noteEditor.scrollRectToVisible(, animated: <#T##Bool#>)
        },
                       completion: nil)
    }
}

protocol NotesViewControllerUpdaterDelegate: class {
    func updateTableView()
}
