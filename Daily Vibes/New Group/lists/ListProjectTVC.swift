//
//  ListProjectTVC.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-02-06.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit
import SwiftTheme

class ListProjectTVC: ThemableBaseTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.theme_backgroundColor = "Global.barTintColor"
//        self.layer.theme_borderColor = "Global.backgroundColor"
//        self.theme_tintColor = "Global.barTextColor"
        
//        let customSelectedView = UIView(frame: .zero)
//        customSelectedView.theme_backgroundColor = "Global.selectionBackgroundColor"
        
//        selectedBackgroundView = customSelectedView
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 16
            frame.size.width -= 2 * 16
            cornerRadius = 8
            borderWidth = 3
            super.frame = frame
        }
    }
}
