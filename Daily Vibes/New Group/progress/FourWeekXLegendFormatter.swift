//
//  FourWeekXLegendFormatter.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-20.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

// from https://d.pr/39B0Xf

import Foundation
import Charts

public class FourWeekXLegendFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM"
        //        dateFormatter.dateStyle = .short
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var datecompo = DateComponents()
        
        datecompo.year = Date().year
        datecompo.day = Int(value)
        
        let cal = Calendar.current
        
        guard let date = cal.date(from: datecompo) else {
            fatalError("need dat date component so I failed because of that need")
        }
        
        let result = dateFormatter.string(from: date)
        
        return result
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
