//
//  DVProgressViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import Charts
import SwiftTheme

class DVProgressViewController: ThemableViewController {
    
    @IBOutlet private weak var performanceTableView: UITableView!
    @IBOutlet private weak var tagsTableView: UITableView!
    @IBOutlet private weak var lineChartView: LineChartView!
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var longtermBarChartView: BarChartView!
    
    private var store = CoreDataManager.store
    
//    private var dvTagsVM = [DVTagViewModel]()
    
    private var streaks = [Streak]() {
        didSet {
            if let firstStreak = streaks.first {
                numDaysInARow = Int(firstStreak.currentDaysInARow)
                recordDaysInARow = Int(firstStreak.recordDaysInARow)
            }
        }
    }
    
    private var numDaysInARow: Int = 0
    private var recordDaysInARow: Int = 0
    private var totalNumTodoItemTasks: Int = 0
    
    private var fromDate: Date?
    private var toDate: Date?
    
    var completedTodoItems = [DVTodoItemTaskViewModel]()
    
    lazy var dvdates : [Date] = {
        var dates = [Date]()
        
        completedTodoItems.forEach { todo in
            guard todo.isCompleted == true else {
                fatalError("faileeeddddddddddddd DVProgressViewController completedTodoItems")
            }
            
            if !dates.contains { date in
                return Calendar.current.isDate(date, equalTo: todo.completedAt!, toGranularity: .day)
                } {
                dates.append(todo.completedAt!)
            }
        }
        
//        print("setting fromDdate to \t \(String(describing: dates.first))")
        fromDate = dates.first
        
        return dates
    }()
    
    lazy var dvdatesCounter : [Double] = {
        var datesCounter = [Double]()
        
        for date in dvdates {
            let filteredByDateValue = completedTodoItems.filter({ todo in
                return Calendar.current.isDate(date, equalTo: todo.completedAt!, toGranularity: .day)
            })
            
            let counts = filteredByDateValue.count
            datesCounter.append(Double(counts))
        }
        
        return datesCounter
    }()
    
    lazy var graphData : [Date:Double] = {
        print("setting graphData dictionary")
        
        let dictionary = Dictionary(uniqueKeysWithValues: zip(dvdates, dvdatesCounter))
        
        return dictionary
    }()
    
    func setupChart() {
        if !graphData.isEmpty {
            print("graphData dictionary is not empty ... getting ready to setupBarchart view")
            setupBarChart(withData: graphData)
            setuplongtermBarChart(withData: graphData)
            
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
            
            longtermBarChartView.data?.notifyDataChanged()
            longtermBarChartView.notifyDataSetChanged()
        } else {
            print("graphData is empty ... setting data to nil")
            barChartView.data = nil
            longtermBarChartView.data = nil
        }
    }
    
//    private func setupLineChart(withData data: [Date: Double]) {
//        print("START setupLineChart")
//        if data.isEmpty {
//            print("data is empty")
//            lineChartView.data = nil
//            return
//        } else {
//            print("got this much data to process : \(data.count) in setupBarchart")
//        }
//
//        var minYValue: Double = -1
//        var maxYValue: Double = 2
//
//        var dataEntries : [ChartDataEntry] = [ChartDataEntry]()
//
////        if let fromEntry = fromDate, let _sWeek = fromEntry.beginning(of: .weekOfYear) {
////            let _sWeek1970 = _sWeek.timeIntervalSince1970
//////            let startDate = fromEntry.subtract(days: 1)
//////            dataEntries.append(BarChartDataEntry(x: Double(startDate.timeIntervalSince1970), y: Double(0)))
////            dataEntries.append(ChartDataEntry(x: Double(_sWeek1970), y: Double(0)))
////        }
//
//        let ___date = Date()
//
//
//        var _data : [ Date:Double ] = [ Date:Double ]()
//
//        for (key, value) in dvdatesCounter.enumerated() {
//            maxYValue = value > maxYValue ? Double(value) : Double(maxYValue)
//            minYValue = value > minYValue ? Double(minYValue) : Double(value)
//
//            let dayDiff = dvdates[key].days(between: ___date)
//
//            if (dayDiff <= 28) {
////                let encoded = dvdates[key].timeIntervalSince1970
//                let date = dvdates[key]
//
////                print("\t encoded: \(encoded) \t date: \(date)")
//
//                _data[date] = value
//            }
//
//        }
//
//        let sorted = _data.sorted { (dataitem1, dataitem2) -> Bool in
//            return dataitem1.key < dataitem2.key
//        }
//
////        var prev = 0;
////        var curr = 0;
//
//        var weekTotalNum = 0.0;
//        var weekTotalCounter = 0;
//        var weekAvg = 0.0;
//
//        let ____now = Date()
//        var weekStart1970Value = ____now.timeIntervalSince1970
//        var endofweek =  ____now.end(of: .weekOfYear)?.endTime()
//        var weekEnd1970Value : TimeInterval = endofweek?.timeIntervalSince1970 ?? ____now.timeIntervalSince1970
//
//        var lastindex = 0
//        var lastvalue = 0.0
//
//        if let weekDate = sorted.first?.key {
//            var weekNum = weekDate.weekOfYear
//
//            if let weekstart = weekDate.beginning(of: .weekOfYear)?.startTime().timeIntervalSince1970 {
//                weekStart1970Value = weekstart
//            }
//
//            if let weekend = weekDate.end(of: .weekOfYear)?.endTime().timeIntervalSince1970 {
//                weekEnd1970Value = weekend
//            }
////            weekStart1970Value = sorted.first?.key.st
//
//            let datasetenumerated = sorted.enumerated()
////            var lastoffset = 0
//
//            for item in datasetenumerated {
//                let element = item.element
//                let date = element.key
//                let value = element.value
//
//                dataEntries.append(ChartDataEntry(x: Double(item.offset), y: value))
//                lastvalue = value
//                lastindex = item.offset
//            }
//
////            for (date, value) in sorted {
////                let __date = date.startTime()
////                let date1970value = __date.timeIntervalSince1970
////
//////                if __date.weekOfYear == weekNum {
//////                    weekTotalCounter += 1
//////                    weekTotalNum += value
//////
//////                    let tempweekAvg = weekTotalNum / Double(weekTotalCounter)
//////
//////                    weekAvg = tempweekAvg > weekAvg ? tempweekAvg : weekAvg
//////                    //                print("weekTotalNum: \(weekTotalNum), weekNum: \(weekNum), currentWeek: \(__date.weekOfYear)")
//////                } else {
////////                    print("-weekTotalNum: \(weekTotalNum), weekNum: \(weekNum), currentWeek: \(__date.weekOfYear)")
//////                    // add to data
//////
////////                    print("end of week = \(endofweek ?? nil) and the weekavg = \(weekAvg) and entries = \(weekTotalCounter)")
//////                    dataEntries.append(ChartDataEntry(x: Double(weekEnd1970Value), y: weekTotalNum))
//////
//////                    if let weekstart = __date.beginning(of: .weekOfYear)?.startTime().timeIntervalSince1970 {
//////                        weekStart1970Value = weekstart
//////                    }
//////
//////                    if let weekend = __date.end(of: .weekOfYear)?.endTime().timeIntervalSince1970 {
//////                        endofweek = __date.end(of: .weekOfYear)?.endTime()
//////                        weekEnd1970Value = weekend
//////                    }
//////
//////                    maxYValue = weekTotalNum > maxYValue ? Double(weekTotalNum) : Double(maxYValue)
//////                    // reset data
//////                    weekTotalNum = 0
//////                    weekNum = __date.weekOfYear
//////                    weekTotalNum += value
//////
//////                    weekTotalCounter = 0
//////                    weekTotalCounter += 1
////////                    weekTotalNum += value
//////
//////                    let tempweekAvg = weekTotalNum / Double(weekTotalCounter)
//////
//////                    weekAvg = tempweekAvg > weekAvg ? tempweekAvg : weekAvg
//////                }
////
//////                print("date: \(date), start: \(__date), date1970: \(date1970value), value: \(value), week: \(__date.weekOfYear)")
////
////                dataEntries.append(ChartDataEntry(x: Double(date1970value), y: value))
////                lastvalue = value
////            }
//
////            print("end of week = \(endofweek ?? nil)")
////            dataEntries.append(ChartDataEntry(x: Double(weekEnd1970Value), y: weekTotalNum))
////            dataEntries.append(ChartDataEntry(x: Double(____now.endTime().timeIntervalSince1970), y: weekTotalNum))
////            print("dates from : \(weekDate) to \(____now.endTime())")
//        }
//
////        let sx = Date().add(days: 1).startTime().timeIntervalSince1970
//        dataEntries.append(ChartDataEntry(x: Double(lastindex+1), y: Double(lastvalue)))
//
//        print("28 days : \(dataEntries.count)")
//
////        print("maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
//        maxYValue = maxYValue + 1
//        print("incremented maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
//
//        numEntries = dataEntries.count
//
//        let colorString = "Global.barTextColor"
//        let barChartDataSetColorString = ThemeManager.value(for: colorString) as? String
//        let barChartLabelColor = UIColor.from(hex: barChartDataSetColorString!)!
//
////        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "BarChartDataSet")
//        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "28 days")
////        lineChartDataSet.colors = ChartColorTemplates.pastel()
//        lineChartDataSet.lineWidth = 1
//        lineChartDataSet.drawCircleHoleEnabled = false
//        lineChartDataSet.mode = .stepped
////        lineChartDataSet.mode = .cubicBezier
////        lineChartDataSet.cubicIntensity = 0.2
//
//        lineChartDataSet.drawFilledEnabled = true
////        lineChartDataSet.fillAlpha = 0.75
//
//        lineChartDataSet.setCircleColor(barChartLabelColor)
//        lineChartDataSet.setColor(barChartLabelColor)
////        lineChartDataSet.circleRadius = 3
//        lineChartDataSet.circleRadius = 0
//
//        let lineChartData = LineChartData(dataSet: lineChartDataSet)
//        lineChartData.setDrawValues(false)
//
//        let colorStringID = "Global.placeholderColor"
//        let gridColorString = ThemeManager.value(for: colorStringID) as? String
//        let gridColorStringUIColor = UIColor.from(hex: gridColorString!)!
//
//        let xAxis = lineChartView.xAxis
////        xAxis.valueFormatter = DateValueFormatter()
//        xAxis.labelPosition = .bottom
//        xAxis.labelTextColor = barChartLabelColor
//        xAxis.drawGridLinesEnabled = true
//        xAxis.gridLineDashLengths = [5, 5]
////        xAxis.axisLineDashLengths = [5, 5]
//        xAxis.axisLineColor = barChartLabelColor
////        xAxis.granularityEnabled = true
////        xAxis.granularity = 2.0
////        xAxis.granularity = (86400/2)
//
//
////        let ll1 = ChartLimitLine(limit: maxYValue, label: "Upper Limit")
////        ll1.lineWidth = 2
////        ll1.lineDashLengths = [5, 5]
////        ll1.labelPosition = .rightTop
////        ll1.valueFont = .systemFont(ofSize: 10)
//
////        let ll2 = ChartLimitLine(limit: minYValue, label: "Lower Limit")
////        ll2.lineWidth = 2
////        ll2.lineDashLengths = [5,5]
////        ll2.labelPosition = .rightBottom
////        ll2.valueFont = .systemFont(ofSize: 10)
//
//        let yAxis = lineChartView.rightAxis
////        yAxis.removeAllLimitLines()
////        yAxis.addLimitLine(ll2)
////        yAxis.addLimitLine(ll1)
//        yAxis.axisMaximum = maxYValue + 1
//        yAxis.axisMinimum = -0.5
//        yAxis.labelTextColor = barChartLabelColor
////        yAxis.drawGridLinesEnabled = false
//        yAxis.gridColor = gridColorStringUIColor
//        yAxis.axisLineColor = barChartLabelColor
//        yAxis.gridLineDashLengths = [5, 5]
////        yAxis.axisLineDashLengths = [5, 5]
//        yAxis.granularityEnabled = true
//        yAxis.granularity = 1.0
////        yAxis.drawLimitLinesBehindDataEnabled = false
//
//        lineChartView.theme_backgroundColor = "Global.barTintColor"
//        lineChartView.theme_tintColor = "Global.barTextColor"
//        lineChartView.scaleXEnabled = false
//        lineChartView.scaleYEnabled = false
//        lineChartView.pinchZoomEnabled = false
//        lineChartView.doubleTapToZoomEnabled = false
//        lineChartView.highlighter = nil
//        lineChartView.rightAxis.enabled = true
//        lineChartView.leftAxis.enabled = false
////        lineChartView.xAxis.enabled = false
//
//        lineChartView.chartDescription?.enabled = false
//        lineChartView.legend.enabled = true
//        lineChartView.legend.textColor = barChartLabelColor
//
////        print("barchartview.data = linechartdata")
//        lineChartView.data = lineChartData
////        lineChartView.chartDescription = "28 days"
//        print("END setupLineChart")
//    }
    
    // TODO:
    // idea prepoluate data for past 7 days
    // then for each item in the data check if it is in one of the days in the data set
    // and simply add that value ... otherwise leave the value at 0
    
    lazy var lastweek : [Date:Double] = {
        let today = Date()
        let starttoday = today
        
        let startThisWeek = starttoday.beginning(of: .weekOfMonth)?.startTime()
        let endThisWeek = starttoday.end(of: .weekOfMonth)?.endTime()
        
//        print("lastweek")
//        print("start of week : \(startThisWeek) || end of week : \(endThisWeek)")
        
        guard var curr = startThisWeek else {
            fatalError("need start of this week")
        }
        
        var data : [Date:Double] = [Date:Double]()
        
        while curr < endThisWeek {
            data.updateValue(0, forKey: curr)
            curr = curr.add(days: 1)
        }
        
//        print("lastweek data count : \(data.count)")
        
        return data
    }()
    
    lazy var lastfourweeks : [Date:Double] = {
        let today = Date()
        
        let twentyeightweeksagostart = today.subtract(days:28).startTime()
        let twentyeightweeksagoend = today.endTime()
        
//        print("lastfourweeks")
//        print("starting this data at : \(twentyeightweeksagostart) until \(twentyeightweeksagoend)")
        
        var data : [Date:Double] = [Date:Double]()
        
        var currDate = twentyeightweeksagostart
        
        while currDate < twentyeightweeksagoend {
//            print("value for currDate in lastfourweeks: \(currDate)")
            data.updateValue(0, forKey: currDate)
            currDate = currDate.add(days:1)
        }
        
//        print("lastfourweeks data count : \(data.count)")
        
        return data
    }()
    
//    var startOfWeek: Date {
//        let cal = Calendar.current
//        let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
//        return cal.date(from: components)!
//    }
    
    private func setuplongtermBarChart(withData data: [Date: Double]) {
        print("START setuplongtermBarChart")
        if data.isEmpty {
            print("data is empty")
            barChartView.data = nil
            return
        } else {
            print("got this much data to process : \(data.count) in setupBarchart")
        }
        
        var minYValue: Double = -1
        var maxYValue: Double = 2
        
        var barChartDataEntries : [BarChartDataEntry] = [BarChartDataEntry]()
        
        let ___date = Date()
        
//        guard let ___dateStartOfWeek = ___date.beginning(of: .weekOfYear)?.startTime() else {
//            fatalError("need start of week")
//        }
//
//        guard let ___dateEndOfWeek = ___date.end(of: .weekOfYear)?.endTime() else {
//            fatalError("need end of week")
//        }
        
        var rawBarChartData : [ Date:Double ] = [ Date:Double ]()
        
        for (key, value) in dvdatesCounter.enumerated() {
            maxYValue = value > maxYValue ? Double(value) : Double(maxYValue)
            minYValue = value > minYValue ? Double(minYValue) : Double(value)
            
            let dayDiff = dvdates[key].days(between: ___date)
            
            //            if (___dateStartOfWeek <= dvdates[key]) && (dvdates[key] <= ___dateEndOfWeek) {
            //                let date = dvdates[key]
            //                rawBarChartData[date] = value
            //            }
            
            if (dayDiff <= 28) {
                let date = dvdates[key]
                rawBarChartData[date] = value
            }
            
        }
        
        let sorted = rawBarChartData.sorted { (dataitem1, dataitem2) -> Bool in
            return dataitem1.key < dataitem2.key
        }
        
        for item in sorted {
            for days in lastfourweeks {
                if days.key.isSameDay(as: item.key) {
                    
//                    let daynumber = days.key.
                    
//                    let cal = Calendar.current
//                    let day = cal.ordinality(of: .day, in: .year, for: days.key)
                    
                    
//                    print("adding value, \(item.value), for day, \(days.key), day number, \(days.key.yearDayNumber()), day, \(day)")
                    lastfourweeks.updateValue(item.value, forKey: days.key)
                }
            }
        }
        
//        var weekTotalNum = 0.0;
//        var weekTotalCounter = 0;
//        var weekAvg = 0.0;
        
//        let ____now = Date()
//        var weekStart1970Value = ____now.timeIntervalSince1970
//        let endofweek =  ____now.end(of: .weekOfYear)?.endTime()
//        var weekEnd1970Value : TimeInterval = endofweek?.timeIntervalSince1970 ?? ____now.timeIntervalSince1970
//
//        var lastvalue = 0.0
//        var lastindex = 0
        
//        if let weekDate = sorted.first?.key {
//            //            var weekNum = weekDate.weekOfYear
//
//            if let weekstart = weekDate.beginning(of: .weekOfYear)?.startTime().timeIntervalSince1970 {
//                weekStart1970Value = weekstart
//            }
//
//            if let weekend = weekDate.end(of: .weekOfYear)?.endTime().timeIntervalSince1970 {
//                weekEnd1970Value = weekend
//            }
//
//            let enumerated = sorted.enumerated()
//
//            for item in enumerated {
//                let element = item.element
//                let date = element.key
//                let value = element.value
//
//                barChartDataEntries.append(BarChartDataEntry(x: Double(item.offset), y: value))
//                lastvalue = value
//                lastindex = item.offset
//            }
//
//            //            for (date, value) in sorted {
//            //                let __date = date.startTime()
//            //                let date1970value = __date.timeIntervalSince1970
//            //
//            //                barChartDataEntries.append(BarChartDataEntry(x: Double(date1970value), y: value))
//            //                lastvalue = value
//            //            }
//        }
        
//        barChartDataEntries.append(BarChartDataEntry(x: Double(lastindex + 1), y: Double(lastvalue)))
        
        let lastfourweekssorted = lastfourweeks.sorted { (dataitem1, dataitem2) -> Bool in
            return dataitem1.key < dataitem2.key
        }
        
        for item in lastfourweekssorted.enumerated() {
            let element = item.element
//            let date = element.key
            let value = element.value
            
//            print("adding value to barchartdataentries : \(item.offset), value: \(element.value), date: \(element.key)")
            let cal = Calendar.current
            
            if let day = cal.ordinality(of: .day, in: .year, for: element.key) {
                barChartDataEntries.append(BarChartDataEntry(x: Double(day), y: value, data: element.key.timeIntervalSince1970 as AnyObject))
            }
//            lastvalue = value
        }
        
//        print("28 day dates : \(barChartDataEntries.count)")
        
        //        print("maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
        maxYValue = maxYValue + 1
        //        print("incremented maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
        
        numEntries = barChartDataEntries.count
        
        let colorString = "Global.barTextColor"
        let barChartDataSetColorString = ThemeManager.value(for: colorString) as? String
        let barChartLabelColor = UIColor.from(hex: barChartDataSetColorString!)!
        
        let barChartDataSet = BarChartDataSet(values: barChartDataEntries, label: "28 days")
        barChartDataSet.setColor(barChartLabelColor)
//        barChartDataSet.colors = ChartColorTemplates.
        //        barChartDataSet.barBorderColor = barChartLabelColor
        //        barChartDataSet.tint
        
        let barChartData = BarChartData(dataSet: barChartDataSet)
        barChartData.setDrawValues(false)
        //        barChartData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
//        barChartData.barWidth = 0.45
        //        barChartData.disla
        
        let colorStringID = "Global.placeholderColor"
        let gridColorString = ThemeManager.value(for: colorStringID) as? String
        let gridColorStringUIColor = UIColor.from(hex: gridColorString!)!
        
        let xAxis = longtermBarChartView.xAxis
        //        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = barChartLabelColor
        xAxis.drawGridLinesEnabled = true
        xAxis.gridLineDashLengths = [5, 5]
        xAxis.axisLineColor = barChartLabelColor
        xAxis.granularityEnabled = true
        xAxis.granularity = 4
        xAxis.labelCount = barChartDataEntries.count
        xAxis.valueFormatter = FourWeekXLegendFormatter()
        
        let yAxis = longtermBarChartView.rightAxis
        //        yAxis.axisMaximum = maxYValue + 1
        yAxis.axisMinimum = -0.5
        yAxis.labelTextColor = barChartLabelColor
        yAxis.gridColor = gridColorStringUIColor
        yAxis.axisLineColor = .clear
        yAxis.gridLineDashLengths = [5, 5]
        yAxis.granularityEnabled = true
        yAxis.granularity = 1.0
        
        longtermBarChartView.theme_backgroundColor = "Global.barTintColor"
        longtermBarChartView.theme_tintColor = "Global.barTextColor"
        longtermBarChartView.scaleXEnabled = false
        longtermBarChartView.scaleYEnabled = false
        longtermBarChartView.pinchZoomEnabled = false
        longtermBarChartView.doubleTapToZoomEnabled = false
        longtermBarChartView.highlighter = nil
        longtermBarChartView.rightAxis.enabled = true
        longtermBarChartView.leftAxis.enabled = false
        //
        longtermBarChartView.chartDescription?.enabled = false
        longtermBarChartView.legend.enabled = true
        longtermBarChartView.legend.textColor = barChartLabelColor
        
        longtermBarChartView.fitBars = true
        longtermBarChartView.data = barChartData
        print("END setuplongtermBarChart")
    }
    
    private func setupBarChart(withData data: [Date: Double]) {
        print("START setupBarChart")
        if data.isEmpty {
            print("data is empty")
            barChartView.data = nil
            return
        } else {
            print("got this much data to process : \(data.count) in setupBarchart")
        }
        
        var minYValue: Double = -1
        var maxYValue: Double = 2
        
        var barChartDataEntries : [BarChartDataEntry] = [BarChartDataEntry]()
        
        let ___date = Date()
        
        guard let ___dateStartOfWeek = ___date.beginning(of: .weekOfYear)?.startTime() else {
            fatalError("need start of week")
        }
        
        guard let ___dateEndOfWeek = ___date.end(of: .weekOfYear)?.endTime() else {
            fatalError("need end of week")
        }
        
        var rawBarChartData : [ Date:Double ] = [ Date:Double ]()
        
        for (key, value) in dvdatesCounter.enumerated() {
            maxYValue = value > maxYValue ? Double(value) : Double(maxYValue)
            minYValue = value > minYValue ? Double(minYValue) : Double(value)
            
            if (___dateStartOfWeek <= dvdates[key]) && (dvdates[key] <= ___dateEndOfWeek) {
                let date = dvdates[key]
                rawBarChartData[date] = value
            }
        }
        
        let sorted = rawBarChartData.sorted { (dataitem1, dataitem2) -> Bool in
            return dataitem1.key < dataitem2.key
        }
        
        // go through the week data
        
//        for item in sorted {
//            for dayitems in lastweek {
//                if dayitems.key.isSameDay(as: item.key) {
////                    dayitems.value = item.value
////                    print("adding value : \(item.value) for day : \(dayitems.key)")
//                    lastweek.updateValue(item.value, forKey: dayitems.key)
//                }
//            }
//        }
        
        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
            for day in lastweek {
                lastweek.updateValue(Double(Float.random(in: 1..<9)), forKey: day.key)
            }
        } else {
            for item in sorted {
                for dayitems in lastweek {
                    if dayitems.key.isSameDay(as: item.key) {
                        //                    dayitems.value = item.value
                        //                    print("adding value : \(item.value) for day : \(dayitems.key)")
                        lastweek.updateValue(item.value, forKey: dayitems.key)
                    }
                }
            }
        }
        
        let lastweeksorted = lastweek.sorted { (dataitem1, dataitem2) -> Bool in
            return dataitem1.key < dataitem2.key
        }
        
        for item in lastweeksorted.enumerated() {
            let element = item.element
            let date = element.key.endTime()
            let date1970value = date.timeIntervalSince1970
            
//            barChartDataEntries.append(BarChartDataEntry(x: Double(item.offset), y: element.value))
            barChartDataEntries.append(BarChartDataEntry(x: Double(item.offset), y: element.value, data: date1970value as AnyObject))
        }

//        barChartDataEntries.append(BarChartDataEntry(x: Double(lastindex + 1), y: Double(lastvalue)))
        
//        print("7 day dates : \(barChartDataEntries.count)")
        
        //        print("maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
        maxYValue = maxYValue + 1
//        print("incremented maxYvalue = \(maxYValue) \t minYValue = \(minYValue)")
        
        numEntries = barChartDataEntries.count
        
        let colorString = "Global.barTextColor"
        let barChartDataSetColorString = ThemeManager.value(for: colorString) as? String
        let barChartLabelColor = UIColor.from(hex: barChartDataSetColorString!)!
        
        let barChartDataSet = BarChartDataSet(values: barChartDataEntries, label: "This week")
//        barChartDataSet.colors = ChartColorTemplates.material()
        barChartDataSet.setColor(barChartLabelColor)
//        barChartDataSet.barBorderColor = barChartLabelColor
//        barChartDataSet.tint

        let barChartData = BarChartData(dataSet: barChartDataSet)
        barChartData.setDrawValues(false)
//        barChartData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        barChartData.barWidth = 0.45
//        barChartData.disla
        
        let colorStringID = "Global.placeholderColor"
        let gridColorString = ThemeManager.value(for: colorStringID) as? String
        let gridColorStringUIColor = UIColor.from(hex: gridColorString!)!
        
        let xAxis = barChartView.xAxis
//        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = barChartLabelColor
        xAxis.drawGridLinesEnabled = true
        xAxis.gridLineDashLengths = [5, 5]
        xAxis.axisLineColor = barChartLabelColor
        xAxis.granularityEnabled = true
//        xAxis.granularity = 86400
//        xAxis.labelCount = barChartDataEntries.count
        xAxis.valueFormatter = SevenDayAxisFormatter()

        let yAxis = barChartView.rightAxis
//        yAxis.axisMaximum = maxYValue + 1
        yAxis.axisMinimum = -0.5
        yAxis.labelTextColor = barChartLabelColor
        yAxis.gridColor = gridColorStringUIColor
        yAxis.axisLineColor = .clear
        yAxis.gridLineDashLengths = [5, 5]
        yAxis.granularityEnabled = true
        yAxis.granularity = 1.0
        
        barChartView.theme_backgroundColor = "Global.barTintColor"
        barChartView.theme_tintColor = "Global.barTextColor"
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlighter = nil
        barChartView.rightAxis.enabled = true
        barChartView.leftAxis.enabled = false
//
        barChartView.chartDescription?.enabled = false
        barChartView.legend.enabled = true
        barChartView.legend.textColor = barChartLabelColor
        
        barChartView.fitBars = true
        barChartView.data = barChartData
        print("END setupBarChart")
    }
    
    private var numCompletedTask: Int = 0
    private var numEntries: Int = 0
    
    private var performanceDataWLabels = [
        NSLocalizedString("Current streak", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Current streak **", comment: ""),
        NSLocalizedString("Longest streak", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Longest streak **", comment: ""),
        NSLocalizedString("Total completed tasks", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Total completed tasks **", comment: ""),
        NSLocalizedString("Total tasks", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Total tasks **", comment: ""),
        NSLocalizedString("Days recorded", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Days recorded **", comment: "")
    ]
    
    private var performanceDataLabels: [String]?
    
    override func setupNavigationTitleText(title text: String?) {
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
            let yearProgressCompletedString = NSLocalizedString("completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND completed **", comment: "")
            let yearProgressString = "\(yearProgressLocalizedString): \(yearProgress)% \(yearProgressCompletedString)"
            let todaysDateString = dateFormatter.string(from: todaysDate)
            
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
            let _title:NSMutableAttributedString = NSMutableAttributedString(string: todaysDateString, attributes: attrs)
            
        let __attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
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
    
    fileprivate func setupDataStuffsz() {
        store.fetchStreaks()
        
        streaks = store.fetchedStreaks
        
//        store.fetchTagsViewModel()
//        dvTagsVM = store.dvTagsVM
        
        if let completedTasks = store.getCompletedTodoItemTasks(ascending: true) {
            if completedTasks.count > 0 {
                if let totalCount = store.getTodoItemTaskCount() {
                    totalNumTodoItemTasks = totalCount
                }
                numCompletedTask = completedTasks.count
                performanceDataLabels = performanceDataWLabels
            } else {
                performanceDataLabels = nil
            }
            completedTodoItems = completedTasks
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toDate = Date()
        
        setupDataStuffsz()
        setupChart()
        
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.theme_backgroundColor = "Global.backgroundColor"
        
        setupTheming()
        reloadTableViews()
        
        barChartView.setNeedsLayout()
    }
    
    private func setupTheming() {
        performanceTableView.theme_backgroundColor = "Global.barTintColor"
        performanceTableView.theme_separatorColor = "ListViewController.separatorColor"
        performanceTableView.tableFooterView = UIView(frame: .zero)
        
//        tagsTableView.theme_backgroundColor = "Global.backgroundColor"
//        tagsTableView.theme_separatorColor = "ListViewController.separatorColor"
//        tagsTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleString = "Progress"
        setupNavigationTitleText(title: titleString)
        
        let missingdatatxt = NSLocalizedString("No data yet, see what happens when you complete a task", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND No data yet, see what happens when you complete a task", comment: "")
//        lineChartView.noDataText = missingdatatxt
//        lineChartView.delegate = self
        longtermBarChartView.noDataText = missingdatatxt
        barChartView.noDataText = missingdatatxt
//        barChartView.delegate = self
        
        performanceTableView.delegate = self
//        tagsTableView.delegate = self
        
//        barChartView.animate(xAxisDuration: 2.5)
//        barChartView.setNeedsDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func reloadTableViews() {
        print("calling reloadtableviews")
        self.performanceTableView.reloadData()
//        self.tagsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showMainTableVCFilteredByTag" {
////            guard let mainTVC = segue.destination as? TodoItemsTableViewController else {
////                fatalError("should be a navigation controller")
////            }
//
//            guard let mainTVC = segue.destination as? TodoItemsTableViewController else { fatalError("should be TodoItemsTableViewController") }
//
////            if let selectedIndexPath = tagsTableView.indexPathForSelectedRow {
////                let tag = dvTagsVM[selectedIndexPath.row]
////                store.filteredTag = tag
////                mainTVC.hidesBottomBarWhenPushed = true
////            }
//        }
    }
}

extension DVProgressViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == tagsTableView {
//            return dvTagsVM.count
//        }
        if tableView == performanceTableView {
            if let count = performanceDataLabels?.count {
                return count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ThemableBaseTableViewCell!
        if tableView == performanceTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultPerformanceCell") as? ThemableBaseTableViewCell
            if let performanceDataWLabels = performanceDataLabels, performanceDataWLabels.count > 0 {
                let label = performanceDataWLabels[indexPath.row]
                cell.textLabel?.text = label
                
                switch indexPath.row {
                case 0:
                    cell.detailTextLabel?.text = "\(numDaysInARow)"
                case 1:
                    cell.detailTextLabel?.text = "\(recordDaysInARow)"
                case 2:
                    cell.detailTextLabel?.text = "\(numCompletedTask)"
                case 3:
                    cell.detailTextLabel?.text = "\(totalNumTodoItemTasks)"
                case 4:
                    cell.detailTextLabel?.text = "\(numEntries)"
                default:
                    cell.detailTextLabel?.text = ""
                }
            }
        }
//        if tableView == tagsTableView {
//
////            let tag = tags[indexPath.row] as Tag
//            let tag = dvTagsVM[indexPath.row]
////            let totalCount = tag.todos?.count ?? -1
////            let totalCount = tag.tagged.count
//
//            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTagsCell") as? ThemableBaseTableViewCell
//            cell.textLabel?.text = tag.label
//            cell.imageView?.image = #imageLiteral(resourceName: "tagsFilledinCircle")
//            cell.detailTextLabel?.text = ""
//
//            cell.accessoryType = .disclosureIndicator
//        }
        
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.textLabel?.theme_backgroundColor = "Global.barTintColor"
        cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        cell.detailTextLabel?.theme_backgroundColor = "Global.barTintColor"
        
        return cell
    }
    
    
}
