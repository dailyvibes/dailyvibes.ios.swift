//
//  AcknowledgementSettingsViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-08.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit
import Down

class AcknowledgementSettingsViewController: ThemableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        let titleString = "Acknowledgement"
        setupNavigationTitleText(title: titleString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = UITextView(frame: self.view.bounds)
        
        let down = Down(markdownString: testMarkdownFileContent())
        
        guard let html = try? down.toHTML() else {
            fatalError("oops")
        }
        
        let defaultStylesheet = "* {font-family: '-apple-system', 'HelveticaNeue'; font-size:\(UIFont.buttonFontSize) } code, pre { font-family: Menlo }"
        
        let htmlString = "<style>" + defaultStylesheet + "</style>" + html
        guard let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue) else { fatalError("htmlData conversion failed") }
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
            NSAttributedString.DocumentType.html]
        let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
        
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false
        
        self.view.addSubview(textView)
    }
    
    public func testMarkdownFileContent() -> String {
        if let templateURL = Bundle.main.url(forResource: "acknowledgement", withExtension: "md") {
            do {
                return try String(contentsOf: templateURL, encoding: String.Encoding.utf8)
            } catch {
                return ""
            }
        }
        return ""
    }
}

extension AcknowledgementSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }
}
