//
//  ThemableTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-15.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

class ThemableTableViewController: UITableViewController {
    
    var customNavigationTitle: String = NSLocalizedString("NOT SET forNavigationTitleText", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText **", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupTitleView(withTitle _titleString: String?, withSubtitle _subtitleString: String?) {
        
        if let titleString = _titleString {
            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
            let _title:NSMutableAttributedString = NSMutableAttributedString(string: titleString, attributes: attrs)
            
            if let subtitleString = _subtitleString {
                let __attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
                let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: subtitleString, attributes: __attrs)
                
                _title.append(NSAttributedString(string:"\n"))
                _title.append(__subTitle)
            }
            
            let size = _title.size()
            
            let width = size.width
            guard let height = navigationController?.navigationBar.frame.size.height else {return}
            
            let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            titleLabel.attributedText = _title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.theme_backgroundColor = "Global.barTintColor"
            titleLabel.theme_textColor = "Global.textColor"
            
            navigationItem.titleView = titleLabel
        } else {
            let todaysDate = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: todaysDate)
            let month = calendar.component(.month, from: todaysDate)
            let day = calendar.component(.day, from: todaysDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startOfYear = dateFormatter.date(from: "\(year)-01-01")
            let todayInYear = dateFormatter.date(from: "\(year)-\(month)-\(day)")
            let endOfYear = dateFormatter.date(from: "\(year)-12-31")
            
            let daysInCurrentYear = calendar.dateComponents([.day], from: startOfYear!, to: endOfYear!)
            let daysLeftInCurrentYear = calendar.dateComponents([.day], from: todayInYear!, to: endOfYear!)
            
            let totalDays = daysInCurrentYear.day
            let daysLeft = daysLeftInCurrentYear.day
            
            let yearProgress = Int(100 - ceil(Double(daysLeft!)/Double(totalDays!) * 100))
            let yearProgressLocalizedString = NSLocalizedString("Year progress", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND year completed **", comment: "")
            let yearProgressString = "\(yearProgressLocalizedString): \(yearProgress)%"
            let todaysDateString = dateFormatter.string(from: todaysDate)
            
            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)]
            let _title:NSMutableAttributedString = NSMutableAttributedString(string: todaysDateString, attributes: attrs)
            
            let __attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13, weight: .ultraLight)]
            let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: "\(yearProgressString)", attributes: __attrs)
            
            _title.append(NSAttributedString(string:"\n"))
            _title.append(__subTitle)
            
            let size = _title.size()
            
            let width = size.width
            guard let height = navigationController?.navigationBar.frame.size.height else {return}
            
            let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            titleLabel.attributedText = _title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.theme_backgroundColor = "Global.barTintColor"
            titleLabel.theme_textColor = "Global.textColor"
            
            navigationItem.titleView = titleLabel
        }
    }
    
    func setupNavigationTitleText(title text:String?, subtitle subtitleText:String?) {
        if let _text = text {
            customNavigationTitle = NSLocalizedString(_text, tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText \(_text) **", comment: "")
        } else {
            customNavigationTitle = NSLocalizedString("NOT SET forNavigationTitleText", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND NOT SET forNavigationTitleText **", comment: "")
        }
        setupTitleView(withTitle: customNavigationTitle, withSubtitle: subtitleText)
    }

}
