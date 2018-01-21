//
//  SegmentedUIToolBar.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-06.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class SegmentedUIToolBar: UIToolbar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        theme_backgroundColor = "Global.barTintColor"
        theme_tintColor = "Global.barTextColor"
        theme_barTintColor = "Global.barTintColor"
    }

}
