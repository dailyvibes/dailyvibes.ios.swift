//
//  TodoItemTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var todoItemLabel: UILabel!
    @IBOutlet weak var todoItemTagsLabel: UILabel!
    @IBOutlet weak var emotionsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
