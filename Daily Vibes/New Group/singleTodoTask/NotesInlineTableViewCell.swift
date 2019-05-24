//
//  NotesInlineTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-14.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import Down
import SwiftTheme
import MarkdownKit

class NotesInlineTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var notesDisplayer: UITextView! {
        didSet {
            notesDisplayer.theme_backgroundColor = "Global.barTintColor"
            notesDisplayer.theme_textColor = "Global.textColor"
            notesDisplayer.theme_tintColor = "Global.textColor"
            notesDisplayer.sizeToFit()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        theme_backgroundColor = "Global.barTintColor"
    }
    
    @objc
    func handleHideToolbar() {
        if notesDisplayer.isFirstResponder {
            notesDisplayer.resignFirstResponder()
        }
    }
    
    func setText(text: String?) {
        self.notesDisplayer?.text = text
    }
    
    func setAttributedText(text: String?) {
        if let inputText = text {
//            let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 15))
            
//            markdownParser.color = UIColor.black
//            markdownParser.bold.color = UIColor.red
//            markdownParser.italic.font = UIFont.italicSystemFont(ofSize: 15)
//            markdownParser.header.fontIncrease = 4
//            let down = Down(markdownString: inputText)
//            let attributedStr = try? down.toAttributedString()
            
//            let attributedStr = markdownParser.parse(inputText)
            
            if let barTintColor = ThemeManager.value(for: "Global.barTintColor") as? String,
                let textColor = ThemeManager.value(for: "Global.textColor") as? String,
                let bartextColor = ThemeManager.value(for: "Global.barTextColor") as? String {
                
//                let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 15))
                let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: UIFont.systemFontSize), color: UIColor.from(hex: textColor))
                markdownParser.addCustomElement(MarkdownChecklistUnchecked())
                markdownParser.addCustomElement(MarkdownChecklistChecked())
//                markdownParser.color = UIColor.from(hex: textColor)
                
                markdownParser.bold.color = UIColor.from(hex: bartextColor)
                markdownParser.italic.color = UIColor.from(hex: bartextColor)
//                markdownParser.link.color = UIColor.from(hex: bartextColor)
                
                markdownParser.code.textHighlightColor = UIColor.from(hex: barTintColor)
                markdownParser.code.textBackgroundColor = UIColor.from(hex: bartextColor)
                
                markdownParser.quote.font = UIFont.preferredFont(forTextStyle: .caption2)
//                markdownParser.code.color = UIColor.from(hex: bartextColor)
                
                let attributedStr = markdownParser.parse(inputText)
                
                notesDisplayer.attributedText = attributedStr
                
//                if let uiTextFieldStringAttributes = [
//                    NSAttributedString.Key.backgroundColor: UIColor.from(hex: backgroundColor),
//                    NSAttributedString.Key.foregroundColor: UIColor.from(hex: foregroundColor)
//                    ] as? [NSAttributedString.Key : UIColor] {
//                    self.notesDisplayer?.attributedText = NSAttributedString(string:down.markdownString , attributes: uiTextFieldStringAttributes)
//                }
            }
            
//            self.notesDisplayer?.attributedText = attributedStr
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
