//
//  LikertScaleItemDetailsTableViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-15.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class LikertScaleItemDetailsTableViewController: ThemableTableViewController {
    
    private var isBrandNewMode: Bool = true
    private var tempCreatedAtDateHolder: Date?
    
    weak var date: LikertItemDate!
    weak var entry: LikertItemEntry! {
        didSet{
            print("entry was set")
        }
    }
    
    private var mngdctx = CoreDataManager.store.context
    
    lazy var saveBtn: UIBarButtonItem = {
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        saveBtn.isEnabled = false
        
        return saveBtn
    }()
    
    var data: [LikertScaleItem] = [LikertScaleItem]() {
        didSet {
            if (data.count == 7) {
                self.saveBtn.isEnabled = true
            } else {
                self.saveBtn.isEnabled = false
            }
        }
    }
    
    private var runningTotal: Float = 0
    
    @IBOutlet weak var mtvtnSliderValue: UILabel!
    @IBOutlet weak var mdSliderValue: UILabel!
    @IBOutlet weak var strssSliderValue: UILabel!
    @IBOutlet weak var vbsSegmentValue: UILabel!
    @IBOutlet weak var wrkSliderValue: UILabel!
    @IBOutlet weak var lfSliderValue: UILabel!
    @IBOutlet weak var hlthSliderValue: UILabel!
    
    // manual theming overwrite
    @IBOutlet weak var dateDateCell: UITableViewCell!
    @IBOutlet weak var entryDateCell: UITableViewCell!
    @IBOutlet weak var mtvtnViewCell: UITableViewCell!
    @IBOutlet weak var mtvtnLabel: UILabel!
    @IBOutlet weak var mtvtnSlider: UISlider!
    @IBOutlet weak var mdViewCell: UITableViewCell!
    @IBOutlet weak var mdLabel: UILabel!
    @IBOutlet weak var mdSlider: UISlider!
    @IBOutlet weak var strssViewCell: UITableViewCell!
    @IBOutlet weak var strssLabel: UILabel!
    @IBOutlet weak var strssSlider: UISlider!
    @IBOutlet weak var vbsViewCell: UITableViewCell!
    @IBOutlet weak var vbsLabel: UILabel!
    @IBOutlet weak var vbsSegment: UISegmentedControl!
    
    @IBOutlet weak var wrkViewCell: UITableViewCell!
    @IBOutlet weak var wrkLabel: UILabel!
    @IBOutlet weak var wrkSlider: UISlider!
    @IBOutlet weak var lfViewCell: UITableViewCell!
    @IBOutlet weak var lfLabel: UILabel!
    @IBOutlet weak var lfSlider: UISlider!
    @IBOutlet weak var hlthViewCell: UITableViewCell!
    @IBOutlet weak var hlthLabel: UILabel!
    @IBOutlet weak var hlthSlider: UISlider!
    
    
    @IBAction func mtvtnSlider(_ sender: UISlider) {
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "motivation" {
                
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "motivation"
        }
        
        var initrawValue = sender.value
        
        print("date: \(currDate) \t sectionIndex: \(sectionIndex)")
        
        let item = LikertScaleItem(context: mngdctx)
        
        item.type = "motivation"
        item.uuid = UUID()
        item.pos = 0
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.mtvtnSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.mtvtnSliderValue.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                self.mtvtnSliderValue.textColor = .whatsNewKitGreen
            }
            
            self.mtvtnSliderValue.text = symbol
        }
        
        results.append(item)
        data = results
    }
    
    @IBAction func mdSlider(_ sender: UISlider) {
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "mood" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "mood"
        }
        
        let initrawValue = sender.value
        
        let item = LikertScaleItem(context: mngdctx)
        
        item.type = "mood"
        item.uuid = UUID()
        item.pos = 1
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.mdSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.mdSliderValue.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                self.mdSliderValue.textColor = .whatsNewKitGreen
            }
            
            self.mdSliderValue.text = symbol
        }
        
        results.append(item)
        data = results
    }
    
    @IBAction func strssSlider(_ sender: UISlider) {
        
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "stress" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "stress"
        }
        
        let initrawValue = sender.value
        
        let item = LikertScaleItem(context: mngdctx)
        
        item.type = "stress"
        item.uuid = UUID()
        item.pos = 2
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.strssSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.strssSliderValue.textColor = .whatsNewKitGreen
            } else {
                symbol = "↑"
                self.strssSliderValue.textColor = .whatsNewKitRed
            }
            
            self.strssSliderValue.text = symbol
        }
        
        results.append(item)
        data = results
    }
    
    // remove rounding and only show up or down
    // do total calculation on save for date and for entry
    
    @IBAction func vbsSegmentControl(_ sender: UISegmentedControl? = nil) {
        
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "vibes" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "vibes"
        }
        
        let item = LikertScaleItem(context: mngdctx)
        
        item.type = "vibes"
        item.uuid = UUID()
        item.pos = 3
        item.entry = entry
        
        if let _sender = sender {
            switch _sender.selectedSegmentIndex {
            case 0:
                // bad vibes
                item.ratedValue = 0
                DispatchQueue.main.async {
                    self.vbsSegmentValue.textColor = .whatsNewKitRed
                    self.vbsSegmentValue.text = "↓"
                }
            case 1:
                // good vibes
                item.ratedValue = 10
                DispatchQueue.main.async {
                    self.vbsSegmentValue.textColor = .whatsNewKitGreen
                    self.vbsSegmentValue.text = "↑"
                }
            default:
                break
            }
        }
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
//        print("adding item to results")
        results.append(item)
//        print("settings data to results")
        data = results
    }
    
    @IBAction func wrkSlider(_ sender: UISlider? = nil) {
        
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "work" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "work"
        }
        
        let item = LikertScaleItem(context: mngdctx)
        
        var initrawValue: Float
        
        if let _sender = sender {
            initrawValue = _sender.value
        } else {
            initrawValue = 5
        }
        
        item.type = "work"
        item.uuid = UUID()
        item.pos = 4
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.wrkSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.wrkSliderValue.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                self.wrkSliderValue.textColor = .whatsNewKitGreen
            }
            
            self.wrkSliderValue.text = symbol
        }
        
//        print("adding item to results")
        results.append(item)
//        print("settings data to results")
        data = results
    }
    
    @IBAction func lfSlider(_ sender: UISlider? = nil) {
        
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "life" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "life"
        }
        
        let item = LikertScaleItem(context: mngdctx)
        
        var initrawValue: Float
        
        if let _sender = sender {
            initrawValue = Float(_sender.value)
        } else {
            initrawValue = Float(5)
        }
        
        item.type = "life"
        item.uuid = UUID()
        item.pos = 5
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.lfSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.lfSliderValue.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                self.lfSliderValue.textColor = .whatsNewKitGreen
            }
            
            self.lfSliderValue.text = symbol
        }
        
//        print("adding item to results")
        results.append(item)
//        print("settings data to results")
        data = results
    }
    
    @IBAction func hlthSlider(_ sender: UISlider? = nil) {
        
        var _createdAt: Date?
        
        var results = data.filter { (item) -> Bool in
            if item.type == "health" {
                _createdAt = item.createdAt
                
                runningTotal = (runningTotal - item.ratedValue)
                entry.removeFromDpoints(item)
            }
            return item.type != "health"
        }
        
        let item = LikertScaleItem(context: mngdctx)
        
        var initrawValue: Float
        
        if let _sender = sender {
            initrawValue = Float(_sender.value)
        } else {
            initrawValue = Float(5)
        }
        
        item.type = "health"
        item.uuid = UUID()
        item.pos = 6
        item.ratedValue = initrawValue
        item.entry = entry
        
        runningTotal = (runningTotal + item.ratedValue)
        entry.addToDpoints(item)
        
        if let _createdAt_ = _createdAt, _createdAt_.isInSameDay(date: currDate) {
            // if in today save that date
            print("todays date")
            item.createdAt = _createdAt_
            item.createdAtStr = dateFormatter.string(from: _createdAt_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else if let _createdat_ = _createdAt, _createdat_.isInPast {
            // if past then set that created date and set updated at for today
            print("past date")
            item.createdAt = _createdat_
            item.createdAtStr = dateFormatter.string(from: _createdat_)
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        } else {
            // default to right now
            print("default date -- now")
            
            print("_createdAt: \(String(describing: _createdAt)) and currDate: \(currDate)")
            
            item.createdAt = currDate
            item.createdAtStr = sectionIndex
            item.updatedAt = currDate
            item.updatedAtStr = sectionIndex
        }
        
        DispatchQueue.main.async {
            
            var symbol: String = "↑"
            
            let magicfloat = Float(5.0)
            
            if initrawValue.isEqual(to: magicfloat) {
                symbol = "="
                self.hlthSliderValue.textColor = .orange
            } else if initrawValue.isLess(than: magicfloat) {
                symbol = "↓"
                self.hlthSliderValue.textColor = .whatsNewKitRed
            } else {
                symbol = "↑"
                self.hlthSliderValue.textColor = .whatsNewKitGreen
            }
            
            self.hlthSliderValue.text = symbol
        }
        
//        print("adding item to results")
        results.append(item)
//        print("settings data to results")
        data = results
    }
    
    lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    lazy var currDate : Date = {
        
        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
            let dtformatter = DateFormatter()
            dtformatter.timeStyle = .short
            
            let cal = Calendar.current
            var customtime = DateComponents()
            let now = Date()
            
            customtime.year = now.year
            customtime.day = now.day
            customtime.month = now.month
            customtime.hour = 09
            customtime.minute = 41
            
            guard let minimumdate = cal.date(from: customtime) else { fatalError("failed to set date at 9:41 like I wanted") }
            return minimumdate
        } else {
            let date = Date()
            
            return date
        }
    }()
    
    lazy var sectionIndex: String = {
        let _date = currDate
        let _formattedDate = dateFormatter.string(from: _date)
        
//        print("section index should be : \(_formattedDate)")
        
        return _formattedDate
    }()
    
    fileprivate func makeFirstDayEntry() {
        // need to start using today's date
        
//        print("making a new date using Date()")
        
        let newDate = LikertItemDate(context: mngdctx)
        
        newDate.uuid = UUID()
        newDate.createdAt = currDate
        newDate.createdAtStr = sectionIndex
        newDate.updatedAt = currDate
        newDate.updatedAtStr = sectionIndex
        
        date = newDate
        
//        print("making a new entry with sectionIndex: \(sectionIndex)")
        let newEntry = LikertItemEntry(context: mngdctx)
        
        newEntry.uuid = UUID()
        newEntry.createdAt = currDate
        newEntry.createdAtStr = sectionIndex
        newEntry.updatedAt = currDate
        newEntry.updatedAtStr = sectionIndex
        newEntry.date = date
        
        entry = newEntry
        
//        print("adding entry to date collection")
        date.addToEntries(entry)
        
//        print("calling _dvsetupDefaultValues")
        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
            let dtformatter = DateFormatter()
            dtformatter.timeStyle = .short
            
            let cal = Calendar.current
            var customtime = DateComponents()
            let now = Date()
            
            customtime.year = now.year
            customtime.day = now.day
            customtime.month = now.month
            customtime.hour = 09
            customtime.minute = 41
            
            guard let minimumdate = cal.date(from: customtime) else { fatalError("failed to set date at 9:41 like I wanted") }
//            let timestr = dtformatter.string(from: minimumdate)
            let sectionStr = dateFormatter.string(from: minimumdate)
            
            date.createdAt = minimumdate
            date.createdAtStr = sectionStr
            date.updatedAt = minimumdate
            date.createdAtStr = sectionStr
            
            newEntry.createdAt = minimumdate
            newEntry.createdAtStr = sectionStr
            newEntry.updatedAt = minimumdate
            newEntry.updatedAtStr = sectionStr
            
            _dvsetupTESTDefaultValues()
        } else {
            _dvsetupDefaultValues()
        }
//        print("called _dvsetupDefaultValues")
    }
    
    fileprivate func setupData() {
        if date == nil {
            makeFirstDayEntry()
        } else {
//            // we are showing a display using some other date
//            print("we are showing set date of createdAt: \(String(describing: date.createdAt ?? nil)) \t createdAtStr: \(String(describing: date.createdAtStr ?? nil))")
            
            // somehow we get a state where the date is yesterdays and not set to today
            // so check if todays date
            // if todays date process as good
            // if not todays date ... make new date...
            if let createdAt = date.createdAt {
                if createdAt.isInToday {
                    if entry != nil {
                        print("and we are showing entry of createdAt: \(String(describing: entry.createdAt ?? nil)) \t createdAtStr \(String(describing: entry.createdAtStr ?? nil))")
                    } else {
//                        print("no existing entry...")
//                        print("making a new entry with sectionIndex: \(sectionIndex) and date of: \(currDate)")
                        let newEntry = LikertItemEntry(context: mngdctx)
                        
                        newEntry.uuid = UUID()
                        newEntry.createdAt = currDate
                        newEntry.createdAtStr = sectionIndex
                        newEntry.updatedAt = currDate
                        newEntry.updatedAtStr = sectionIndex
                        newEntry.date = date
                        
                        entry = newEntry
                        
//                        print("adding entry to date collection")
                        date.addToEntries(entry)
                        
//                        print("calling _dvsetupDefaultValues")
                        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
                            _dvsetupTESTDefaultValues()
                        } else {
                            _dvsetupDefaultValues()
                        }
//                        print("called _dvsetupDefaultValues")
                    }
                } else {
                    makeFirstDayEntry()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        
        setupUI()
        setupNavTitle()
    }
    
    fileprivate func setupNavTitle() {
        if entry != nil {
            guard var entryDate = entry.createdAtStr else { fatalError("entry needs a createdat") }
            
            if entryDate.isEmpty && entry.createdAt != nil {
                guard let createdatdate = entry.createdAt else { fatalError("need createdAt date object here") }
                print("empty createdAtStr but have createdAt date object")
                let createdAtDateFix = dateFormatter.string(from: createdatdate)
                
                entry.createdAtStr = createdAtDateFix
                entryDate = createdAtDateFix
            }
            
            print("entryDate = \(entryDate)")
            navigationItem.title = entryDate
            
            // setup the variables
            
            if let likertitems = entry.dpoints?.allObjects as? [LikertScaleItem] {
                if likertitems.count >= 7 {
                    isBrandNewMode = false
                }
                for item in likertitems {
                    runningTotal = (runningTotal + item.ratedValue)
                    data.append(item)
                    
                    switch item.type {
                    case "vibes":
                        let index = item.ratedValue > 5 ? 1 : 0
                        vbsSegment.selectedSegmentIndex = index
                        vbsSegmentControl(vbsSegment)
                    case "motivation":
                        mtvtnSlider.setValue(item.ratedValue, animated: true)
                        mtvtnSlider(mtvtnSlider)
                    case "mood":
                        mdSlider.setValue(item.ratedValue, animated: true)
                        mdSlider(mdSlider)
                    case "stress":
                        strssSlider.setValue(item.ratedValue, animated: true)
                        strssSlider(strssSlider)
                    case "work":
                        wrkSlider.setValue(item.ratedValue, animated: true)
                        wrkSlider(wrkSlider)
                    case "life":
                        lfSlider.setValue(item.ratedValue, animated: true)
                        lfSlider(lfSlider)
                    case "health":
                        hlthSlider.setValue(item.ratedValue, animated: true)
                        hlthSlider(hlthSlider)
                    default:
                        // do nothing
                        print("do nothing")
                    }
                }
            }
            
        }
        
//        navigationItem.title = ""
        
        if let createdat = entry.createdAt {
            let dtformatter = DateFormatter()
            dtformatter.timeStyle = .short
            
            let createdatstr = dtformatter.string(from: createdat)
            
            let dtformatter2 = DateFormatter()
            dtformatter2.dateStyle = .short
            
            let createdatdate = dtformatter2.string(from: createdat)
            
            dateDateCell.textLabel?.text = "Date"
            dateDateCell.detailTextLabel?.text = createdatdate
            entryDateCell.detailTextLabel?.theme_textColor = "Global.barTextColor"
//            entryDateCell.accessoryType = .disclosureIndicator
//            entryDateCell.accessoryView?.theme_tintColor = "Global.selectionBackgroundColor"
            
            entryDateCell.textLabel?.text = "Time"
            entryDateCell.detailTextLabel?.text = createdatstr
            entryDateCell.detailTextLabel?.theme_textColor = "Global.barTextColor"
            entryDateCell.accessoryType = .disclosureIndicator
            entryDateCell.accessoryView?.theme_tintColor = "Global.selectionBackgroundColor"
        }
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupNavigation() {
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        cancelBtn.accessibilityIdentifier = "likert_scale_item_details_cancel_btn"
        saveBtn.accessibilityIdentifier = "likert_scale_item_details_save_btn"
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.theme_barStyle = "Global.toolbarStyle"
        navigationController?.toolbar.theme_tintColor = "Global.barTextColor"
        
        setToolbarItems([cancelBtn, spacer, saveBtn], animated: true)
    }
    
    private lazy var selectionView : UIView = {
        let view = UIView(frame: .zero)
        
        view.theme_backgroundColor = "Global.selectionBackgroundColor"
        
        return view
    }()
    
    private func setupUI() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        tableView.theme_backgroundColor = "Global.backgroundColor"
        tableView.theme_separatorColor = "ListViewController.separatorColor"
        
        dateDateCell.theme_backgroundColor = "Global.barTintColor"
        dateDateCell.selectionStyle = .none
        dateDateCell.textLabel?.theme_textColor = "Global.textColor"
        dateDateCell.detailTextLabel?.theme_textColor = "Global.barTextColor"
        
        entryDateCell.theme_backgroundColor = "Global.barTintColor"
        entryDateCell.selectedBackgroundView = selectionView
//        entryDateCell.theme_tintColor = "Global.selectionBackgroundColor"
        entryDateCell.textLabel?.theme_textColor = "Global.textColor"
//        entryDateCell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        
        mtvtnViewCell.theme_backgroundColor = "Global.barTintColor"
        mtvtnViewCell.theme_tintColor = "Global.barTextColor"
        // workaround for now...
        mtvtnViewCell.selectionStyle = .none
        mtvtnLabel.theme_textColor = "Global.textColor"
        mtvtnSliderValue.theme_textColor = "Global.placeholderColor"
        mtvtnSlider.theme_backgroundColor = "Global.barTintColor"
        mtvtnSlider.theme_thumbTintColor = "Global.barTextColor"
        mtvtnSlider.minimumTrackTintColor = .whatsNewKitGreen
        mtvtnSlider.maximumTrackTintColor = .whatsNewKitRed
        
        mdViewCell.theme_backgroundColor = "Global.barTintColor"
        mdViewCell.theme_tintColor = "Global.barTextColor"
        mdViewCell.selectionStyle = .none
        mdLabel.theme_textColor = "Global.textColor"
        mdSliderValue.theme_textColor = "Global.placeholderColor"
        mdSlider.theme_backgroundColor = "Global.barTintColor"
        mdSlider.theme_thumbTintColor = "Global.barTextColor"
        mdSlider.minimumTrackTintColor = .whatsNewKitGreen
        mdSlider.maximumTrackTintColor = .whatsNewKitRed
        
        strssViewCell.theme_backgroundColor = "Global.barTintColor"
        strssViewCell.theme_tintColor = "Global.barTextColor"
        strssViewCell.selectionStyle = .none
        strssLabel.theme_textColor = "Global.textColor"
        strssSliderValue.theme_textColor = "Global.placeholderColor"
        strssSlider.theme_backgroundColor = "Global.barTintColor"
        strssSlider.theme_thumbTintColor = "Global.barTextColor"
        strssSlider.minimumTrackTintColor = .whatsNewKitRed
        strssSlider.maximumTrackTintColor = .whatsNewKitGreen
        
        vbsViewCell.theme_backgroundColor = "Global.barTintColor"
        vbsViewCell.theme_tintColor = "Global.barTextColor"
        vbsViewCell.selectionStyle = .none
        vbsLabel.theme_textColor = "Global.textColor"
        vbsSegmentValue.theme_textColor = "Global.placeholderColor"
        vbsSegment.theme_tintColor = "Global.barTextColor"
        
        // TODO: what to do about selected optiosn?
        
        wrkViewCell.theme_backgroundColor = "Global.barTintColor"
        wrkViewCell.theme_tintColor = "Global.barTextColor"
        wrkViewCell.selectionStyle = .none
        wrkLabel.theme_textColor = "Global.textColor"
        wrkSliderValue.theme_textColor = "Global.placeholderColor"
        wrkSlider.theme_backgroundColor = "Global.barTintColor"
        wrkSlider.theme_thumbTintColor = "Global.barTextColor"
        wrkSlider.minimumTrackTintColor = .whatsNewKitGreen
        wrkSlider.maximumTrackTintColor = .whatsNewKitRed
        
        lfViewCell.theme_backgroundColor = "Global.barTintColor"
        lfViewCell.theme_tintColor = "Global.barTextColor"
        lfViewCell.selectionStyle = .none
        lfLabel.theme_textColor = "Global.textColor"
        lfSliderValue.theme_textColor = "Global.placeholderColor"
        lfSlider.theme_backgroundColor = "Global.barTintColor"
        lfSlider.theme_thumbTintColor = "Global.barTextColor"
        lfSlider.minimumTrackTintColor = .whatsNewKitGreen
        lfSlider.maximumTrackTintColor = .whatsNewKitRed
        
        hlthViewCell.theme_backgroundColor = "Global.barTintColor"
        hlthViewCell.theme_tintColor = "Global.barTextColor"
        hlthViewCell.selectionStyle = .none
        hlthLabel.theme_textColor = "Global.textColor"
        hlthSliderValue.theme_textColor = "Global.placeholderColor"
        hlthSlider.theme_backgroundColor = "Global.barTintColor"
        hlthSlider.theme_thumbTintColor = "Global.barTextColor"
        hlthSlider.minimumTrackTintColor = .whatsNewKitGreen
        hlthSlider.maximumTrackTintColor = .whatsNewKitRed
    }
    
    @objc
    func cancel(_ sender: UIBarButtonItem) {
        closeView()
    }
    
    private func closeView() {
        print("calling closeview")
        if mngdctx.hasChanges {
            print("has changes")
            mngdctx.rollback()
            print("calling rollback")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func save(_ sender: UIBarButtonItem) {
//        print("calling save")
        saveRecord()
    }
    
    private func saveRecord() {
//        print("calling saverecord")
        if data.isEmpty {
            closeView()
        }
        
        if mngdctx.hasChanges {
            print("context has changes")
            do {
                guard let _date = entry.date else {
                    fatalError("need a date")
                }
                
                
                // TODO
                // check the big total for an entry
                // check running total for this screen max (7 * 10)
                // if running total for an entry is bigger than for this screen --> set to this screen?
                // otherwise
                // remove from date running total current Entry total and add the new running total
                // remove from the entry running total current runnign total and add the new runing total
                
                let MAGICmaxScorePerLikertItem = Float(10.0)
                let MAGICnumEvaluatedLikertItems = Float(7.0)
                let MAGICapproximateMaxRunnningTotal = MAGICnumEvaluatedLikertItems * MAGICmaxScorePerLikertItem
                
                if MAGICapproximateMaxRunnningTotal.isLess(than: entry.runningTotal) {
                    entry.runningTotal = MAGICapproximateMaxRunnningTotal
                } else {
                    
                    print("\t\tBEFORE")
                    print("runningtotal: \(runningTotal), date.runningtotal: \(_date.runningTotal), entry.runningtotal: \(entry.runningTotal)")
                    
                    let dateTotal = _date.runningTotal - entry.runningTotal + runningTotal
                    let entryTotal = runningTotal
                    
                    _date.runningTotal = dateTotal
                    entry.runningTotal = entryTotal
                    
                    print("\t\tAFTER")
                    print("runningtotal: \(runningTotal), date.runningtotal: \(_date.runningTotal), entry.runningtotal: \(entry.runningTotal)")
                }
                
                try mngdctx.save()
                
                print("saved")
                
                self.dismiss(animated: true, completion: nil)
//                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
            }
        } else {
            print("context has no changes but pressed save")
            do {
                try mngdctx.save()
                self.dismiss(animated: true, completion: nil)
            } catch let error as NSError {
                print("Could not complete fetchDateEntries. \(error), \(error.userInfo)")
            }
        }
        
//        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        privateMOC.parent = mngdctx
//
//        privateMOC.perform {
//            for item in self.data {
//                guard let date = self.entry.date else {
//                    fatalError("need a date")
//                }
//
//                self.entry.date?.runningTotal = (date.runningTotal + item.ratedValue)
//                self.entry.runningTotal = (self.entry.runningTotal + item.ratedValue)
//                self.entry.addToDpoints(item)
//            }
//            do {
//                try privateMOC.save()
//                self.mngdctx.performAndWait {
//                    do {
//                        try self.mngdctx.save()
//                        self.dismiss(animated: true, completion: nil)
//                    } catch {
//                        fatalError("Failure to save context: \(error)")
//                    }
//                }
//            } catch {
//                fatalError("Failure to save context: \(error)")
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    func _dvsetupDefaultValues() {
        print("setting up default values...")
        vbsSegment.setValue(1, forKey: "selectedSegmentIndex")
        vbsSegmentControl(vbsSegment)
//        self.vbsSegment.selectedSegmentIndex = 1
//        vbsSegmentControl(vbsSegment)
        mtvtnSlider.setValue(5.0, animated: true)
        mtvtnSlider(mtvtnSlider)
        mdSlider.setValue(5.0, animated: true)
        mdSlider(mdSlider)
        strssSlider.setValue(5.0, animated: true)
        strssSlider(strssSlider)
        wrkSlider.setValue(5.0, animated: true)
        wrkSlider(wrkSlider)
        lfSlider.setValue(5.0, animated: true)
        lfSlider(lfSlider)
        hlthSlider.setValue(5.0, animated: true)
        hlthSlider(hlthSlider)
    }
    
    private func _dvsetupTESTDefaultValues() {
        print("setting up default TEXT values...")
        vbsSegment.setValue(1, forKey: "selectedSegmentIndex")
        vbsSegmentControl(vbsSegment)
        //        self.vbsSegment.selectedSegmentIndex = 1
        //        vbsSegmentControl(vbsSegment)
        mtvtnSlider.setValue(9.5, animated: true)
        mtvtnSlider(mtvtnSlider)
        mdSlider.setValue(6.5, animated: true)
        mdSlider(mdSlider)
        strssSlider.setValue(1.5, animated: true)
        strssSlider(strssSlider)
        wrkSlider.setValue(5.0, animated: true)
        wrkSlider(wrkSlider)
        lfSlider.setValue(3.5, animated: true)
        lfSlider(lfSlider)
        hlthSlider.setValue(9.0, animated: true)
        hlthSlider(hlthSlider)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == entryDateCell {
            let btnfeedback = UIImpactFeedbackGenerator()
            btnfeedback.impactOccurred()
            
            datePickerTappedForDuedateAtDateCell(at: indexPath)
        }
    }
    
    func datePickerTappedForDuedateAtDateCell(at indexPath: IndexPath) {
        let setChangeTimeStr = NSLocalizedString("Change Time", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Change Time ***", comment: "")
        let setString = NSLocalizedString("Change", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
//        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
        
        if tempCreatedAtDateHolder == nil {
            tempCreatedAtDateHolder = self.entry.createdAt
        }
        
        let alert = UIAlertController(style: .actionSheet, title: setChangeTimeStr, message: nil)
        
        alert.addDatePicker(mode: .time, date: self.entry.createdAt, minimumDate: nil, maximumDate: nil) { date in
            print("old date")
            Log(self.entry.createdAt)
            print("new date")
            Log(date)
            
            guard let olddate = self.entry.createdAt else { fatalError("need dat olddate") }
            
            if date == olddate {
                print("all good same date")
                self.entry.createdAt = date
                self.entry.createdAtStr = self.dateFormatter.string(from: date)
            }
            
            if date.isSameDay(as: olddate) {
                print("new entry time ... so requires new entry")
                let _entry = LikertItemEntry(context: self.mngdctx)
                
                print("currDate : \(self.currDate) \t sectionIndex : \(self.sectionIndex)")
                
                _entry.uuid = UUID()
                _entry.createdAt = date
                _entry.createdAtStr = self.dateFormatter.string(from: date)
                _entry.updatedAt = date
                _entry.updatedAtStr = self.dateFormatter.string(from: date)
                
                print("and remove old entry")
                
                _entry.date = self.entry.date
                
                if let _runningTotal = _entry.date?.runningTotal {
                    print("adjusting date running total by removing \(self.entry.runningTotal) from \(_runningTotal)")
                    _entry.date?.runningTotal = _runningTotal - self.entry.runningTotal
                    print("adjusted date total \(String(describing: _entry.date?.runningTotal))")
                }
                
                print("removing entry from date entries")
                self.entry.date?.removeFromEntries(self.entry)
                print("adding entry to date entries")
                _entry.date?.addToEntries(_entry)
                
                print("adding items and adjusting runningtotal")
                for item in self.data {
                    _entry.addToDpoints(item)
                    _entry.runningTotal = _entry.runningTotal + item.ratedValue
                }
                
                print("setting new entry over old value")
                self.entry = _entry
                
                if let _runTotal = self.entry.date?.runningTotal {
                    print("added items, \n runningtotal is \t \(self.runningTotal) and should date is currently at : \(_runTotal)")
                    self.entry.date?.runningTotal = _runTotal + self.entry.runningTotal
                    print("adjusted date by \(self.entry.runningTotal) total should be : \(String(describing: self.entry.date?.runningTotal))")
                }
            }
            
            if let createdat = self.entry.createdAt {
                let dtformatter = DateFormatter()
                dtformatter.timeStyle = .short
                
                let createdatstr = dtformatter.string(from: createdat)
                
                print("got a new createdatdate : \(createdatstr)")
                self.tableView.beginUpdates()
                self.entryDateCell.textLabel?.text = "Time"
                self.entryDateCell.detailTextLabel?.text = createdatstr
                self.entryDateCell.accessoryType = .disclosureIndicator
                self.entryDateCell.accessoryView?.theme_tintColor = "Global.selectionBackgroundColor"
                self.tableView.reloadData()
                self.tableView.endUpdates()
            }
            
//            self.entryDateCell.setNeedsLayout()
            
//            if date.isSameDay(as: olddate) {
//                print("all good ... same day")
//                self.entry.createdAt = date
//                self.entry.createdAtStr = self.dateFormatter.string(from: date)
//            } else {
//                print("not good ... not same day")
//
//                if date.isInPast {
//                    print("date is in the past")
//                }
//
//                if date.isInFuture {
//                    print("date is in the future")
//                }
//
//            }
            
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
        }
        
        alert.addAction(title: setString, style: .destructive)
//        alert.addAction(title: cancelString, style: .cancel)
        tableView.deselectRow(at: indexPath, animated: true)
        present(alert, animated: true, completion: nil)
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
//        view.theme_backgroundColor = "Global.backgroundColor"
//        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.theme_textColor = "Global.barTextColor"
//        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
//        label.textAlignment = .center
//        view.addSubview(label)
////        guard let view = super.tableView(tableView, viewForHeaderInSection: section) else {
////            fatalError("need dat default view")
////        }
////
////        view.theme_backgroundColor = "Global.backgroundColor"
//
//        return view
//    }
}
