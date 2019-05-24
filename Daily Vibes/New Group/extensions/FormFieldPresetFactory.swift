//
//  FormFieldPresetFactory.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-01-05.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

//
//  FormFieldPresetFactory.swift
//  SwiftEntryKitDemo
//
//  Created by Daniel Huri on 5/18/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation
import SwiftEntryKit

typealias MainFont = Font.HelveticaNeue

enum Font {
    enum HelveticaNeue: String {
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case ultraLight = "UltraLight"
        case italic = "Italic"
        case light = "Light"
        case thinItalic = "ThinItalic"
        case lightItalic = "LightItalic"
        case bold = "Bold"
        case thin = "Thin"
        case condensedBlack = "CondensedBlack"
        case condensedBold = "CondensedBold"
        case boldItalic = "BoldItalic"
        
        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
        }
    }
}

extension UIColor {
    static func by(r: Int, g: Int, b: Int, a: CGFloat = 1) -> UIColor {
        let d = CGFloat(255)
        return UIColor(red: CGFloat(r) / d, green: CGFloat(g) / d, blue: CGFloat(b) / d, alpha: a)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let darkDefault = UIColor(white: 45.0/255.0, alpha: 1)
    static let grayText = UIColor(white: 160.0/255.0, alpha: 1)
    static let facebookDarkBlue = UIColor.by(r: 59, g: 89, b: 152)
    static let dimmedLightBackground = UIColor(white: 100.0/255.0, alpha: 0.3)
    static let dimmedDarkBackground = UIColor(white: 50.0/255.0, alpha: 0.3)
    static let pinky = UIColor(rgb: 0xE91E63)
    static let amber = UIColor(rgb: 0xFFC107)
    static let satCyan = UIColor(rgb: 0x00BCD4)
    static let darkText = UIColor(rgb: 0x212121)
    static let redish = UIColor(rgb: 0xFF5252)
    static let darkSubText = UIColor(rgb: 0x757575)
    static let greenGrass = UIColor(rgb: 0x4CAF50)
    static let darkChatMessage = UIColor(red: 48, green: 47, blue: 48)
}

struct EKColor {
    struct BlueGray {
        static let c50 = UIColor(rgb: 0xeceff1)
        static let c100 = UIColor(rgb: 0xcfd8dc)
        static let c200 = UIColor(rgb: 0xb0bec5)
        static let c300 = UIColor(rgb: 0x90a4ae)
        static let c400 = UIColor(rgb: 0x78909c)
        static let c500 = UIColor(rgb: 0x607d8b)
        static let c600 = UIColor(rgb: 0x546e7a)
        static let c700 = UIColor(rgb: 0x455a64)
        static let c800 = UIColor(rgb: 0x37474f)
        static let c900 = UIColor(rgb: 0x263238)
    }
    
    struct Netflix {
        static let light = UIColor(rgb: 0x485563)
        static let dark = UIColor(rgb: 0x29323c)
    }
    
    struct Gray {
        static let a800 = UIColor(rgb: 0x424242)
        static let mid = UIColor(rgb: 0x616161)
        static let light = UIColor(white: 230.0/255.0, alpha: 1)
    }
    
    struct Purple {
        static let a300 = UIColor(rgb: 0xba68c8)
        static let a400 = UIColor(rgb: 0xab47bc)
        static let a700 = UIColor(rgb: 0xaa00ff)
        static let deep = UIColor(rgb: 0x673ab7)
    }
    
    struct BlueGradient {
        static let light = UIColor(red: 100, green: 172, blue: 196)
        static let dark = UIColor(red: 27, green: 47, blue: 144)
    }
    
    struct Yellow {
        static let a700 = UIColor(rgb: 0xffd600)
    }
    
    struct Teal {
        static let a700 = UIColor(rgb: 0x00bfa5)
        static let a600 = UIColor(rgb: 0x00897b)
    }
    
    struct Orange {
        static let a50 = UIColor(rgb: 0xfff3e0)
    }
    
    struct LightBlue {
        static let a700 = UIColor(rgb: 0x0091ea)
    }
    
    struct LightPink {
        static let first = UIColor(rgb: 0xff9a9e)
        static let last = UIColor(rgb: 0xfad0c4)
    }
}

struct TextFieldOptionSet: OptionSet {
    let rawValue: Int
    static let fullName = TextFieldOptionSet(rawValue: 1 << 0)
    static let mobile = TextFieldOptionSet(rawValue: 1 << 1)
    static let email = TextFieldOptionSet(rawValue: 1 << 2)
    static let password = TextFieldOptionSet(rawValue: 1 << 3)
    static let projectList = TextFieldOptionSet(rawValue: 1 << 4)
}

enum FormStyle {
    case light
    case dark
    
    var imageSuffix: String {
        switch self {
        case .dark:
            return "_light"
        case .light:
            return "_dark"
        }
    }
    
    var title: EKProperty.LabelStyle {
        let font = MainFont.medium.with(size: 16)
        switch self {
        case .dark:
            return .init(font: font, color: .white, alignment: .center)
        case .light:
            return .init(font: font, color: EKColor.Gray.a800, alignment: .center)
        }
    }
    
    var buttonTitle: EKProperty.LabelStyle {
        let font = MainFont.bold.with(size: 16)
        switch self {
        case .dark:
            return .init(font: font, color: .black)
        case .light:
            return .init(font: font, color: .white)
        }
    }
    
    var buttonBackground: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .redish
        }
    }
    
    var placeholder: EKProperty.LabelStyle {
        let font = MainFont.light.with(size: 14)
        switch self {
        case .dark:
            return .init(font: font, color: UIColor(white: 0.8, alpha: 1))
        case .light:
            return .init(font: font, color: UIColor(white: 0.5, alpha: 1))
        }
    }
    
    var text: EKProperty.LabelStyle {
        let font = MainFont.light.with(size: 14)
        switch self {
        case .dark:
            return .init(font: font, color: .white)
        case .light:
            return .init(font: font, color: .black)
        }
    }
    
    var separator: UIColor {
        return .init(white: 0.8784, alpha: 0.6)
    }
}

class FormFieldPresetFactory {
    
    class func projectList(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let projectListPlaceholder = EKProperty.LabelContent(text: "Project", style: placeholderStyle)
        return .init(keyboardType: .namePhonePad, placeholder: projectListPlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_mail" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func email(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let emailPlaceholder = EKProperty.LabelContent(text: "Email Address", style: placeholderStyle)
        return .init(keyboardType: .emailAddress, placeholder: emailPlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_mail" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func fullName(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let fullNamePlaceholder = EKProperty.LabelContent(text: "Full Name", style: placeholderStyle)
        return .init(keyboardType: .namePhonePad, placeholder: fullNamePlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_user" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func mobile(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let mobilePlaceholder = EKProperty.LabelContent(text: "Mobile Phone", style: placeholderStyle)
        return .init(keyboardType: .decimalPad, placeholder: mobilePlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_phone" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func password(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let passwordPlaceholder = EKProperty.LabelContent(text: "Password", style: placeholderStyle)
        return .init(keyboardType: .namePhonePad, placeholder: passwordPlaceholder, textStyle: textStyle, isSecure: true, leadingImage: UIImage(named: "ic_lock" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func fields(by set: TextFieldOptionSet, style: FormStyle) -> [EKProperty.TextFieldContent] {
        var array: [EKProperty.TextFieldContent] = []
        let placeholderStyle = style.placeholder
        let textStyle = style.text
        let separatorColor = style.separator
        if set.contains(.fullName) {
            array.append(fullName(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.mobile) {
            array.append(mobile(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.email) {
            array.append(email(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.password) {
            array.append(password(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.projectList) {
            array.append(projectList(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        return array
    }
}

