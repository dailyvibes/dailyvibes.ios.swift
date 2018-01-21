//
//  LoadingTableViewEmptyView.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-17.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class LoadingTableViewEmptyView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet private weak var emptyListHeader: UILabel!
    @IBOutlet private weak var emptyListMainText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emptyListHeader.text = NSLocalizedString("Your list is currently empty", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Your list is currently empty. **", comment: "")
        emptyListMainText.text = NSLocalizedString("You can add a new to-do to get started", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND You can add a new to-do to get started **", comment: "")
        
        view.theme_backgroundColor = "Global.backgroundColor"
        
        emptyListHeader.theme_textColor = "Global.textColor"
        emptyListMainText.theme_textColor = "Global.textColor"
    }
    
}
