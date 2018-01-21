//
//  UIColor+Extension.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-18.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

// http://www.coderzheaven.com/2017/12/10/hex-string-to-uicolor-in-ios-swift/

import UIKit

extension UIColor {
    class func from(hex: String) -> UIColor! {
        //        return UIColor(red: 0x29/0xff, green: 0x80/0xff, blue: 0xb9/0xff, alpha: 1)
        var cString:String = hex.trimmingCharacters(in:
            .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
