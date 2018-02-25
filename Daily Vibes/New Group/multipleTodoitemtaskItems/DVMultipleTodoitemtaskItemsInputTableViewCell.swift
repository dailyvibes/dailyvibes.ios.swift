//
//  DVMultipleTodoitemtaskItemsInputTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-02-17.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import GrowingTextView

class DVMultipleTodoitemtaskItemsInputTableViewCell: UITableViewCell {
    
    @IBOutlet weak var multipleTodoitemTextView: GrowingTextView! {
        didSet {
//            multipleTodoitemTextView.maxLength = 140
//            multipleTodoitemTextView.trimWhiteSpaceWhenEndEditing = false
//            multipleTodoitemTextView.placeHolder = "Say something..."
//            multipleTodoitemTextView.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)
//            multipleTodoitemTextView.minHeight = 25.0
//            multipleTodoitemTextView.maxHeight = 70.0
//            multipleTodoitemTextView.backgroundColor = UIColor.white
//            multipleTodoitemTextView.layer.cornerRadius = 4.0
            
            multipleTodoitemTextView.layer.cornerRadius = 4.0
            multipleTodoitemTextView.placeHolder = """
            - Please enter
            - Multiple tasks
            - One new to-do item task per line
            - You can also include #tags
            """
            multipleTodoitemTextView.font = UIFont.systemFont(ofSize: 15)
//            multipleTodoitemTextView.minHeight = 60
//            multipleTodoitemTextView.maxHeight = 150
            
            self.multipleTodoitemTextView.sizeToFit()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        multipleTodoitemTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
extension DVMultipleTodoitemtaskItemsInputTableViewCell: GrowingTextViewDelegate {
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print("changing textView")
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
//            self.view.layoutIfNeeded()
            self.multipleTodoitemTextView.sizeToFit()
        }, completion: nil)
    }
}
