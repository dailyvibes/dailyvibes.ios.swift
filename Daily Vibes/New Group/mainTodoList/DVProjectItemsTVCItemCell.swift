//
//  DVProjectItemsTVCItemCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-02-11.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class DVProjectItemsTVCItemCell: ThemableBaseTableViewCell {
    
    // MARK: Properties
//    @IBOutlet weak var todoItemLabel: UILabel!
//    @IBOutlet weak var todoItemTagsLabel: UILabel!
//    @IBOutlet weak var emotionsImageView: UIImageView!
    //    private let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
    
    @IBOutlet weak var emotionsImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var completedAt: PillLabel!
    @IBOutlet weak var duedateAt: PillLabel!
    @IBOutlet weak var taskitemimageview: UIView!
    
    @IBOutlet weak var tags: PillLabel!
    @IBOutlet weak var notes: PillLabel!
    @IBOutlet weak var archived: PillLabel!
    
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
    
    //    override var frame: CGRect {
    //        get {
    //            return super.frame
    //        }
    //        set (newFrame) {
    //            var frame = newFrame
    //            frame.origin.x += 16
    //            frame.size.width -= 2 * 16
    //            cornerRadius = 8
    //            borderWidth = 1
    //            super.frame = frame
    //        }
    //    }
    
}

