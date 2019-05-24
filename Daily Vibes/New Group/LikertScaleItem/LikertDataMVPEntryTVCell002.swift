//
//  LikertDataMVPEntryTVCell002.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-01-02.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import UIKit

class LikertDataMVPEntryTVCell002: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    
    var data: LikertItemEntry? {
        didSet {
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
//                    let symbol = runningtotal.isLessThanOrEqualTo(35) ? "↓" : "↑"
                    //                    detail.text = "\(runningtotal) \(symbol)"
//                    detail.text = symbol
                    if runningtotal.isEqual(to: 35) {
                        detailImage.image = #imageLiteral(resourceName: "dvMinusOrange")
                    } else if (runningtotal.isLessThanOrEqualTo(35)) {
                        detailImage.image = #imageLiteral(resourceName: "dvArrowDownRed")
                    } else {
                        detailImage.image = #imageLiteral(resourceName: "dvArrowUpGreen")
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
        
        let customSelectedView = UIView(frame: .zero)
        customSelectedView.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        selectedBackgroundView = customSelectedView
//        detailText.theme_textColor = "Global.placeholderColor"
    }

}
