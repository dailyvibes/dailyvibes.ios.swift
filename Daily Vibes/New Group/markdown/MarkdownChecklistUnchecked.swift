//
//  MarkdownChecklist.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-02-04.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import Foundation
import MarkdownKit

open class MarkdownChecklistUnchecked: MarkdownLevelElement {
    
    fileprivate static let regex = "^(\\[\\s\\])\\s*(.+)$"
    
    open var maxLevel: Int
    open var font: MarkdownFont?
    open var color: MarkdownColor?
    open var separator: String
    open var indicator: String
    
    open var regex: String {
        let level: String = maxLevel > 0 ? "\(maxLevel)" : ""
        return String(format: MarkdownChecklistUnchecked.regex, level)
    }
    
    public init(font: MarkdownFont? = nil, maxLevel: Int = 0, indicator: String = "☐",
                separator: String = "  ", color: MarkdownColor? = nil) {
        self.maxLevel = maxLevel
        self.indicator = indicator
        self.separator = separator
        self.font = font
        self.color = color
    }
    
    open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
        var string = (0..<level).reduce("") { (string, _) -> String in
            return "\(string)\(separator)"
        }
        string = "\(string)\(indicator) "
        attributedString.replaceCharacters(in: range, with: string)
    }
}
