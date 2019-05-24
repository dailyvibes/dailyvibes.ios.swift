//
//  LikertDataMVPDateTVCell002.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-01-03.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import UIKit

class LikertDataMVPDateTVCell002: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    
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
                        if runningtotal.isEqual(to: estTotal) {
                            detailImage.image = #imageLiteral(resourceName: "dvMinusOrange")
                        } else if (runningtotal.isLessThanOrEqualTo(estTotal)) {
                            detailImage.image = #imageLiteral(resourceName: "dvArrowDownRed")
                        } else {
                            detailImage.image = #imageLiteral(resourceName: "dvArrowUpGreen")
                        }
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
