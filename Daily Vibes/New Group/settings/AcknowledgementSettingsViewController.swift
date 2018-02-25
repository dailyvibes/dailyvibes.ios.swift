//
//  AcknowledgementSettingsViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-08.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
//import Haring
import Down

class AcknowledgementSettingsViewController: ThemableViewController {
    @IBOutlet fileprivate weak var markdowntextView: UITextView! {
        didSet {
            markdowntextView.isEditable = false
            markdowntextView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleString = "Acknowledgement"
        setupNavigationTitleText(title: titleString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .always
        
        guard let downView = try? DownView(frame: self.view.bounds, markdownString: testMarkdownFileContent(), didLoadSuccessfully: nil) else { return }
        
        self.view.addSubview(downView)
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
