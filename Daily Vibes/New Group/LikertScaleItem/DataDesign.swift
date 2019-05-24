//
//  DataDesign.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-12-16.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation

enum DLikertScaleItemType {
    case motivation
    case mood
    case stress
    case vibes
    case work
    case life
    case health
}

enum DLikertItemEntryNameType {
    case morning
    case day
    case afternoon
}

protocol DlBase {
    var uuid: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get set }
    var createdAtStr: String { get }
    var updatedAtStr: String { get set }
}


// required structure
struct DLikertItemDate: DlBase {
    // default
    let uuid: String
    let createdAt: Date
    var updatedAt: Date
    let createdAtStr: String
    var updatedAtStr: String
    // custom
    var currentEntry: DLikertItemEntry?
    var dayEntries: [DLikertItemEntry] = [DLikertItemEntry]()
    var nextDateEntryUUID: String?
    var previousDateEntryUUID: String?
    
    init(createdAt: Date?) {
        let date = createdAt ?? Date()
        
        let dateISOformatter = ISO8601DateFormatter()
        let datetimeNow = dateISOformatter.string(from: date)
        
        guard let convertedDate = dateISOformatter.date(from: datetimeNow) else {
            fatalError("check DLikertItemDate constructor")
        }
        
        self.uuid = UUID().uuidString
        self.createdAt = convertedDate
        self.updatedAt = convertedDate
        self.createdAtStr = datetimeNow
        self.updatedAtStr = datetimeNow
    }
}

// require structure
struct DLikertItemEntry: DlBase {
    // default
    let uuid: String
    let createdAt: Date
    var updatedAt: Date
    let createdAtStr: String
    var updatedAtStr: String
    // custom
    let type: DLikertItemEntryNameType
    var entires: [DLikertScaleItemDetailsViewData] = [DLikertScaleItemDetailsViewData]()
    let previousEntryUUID: String?
    let nextEntryUUID: String?
    let dateUUID: String
    
    init(type: DLikertItemEntryNameType, dateUUID: String, nextEntry: String?, prevEntry: String?) {
        let date = Date()
        
        let dateISOformatter = ISO8601DateFormatter()
        let datetimeNow = dateISOformatter.string(from: date)
        
        guard let convertedDate = dateISOformatter.date(from: datetimeNow) else {
            fatalError("check LikertItemEntry constructor")
        }
        
        self.uuid = UUID().uuidString
        self.createdAt = convertedDate
        self.updatedAt = convertedDate
        self.createdAtStr = datetimeNow
        self.updatedAtStr = datetimeNow
        self.type = type
        self.dateUUID = dateUUID
        self.nextEntryUUID = nextEntry
        self.previousEntryUUID = prevEntry
    }
}

// what we make on the screen via interactions
struct DLikertScaleItemDetailsViewData: DlBase {
    // default
    let uuid: String
    let createdAt: Date
    var updatedAt: Date
    let createdAtStr: String
    var updatedAtStr: String
    // custom
    let ratedValue: Float
    let type: DLikertScaleItemType
    let ratedValueMax: Float
    let ratedValueMin: Float
    let ratedValueAdjuster: Float
    let entryUUID: String
    
    init(type: DLikertScaleItemType, value: Float, min: Float = 0, max: Float = 10, adjuster: Float = 5, entryUUID: String) {
        let date = Date()
        
        let dateISOformatter = ISO8601DateFormatter()
        let datetimeNow = dateISOformatter.string(from: date)
        
        guard let convertedDate = dateISOformatter.date(from: datetimeNow) else {
            fatalError("check LikertScaleItemDetailsViewData constructor")
        }
        
        self.uuid = UUID().uuidString
        self.createdAt = convertedDate
        self.updatedAt = convertedDate
        self.createdAtStr = datetimeNow
        self.updatedAtStr = datetimeNow
        self.type = type
        self.ratedValue = value
        self.ratedValueMin = min
        self.ratedValueMax = max
        self.ratedValueAdjuster = adjuster
        self.entryUUID = entryUUID
    }
}

class LikertScaleDataDesign {
    private init() {}
    
    class func likertItemDate(createdAt: Date?) -> DLikertItemDate {
        return DLikertItemDate(createdAt: createdAt)
    }
    
    class func likertItemEntry(type: DLikertItemEntryNameType, dateUUID: String, nextEntry: String?, prevEntry: String?) -> DLikertItemEntry {
        return DLikertItemEntry(type: type, dateUUID: dateUUID, nextEntry: nextEntry, prevEntry: prevEntry)
    }
    
    class func likertScaleItemDetailsViewData(type: DLikertScaleItemType, value: Float, min: Float = 0, max: Float = 10, adjuster: Float = 5, entryUUID: String) -> DLikertScaleItemDetailsViewData {
        return DLikertScaleItemDetailsViewData(type: type, value: value, min: min, max: max, adjuster: adjuster, entryUUID: entryUUID)
    }
}
