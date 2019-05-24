//
//  ThemableBaseTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-18.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class ThemableBaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        theme_backgroundColor = "Global.barTintColor"
        theme_tintColor = "Global.barTextColor"
        
        let customSelectedView = UIView(frame: .zero)
        customSelectedView.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        selectedBackgroundView = customSelectedView
    }

}
