//
//  NewTodoItemTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-18.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

// https://stackoverflow.com/a/47037937

import UIKit

class NewTodoItemTableViewCell: UITableViewCell, UITextViewDelegate {
    
    var callBack: ((UITextView) -> ())?
    
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        textView.isScrollEnabled = false
    }

    func textViewDidChange(_ textView: UITextView) {
        // tell controller the text changed
        callBack?(textView)
    }

}
