//
//  TagsCreationTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-21.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class TagsCreationTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var tagLabeler: ThemableBaseTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        theme_backgroundColor = "Global.barTintColor"
        
        tagLabeler.placeholder = NSLocalizedString("Create a new tag or use one below", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Create a new tag or use one below **", comment: "")
        tagLabeler.setAttributedPlaceholderFromPlaceholder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
