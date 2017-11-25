//
//  NewTodoItemTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-18.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

//protocol ExpandingCellDelegate {
//    func updated(height: CGFloat)
//}

class NewTodoItemTableViewCell: UITableViewCell, UITextViewDelegate {
    
//    var delegate: ExpandingCellDelegate?
    var callBack: ((UITextView) -> ())?
    
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.isScrollEnabled = false
    }

    func textViewDidChange(_ textView: UITextView) {
        // tell controller the text changed
        callBack?(textView)
    }

}

//extension NewTodoItemTableViewCell: UITextViewDelegate {
//
//    func textViewDidChange(_ textView: UITextView) {
//
//        let height = textView.newHeight(withBaseHeight: 200)
//        delegate?.updated(height: height)
//    }
//}

