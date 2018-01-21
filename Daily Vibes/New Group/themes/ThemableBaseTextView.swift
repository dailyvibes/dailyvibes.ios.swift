//
//  ThemableBaseTextView.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class ThemableBaseTextView: UITextView {

    override func awakeFromNib() {
        theme_backgroundColor = "Global.barTintColor"
        theme_textColor = "Global.textColor"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setAttributed),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
    }
    
    @objc func setAttributed(text string:String) {
        var uiTextViewStringAttributes: [NSAttributedStringKey:Any]?
        
        if let backgroundColor = ThemeManager.value(for: "Global.barTintColor") as? String,
            let foregroundColor = ThemeManager.value(for: "Global.textColor") as? String {
            uiTextViewStringAttributes = [
                NSAttributedStringKey.backgroundColor: UIColor.from(hex: backgroundColor),
                NSAttributedStringKey.foregroundColor: UIColor.from(hex: foregroundColor)
            ]
        }
        
        attributedText = NSAttributedString(string: string, attributes: uiTextViewStringAttributes)
    }

}
