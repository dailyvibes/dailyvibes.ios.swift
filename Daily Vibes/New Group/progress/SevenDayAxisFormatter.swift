//
//  DateValueFormatter.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-20.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

// from https://d.pr/39B0Xf

import Foundation
import Charts

public class SevenDayAxisFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "d"
//        dateFormatter.dateStyle = .short
    }
    
    lazy var sevendaydata : [Double:String] = {
        var data = [Double:String]()
        
        let sun = NSLocalizedString("Sunday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Sunday **", comment: "")
        let mon = NSLocalizedString("Monday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Monday **", comment: "")
        let tue = NSLocalizedString("Tuesday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Tuesday **", comment: "")
        let wed = NSLocalizedString("Wednesday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Wednesday **", comment: "")
        let thu = NSLocalizedString("Thursday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Thursday **", comment: "")
        let fri = NSLocalizedString("Friday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Friday **", comment: "")
        let sat = NSLocalizedString("Saturday", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Saturday **", comment: "")
        
        data.updateValue(sun[0], forKey: 0)
        data.updateValue(mon[0], forKey: 1)
        data.updateValue(tue[0], forKey: 2)
        data.updateValue(wed[0], forKey: 3)
        data.updateValue(thu[0], forKey: 4)
        data.updateValue(fri[0], forKey: 5)
        data.updateValue(sat[0], forKey: 6)
        
        return data
    }()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return sevendaydata[value] ?? ""
    }
    
    public func stringForValue(
        _ value: Double,
        entry: BarChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
//        return format(value: value)
        guard let time = entry.data as? TimeInterval else {
            fatalError("we always set this data as a timeinterval so we can decode it here ... so not good ...")
        }
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }
}
