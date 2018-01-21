//
//  NotesInlineTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-14.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class NotesInlineTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var notesDisplayer: UITextView! {
        didSet {
            notesDisplayer.theme_backgroundColor = "Global.barTintColor"
            notesDisplayer.theme_textColor = "Global.textColor"
            notesDisplayer.sizeToFit()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        theme_backgroundColor = "Global.barTintColor"
    }
    
    func setText(text: String?) {
        self.notesDisplayer?.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
