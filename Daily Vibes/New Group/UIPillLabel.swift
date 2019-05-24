//// from https://stackoverflow.com/a/36311576
//
////
////  UIPillLabel.swift
////  Daily Vibes
////
////  Created by Alex Kluew on 2019-01-16.
////  Copyright © 2019 Alex Kluew. All rights reserved.
////
//
import Foundation
import UIKit

class PillLabel : UILabel {
    
    @IBInspectable var color = UIColor.lightGray
//    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var labelText: String = "None"
    @IBInspectable var fontSize: CGFloat = 10.5
    
    // This has to be balanced with the number of spaces prefixed to the text
//    let borderWidth: CGFloat = 3
    
    init(text: String, color: UIColor = UIColor.lightGray) {
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        labelText = text
        self.color = color
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // This has to be balanced with the borderWidth property
        text = "  \(labelText)"
        
        // Credits to https://stackoverflow.com/a/33015915/784318
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        backgroundColor = color
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
        font = UIFont.boldSystemFont(ofSize: fontSize)
        textColor = color.contrastColor
        sizeToFit()
        
        // Credits to https://stackoverflow.com/a/15184257/784318
//        frame = CGRect.inset(by: self.frame, -borderWidth, -borderWidth)
        frame = CGRect(x: 0, y: 0, width: self.frame.width-borderWidth, height: self.frame.height-borderWidth)
    }
    
}

//class LabelWithPadding: UILabel {
//    override var intrinsicContentSize: CGSize {
//        let defaultSize = super.intrinsicContentSize
//        return CGSize(width: defaultSize.width + 12, height: defaultSize.height + 8)
//    }
//}

extension UIColor {
    // Credits to https://stackoverflow.com/a/29044899/784318
//    func isLight() -> Bool{
//        var green: CGFloat = 0.0, red: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
//        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        let brightness = ((red * 299) + (green * 587) + (blue * 114) ) / 1000
//
//        return brightness < 0.5 ? false : true
//    }
    
    var contrastColor: UIColor{
        return self.isLight ? UIColor.black : UIColor.white
    }
}
