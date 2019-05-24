//
//  LikertDataMVPTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-17.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

// help with uilabel with background from https://stackoverflow.com/questions/40632207/ios-label-in-a-circle

import UIKit
import SwiftTheme

class LikertDataMVPTableViewCell: UITableViewCell {
    
    var data: LikertItemEntry? {
        didSet {
            if let recordings = data?.dpoints?.allObjects as? [LikertScaleItem] {
                // business logic
                
                for item in recordings {
                    let marker = item.ratedValue >= 5 ? "+" : "-"
                    
                    switch item.type {
                    case "motivation":
                        //                    print("motivation value: \(item.ratedValue)")
//                        motivationValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        motivationValue.text = marker
                    case "mood":
                        //                    print("mood value: \(item.ratedValue)")
//                        moodValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        moodValue.text = marker
                    case "stress":
                        //                    print("stress value: \(item.ratedValue)")
//                        stressValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        stressValue.text = marker
                    case "vibes":
                        //                    print("vibes value: \(item.ratedValue)")
                        vibesValue.text = item.ratedValue >= 5 ? "Good" : "Bad"
                    case "work":
                        //                    print("work value: \(item.ratedValue)")
//                        workValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        workValue.text = marker
                    case "life":
                        //                    print("life value: \(item.ratedValue)")
//                        lifeValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        lifeValue.text = marker
                    case "health":
                        //                    print("health value: \(item.ratedValue)")
//                        healthValue.text = "\(marker) | " + String(Float(item.ratedValue) - 5) + " | \(item.ratedValue)"
                        healthValue.text = marker
                    default:
                        // do nothing
                        print("")
                    }
                }
                
                //            print("date: \(data?.createdAtStr)")
                //            print("date: \(data?.updatedAtStr)")
                //            print("recordings: \(recordings.count)")
                
                //            let dateFormatter = ISO8601DateFormatter()
                //            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
                guard let createdAt = data?.createdAt else {
                    fatalError("entry data had missing createdAt date")
                }
                //            entryDateLabel.text = ""
                //            entryDateLabel.text = String(createdAtStr.split(separator: "-").last!)
                if let runningTotal = data?.runningTotal {
                    if runningTotal > 35 {
                        titleUpperStackViewLabel.text = "+"
                        entryDateLabel.text = String(runningTotal)
                        titleUpperStackViewLabel.layer.backgroundColor = UIColor.green.cgColor
                        titleUpperStackViewLabel.layer.borderColor = UIColor.green.cgColor
                    }
                    if runningTotal < 35 {
                        titleUpperStackViewLabel.text = "-"
                        entryDateLabel.text = String(runningTotal)
                        titleUpperStackViewLabel.layer.backgroundColor = UIColor.red.cgColor
                        titleUpperStackViewLabel.layer.borderColor = UIColor.red.cgColor
                    }
                    if runningTotal == 35 {
                        titleUpperStackViewLabel.text = "+"
                        entryDateLabel.text = String(runningTotal)
                        titleUpperStackViewLabel.layer.backgroundColor = UIColor.lightGray.cgColor
                        titleUpperStackViewLabel.layer.borderColor = UIColor.lightGray.cgColor
                    }
                }
                
                titleUpperStackViewLabel.textAlignment = .center
                titleUpperStackViewLabel.layer.cornerRadius = 10.0
                titleUpperStackViewLabel.layer.borderWidth = 1.0
                titleUpperStackViewLabel.layer.masksToBounds = true
                
                titleUpperStackViewLabel.translatesAutoresizingMaskIntoConstraints = false
                
                    let _formttr = DateFormatter()
                    _formttr.dateStyle = .medium
                    _formttr.timeStyle = .short
//                    print(_formttr.string(from: newISOdate))
                let formattedDate = _formttr.string(from: createdAt)
                let manipulatedFormattedDate = formattedDate.components(separatedBy: " at ")
                
                if let _time = manipulatedFormattedDate.last, let _date = manipulatedFormattedDate.first {
                    detailUpperStackViewLabel.text = _date
                    entryDateLabelSub.text = _time
                }
                
                detailLowerStackView.isHidden = true
//                entryDateLabel.text = String(data.runningTotal)
            }
        }
    }
    
    weak var delegate: LikertDataMVPTableViewCellDelegate?
    
    var isExpanded: Bool = false {
        didSet {
            detailLowerStackView.isHidden = !isExpanded
            delegate?.expandableCellLayoutChanged(self)
        }
    }
    
    private var covertedData: [LikertScaleItem] = [LikertScaleItem]()
    
    // upper stack view
    @IBOutlet weak var upperStackView: UIStackView!
    @IBOutlet weak var titleUpperStackViewLabel: UILabel!
    @IBOutlet weak var detailUpperStackViewLabel: UILabel!
    
    @IBOutlet weak var detailLowerStackView: UIStackView!
    // lower stack view
    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var entryDateLabelSub: UILabel!
    @IBOutlet weak var motivationValueLabel: UILabel!
    @IBOutlet weak var motivationValue: UILabel!
    @IBOutlet weak var moodValueLabel: UILabel!
    @IBOutlet weak var moodValue: UILabel!
    @IBOutlet weak var stressValueLabel: UILabel!
    @IBOutlet weak var stressValue: UILabel!
    @IBOutlet weak var vibesValueLabel: UILabel!
    @IBOutlet weak var vibesValue: UILabel!
    @IBOutlet weak var workValueLabel: UILabel!
    @IBOutlet weak var workValue: UILabel!
    @IBOutlet weak var lifeValueLabel: UILabel!
    @IBOutlet weak var lifeValue: UILabel!
    @IBOutlet weak var healthValueLabel: UILabel!
    @IBOutlet weak var healthValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupTheming()
    }
    
    private func setupTheming() {
        // theme
        titleUpperStackViewLabel.theme_textColor = "Global.textColor"
        detailUpperStackViewLabel.theme_textColor = "Global.textColor"
        entryDateLabel.theme_textColor = "Global.textColor"
        entryDateLabelSub.theme_textColor = "Global.textColor"
        motivationValueLabel.theme_textColor = "Global.textColor"
        motivationValue.theme_textColor = "Global.textColor"
        moodValueLabel.theme_textColor = "Global.textColor"
        moodValue.theme_textColor = "Global.textColor"
        stressValueLabel.theme_textColor = "Global.textColor"
        stressValue.theme_textColor = "Global.textColor"
        vibesValueLabel.theme_textColor = "Global.textColor"
        vibesValue.theme_textColor = "Global.textColor"
        workValueLabel.theme_textColor = "Global.textColor"
        workValue.theme_textColor = "Global.textColor"
        lifeValueLabel.theme_textColor = "Global.textColor"
        lifeValue.theme_textColor = "Global.textColor"
        healthValueLabel.theme_textColor = "Global.textColor"
        healthValue.theme_textColor = "Global.textColor"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

protocol LikertDataMVPTableViewCellDelegate: class {
    func expandableCellLayoutChanged(_ expandableCell: LikertDataMVPTableViewCell)
}
