//
//  ThemeManager.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-06.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation
import SwiftTheme

enum MyThemes: Int {
    
    case DVDefault = 0
    case nightBlue = 1
    case night = 2
    case lightOrange = 3
    
    // MARK: -
    
    static var current = MyThemes.DVDefault
    static var before  = MyThemes.DVDefault
    
    // MARK: - Switch Theme
    
    static func switchTo(_ theme: MyThemes) {
        before  = current
        current = theme
        
        switch theme {
        case .nightBlue:
            ThemeManager.setTheme(plistName: "NightBlue", path: .mainBundle)
        case .DVDefault:
            ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
        case .night:
            ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
        case .lightOrange:
            ThemeManager.setTheme(plistName: "LightOrange", path: .mainBundle)
        }
    }
}
