//
//  LikertDataMVPEntryTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class LikertDataMVPEntryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    var data: LikertItemEntry? {
        didSet {
//            print("settings...")
            guard let createdAt = data?.createdAt else {
                fatalError("entry had missing createdAt")
            }

            let _formttr = DateFormatter()
            _formttr.dateStyle = .medium
            _formttr.timeStyle = .short

            let formattedDate = _formttr.string(from: createdAt)
            let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")

//            if let _time = manipulatedFormattedDate.last ,let _date = manipulatedFormattedDate.first {
//                title.text = _time
//                subTitle.text = _date
//                detail.text = "↑"
//            }
            
            if let _time = manipulatedFormattedDate.last ,let _date = manipulatedFormattedDate.first  {
                title.text = _time
                subTitle.text = _date
                
                if let runningtotal = data?.runningTotal {
                    let symbol = runningtotal.isLessThanOrEqualTo(35) ? "↓" : "↑"
//                    detail.text = "\(runningtotal) \(symbol)"
                    detail.text = symbol
                }
                
//                if let entries = data?.entries {
//                    let count = entries.count
//                    subTitle.text = "\(count) entries"
//                    if let runningtotal = data?.runningTotal {
//                        let estTotal = Float(count) * Float(35)
//                        let symbol = runningtotal.isLessThanOrEqualTo(estTotal) ? "↓" : "↑"
//                        detailText.text = "\(estTotal) \(symbol)"
//                    }
//                }
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
//        doneAlertCell.theme_backgroundColor = "Global.barTintColor"
//        doneAlertLabel.theme_textColor = "Global.textColor"
//        doneAlertSwitch.theme_onTintColor = "Global.barTextColor"
//        deleteAlertCell.theme_backgroundColor = "Global.barTintColor"
//        deleteAlertLabel.theme_textColor = "Global.textColor"
//        deleteAlertSwitch.theme_onTintColor = "Global.barTextColor"
        
        self.theme_backgroundColor = "Global.barTintColor"
        title.theme_textColor = "Global.textColor"
        subTitle.theme_textColor = "Global.placeholderColor"
        detail.theme_textColor = "Global.placeholderColor"
        
        let customSelectedView = UIView(frame: .zero)
        customSelectedView.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        selectedBackgroundView = customSelectedView
    }

}
