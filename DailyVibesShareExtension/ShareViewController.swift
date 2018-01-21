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
    private var tags = [Tag]()
    private var tag = Tag()
    
    override func loadView() {
        super.loadView()
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
        store.fetchTags()
        tags = store.fetchedTags
        let defaultShareSetting = "unsorted"
        tag = store.fetchSpecificTag(byLabel: defaultShareSetting) ?? store.storeTag(withLabel: defaultShareSetting)
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
        let dueDate = Date().endTime()
        
        
        if let string = urlString {
            store.storeTodoItemTaskTag(withTitle: "\(text) - \(string)", forDueDate: dueDate, for: tag)
        } else {
            store.storeTodoItemTaskTag(withTitle: text, forDueDate: dueDate, for: tag)
        }
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        let item = SLComposeSheetConfigurationItem.init()
        item?.title = "Tag"
        item?.value = tag.label
        
        return [item!]
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
