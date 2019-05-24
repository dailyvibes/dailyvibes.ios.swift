//
//  LikertDataMVPDateTableViewCellTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class LikertDataMVPDateTableViewCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var detailText: UILabel!
    
    var data: LikertItemDate? {
        didSet {
            guard let createdAt = data?.createdAt else {
                fatalError("date had missing createdAt date")
            }
            
            let _formttr = DateFormatter()
            _formttr.dateStyle = .medium
            _formttr.timeStyle = .short

            let formattedDate = _formttr.string(from: createdAt)
            let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")
            
            if let _date = manipulatedFormattedDate.first {
                title.text = _date
                if let entries = data?.entries {
                    let count = entries.count
                    subTitle.text = "\(count) entries"
                    if let runningtotal = data?.runningTotal {
                        let estTotal = Float(count) * Float(35)
                        let symbol = runningtotal.isLessThanOrEqualTo(estTotal) ? "↓" : "↑"
//                        detailText.text = "\(runningtotal), \(symbol)"
                        detailText.text = symbol
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheming()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setupTheming() {
        self.theme_backgroundColor = "Global.barTintColor"
        title.theme_textColor = "Global.textColor"
        subTitle.theme_textColor = "Global.placeholderColor"
        detailText.theme_textColor = "Global.placeholderColor"
        
        let customSelectedView = UIView(frame: .zero)
        customSelectedView.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        selectedBackgroundView = customSelectedView
    }

}
