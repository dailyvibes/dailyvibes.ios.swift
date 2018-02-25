//
//  ListCreationTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-12.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class ListCreationTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var listLabeler: ThemableBaseTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        theme_backgroundColor = "Global.barTintColor"
        
        listLabeler.placeholder = NSLocalizedString("Create new (ex: Groceries, Upcoming project) or select one below", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND ex: Groceries, Upcoming project **", comment: "")
        listLabeler.setAttributedPlaceholderFromPlaceholder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
