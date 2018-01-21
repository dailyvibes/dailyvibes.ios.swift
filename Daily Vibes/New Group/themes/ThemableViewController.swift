//
//  ThemableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-15.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class ThemableViewController: UIViewController {

    var customNavigationTitle: String = NSLocalizedString("NOT SET forNavigationTitleText", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText **", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupTitleView(withString string: String) {
        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let _title:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrs)
        
        let size = _title.size()
        
        let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {return}
        
        let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        titleLabel.attributedText = _title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.theme_backgroundColor = "Global.barTintColor"
        titleLabel.theme_textColor = "Global.textColor"
        
        navigationItem.titleView = titleLabel
    }
    
    func setupNavigationTitleText(title text:String?) {
        if let _text = text {
            customNavigationTitle = NSLocalizedString(_text, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText \(_text) **", comment: "")
        } else {
            customNavigationTitle = NSLocalizedString("NOT SET forNavigationTitleText", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText **", comment: "")
        }
        setupTitleView(withString: customNavigationTitle)
    }

}
