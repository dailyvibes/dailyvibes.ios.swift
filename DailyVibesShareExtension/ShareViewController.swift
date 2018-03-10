//
//  ShareViewController.swift
//  DailyVibesShareExtension
//
//  Created by Alex Kluew on 2018-01-07.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

class ShareViewController: SLComposeServiceViewController {
    
    private var urlString: String?
    private var textString: String?
    
    private let store = CoreDataManager.store
//    private var tags = [Tag]()
//    private var tag = Tag()
    
    private var defaultTag: DVTagViewModel?
    private var defaultList: DVListViewModel?
    
    private var dvTagsVM = [DVTagViewModel]() {
        didSet {
            let defaultString = NSLocalizedString("from widget", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND from widget **", comment: "")
            
            for dvTagVm in dvTagsVM {
                if defaultString == dvTagVm.label {
                    defaultTag = dvTagVm
                }
            }
            
            if defaultTag == nil {
                defaultTag = store.createTag(withLabel: defaultString)
            }
        }
    }
    
    
    private var dvListsVM = [DVListViewModel]() {
        didSet {
            let defaultString = NSLocalizedString("Unsorted", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Unsorted **", comment: "")
            
            for dvListVM in dvListsVM {
                if let listTitle = dvListVM.title {
                    if listTitle == defaultString {
                        defaultList = dvListVM
                    }
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "launch_icon_dailyvibes"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        
        loadData()
        parseData()
    }
    
    private func parseData() {
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        let contentTypeText = kUTTypeText as String
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            if attachment.isURL {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    let url = results as! URL?
                    self.urlString = url!.absoluteString
                })
            }
            if attachment.isText {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
                    self.textString = text
                    _ = self.isContentValid()
                })
            }
        }
    }
    
    private func loadData() {
        store.fetchTagsViewModel()
        store.fetchListsViewModel()
        dvTagsVM = store.dvTagsVM
        dvListsVM = store.dvListsVM
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        if urlString != nil || textString != nil {
            if !contentText.isEmpty {
                return true
            }
        }
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        guard let text = textView.text else { return }
        
        store.findOrCreateTodoitemTaskDeepNested(withUUID: nil)
        
        if store.editingDVTodotaskItem != nil {
            store.editingDVTodotaskItem?.list = defaultList
            
            if let defaultTag = defaultTag {
                store.editingDVTodotaskItem?.tags?.append(defaultTag)
            }
            
            if let string = urlString {
                var newNote = DVNoteViewModel.makeEmpty()
                
                store.editingDVTodotaskItem?.todoItemText = text
                newNote.content = string
                store.editingDVTodotaskItem?.note = newNote
            } else {
                store.editingDVTodotaskItem?.todoItemText = text
            }
            
            store.saveEditingDVTodotaskItem()
        }
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        let tagItem = SLComposeSheetConfigurationItem.init()
        let projectItem = SLComposeSheetConfigurationItem.init()
        
        tagItem?.title = NSLocalizedString("Tag", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tag **", comment: "")
        tagItem?.value = defaultTag?.label
        
        projectItem?.title = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
        projectItem?.value = defaultList?.title
        
        return [tagItem!, projectItem!]
    }
    
}

extension NSItemProvider {
    
    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String)
    }
    
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeText as String)
    }
    
}
