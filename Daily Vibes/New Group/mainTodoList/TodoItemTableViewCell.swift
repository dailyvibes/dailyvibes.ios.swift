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
//    private let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        emotionsImageView.isUserInteractionEnabled = true
//        emotionsImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
//    @objc func didTap(sender: UITapGestureRecognizer) {
////        let location = sender.location(in: view)
//        print("tapped on \(todoItemLabel.text)")
//        // User tapped at the point above. Do something with that if you want.
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
