//
//  AboutSettingsViewControllerViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-08.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import WebKit

class AboutSettingsViewControllerViewController: ThemableViewController {

    @IBOutlet private var webView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleString = "About"
        setupNavigationTitleText(title: titleString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let urlLocation = "https://dailyvibes.ca/about/"
        let myURL = URL(string: urlLocation)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

}
