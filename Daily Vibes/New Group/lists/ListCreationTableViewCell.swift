//
//  ListCreationTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-12.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class ListCreationTableViewCell: ThemableBaseTableViewCell {

    // MARK: Properties
//    @IBOutlet weak var listLabeler: ThemableBaseTextField!
    @IBOutlet weak var listLabeler: UITextField!
    
    @objc
    func handleHideToolbar() {
//        print("called handleHideToolbar")
        if listLabeler.isFirstResponder {
            listLabeler.resignFirstResponder()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        theme_backgroundColor = "Global.selectionBackgroundColor"
//        theme_backgroundColor = "Global.barTintColor"
        
        theme_backgroundColor = "Global.backgroundColor"
        theme_tintColor = "Global.textColor"
        
        
        let numbertoolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numbertoolbar.theme_barStyle = "Global.toolbarStyle"
//        numbertoolbar.theme_barStyle = "Global.barTextColor"
        
        let kbhideBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "dvKeyboardDownIcon001"), style: .plain, target: self, action: #selector(handleHideToolbar))
        kbhideBtn.accessibilityIdentifier = "listcreate.keyboard.down.btn"
        
        let tbitems: [UIBarButtonItem] = [
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), kbhideBtn]
        
        numbertoolbar.items = tbitems
        numbertoolbar.sizeToFit()
        
        listLabeler.inputAccessoryView = numbertoolbar
        listLabeler.theme_backgroundColor = "Global.barTintColor"
        listLabeler.keyboardType = .namePhonePad
        listLabeler.returnKeyType = .done
//        listLabeler.leftViewMode = .always
        
//        leftViewMode = UITextFieldViewMode.always
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        listLabeler.imageView.contentMode = .scaleAspectFit
//        listLabeler.imageView.image = #imageLiteral(resourceName: "dvNewIcon")
//        listLabeler.leftView = imageView
//        listLabeler.leftView.image
        // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
//        listLabeler.imageView.tintColor = .
        
//        let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        _imageView.contentMode = .scaleAspectFit
//        _imageView.image = #imageLiteral(resourceName: "dvAdd002Icon")
//        listLabeler.inset
        
//        listLabeler.theme_backgroundColor = "Global.backgroundColor"
//        listLabeler.borderWidth = 2.0
//        listLabeler.borderColor = .black
        
//        let projectImage = #imageLiteral(resourceName: "dvProject003Icon")
        //        let projectImagePlaceholder = projectImage.tint(color: .whatsNewKitGreen)
//        let projectImagePlaceholder = projectImage.tint(color: .gray)
        let projectImagePlaceholder = "➕".imageFromEmoji(16, 16)
        let leftbtn = UIButton.init(type: .custom)
        
        leftbtn.setImage(projectImagePlaceholder, for: .normal)
        //        leftbtn.addTarget(self, action: nil, for: .touchUpInside)
        leftbtn.frame = CGRect.init(x: 8, y: 0, width: 16, height: 16)
        
        let xview = UIView.init(frame: CGRect(x: 0, y: 0, width: 24, height: 16))
        xview.addSubview(leftbtn)
        
        listLabeler.leftView = xview
        listLabeler.leftViewMode = .always
        
        let titleStr = NSLocalizedString("Title", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Title **", comment: "")
        
        listLabeler.borderStyle = .roundedRect
        listLabeler.theme_textColor = "Global.textColor"
        listLabeler.placeholder = titleStr
        
        listLabeler.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: "Global.placeholderColor") { value -> [NSAttributedString.Key : AnyObject]? in
            guard let rgba = value as? String else {
                return nil
            }
            
            let color = UIColor(rgba: rgba)
            let shadow = NSShadow(); shadow.shadowOffset = CGSize.zero
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                NSAttributedString.Key.shadow: shadow
            ]
            
            return titleTextAttributes
        }
        
//        listLabeler.setPlaceHolderTextColor(.grayText)
//        listLabeler.placeholder = NSLocalizedString("Create new (ex: Groceries, Upcoming project) or select one below", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND ex: Groceries, Upcoming project **", comment: "")
//        listLabeler.setAttributedPlaceholderFromPlaceholder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
