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

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
