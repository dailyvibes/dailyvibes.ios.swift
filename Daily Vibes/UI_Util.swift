//
//  UI_Util.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-11.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit

class UI_Util {
    
    public static func setGradientGreenBlue(uiView: UIView) {
        
        let colorTop =  UIColor(red: 15.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 84.0/255.0, green: 187.0/255.0, blue: 187.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = uiView.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        uiView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
