//
//  ThemableBaseTextField.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-18.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class ThemableBaseTextField: UITextField {
    
    override func awakeFromNib() {
        theme_textColor = "Global.textColor"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setAttributedPlaceholderFromPlaceholder),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
    }
    
    @objc func setAttributedPlaceholderFromPlaceholder() {
        var uiTextFieldStringAttributes: [NSAttributedStringKey:UIColor]?
        
        if let backgroundColor = ThemeManager.value(for: "Global.barTintColor") as? String,
            let foregroundColor = ThemeManager.value(for: "Global.placeholderColor") as? String {
            uiTextFieldStringAttributes = [
                NSAttributedStringKey.backgroundColor: UIColor.from(hex: backgroundColor),
                NSAttributedStringKey.foregroundColor: UIColor.from(hex: foregroundColor)
            ]
        }
        
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string:placeholder, attributes: uiTextFieldStringAttributes)
        }
    }
}
