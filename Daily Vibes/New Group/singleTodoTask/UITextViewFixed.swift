//
//  UITextViewFixed.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-14.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

// code from https://stackoverflow.com/a/42333832

import UIKit
import SwiftTheme

@IBDesignable class UITextViewFixed: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
//        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }

}
