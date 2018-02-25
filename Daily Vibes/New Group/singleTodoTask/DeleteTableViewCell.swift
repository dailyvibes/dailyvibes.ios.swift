//
//  DeleteTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-15.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class DeleteTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var deleteButtonCell: UIButton! {
        didSet {
            let deleteButtonString = NSLocalizedString("Delete", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Delete **", comment: "")
            deleteButtonCell.setTitle(deleteButtonString, for: .normal)
            deleteButtonCell.theme_backgroundColor = "Global.barTintColor"
            deleteButtonCell.tintColor = .red
            theme_backgroundColor = "Global.barTintColor"
        }
    }
    
    var delegate: DeleteButtonTableViewCellDelegate?

    @IBAction func deleteButtonAction(_ sender: UIButton) {
        if sender == deleteButtonCell {
            delegate?.processDeleteButtonClick()
        }
    }
    
    func enableDeleteButton() {
        if !deleteButtonCell.isEnabled {
            deleteButtonCell.isEnabled = true
        }
    }
    
    func isEnabled() -> Bool {
        return deleteButtonCell.isEnabled
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

protocol DeleteButtonTableViewCellDelegate : class {
    func processDeleteButtonClick()
}
