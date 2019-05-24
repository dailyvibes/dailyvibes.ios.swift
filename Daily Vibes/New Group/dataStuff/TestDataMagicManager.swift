//
//  TestDataMagicManager.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-01-08.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import Foundation
import CoreData

class LineItemSettings {
    var createdat : Date
    var completedat: Date?
    var dueat: Date?
    let updatedat: Date
    var title: String = ""
    let isNew: Bool = false
    var isCompleted: Bool = false
    var hasProject: Bool = false
    var projecttitle: String = ""
    var projectemoji: String?
    
    init(forDate date:Date = Date()) {
        createdat = date
        updatedat = date
    }
    
    convenience init() {
        self.init(forDate: Date())
    }
}

class TestDataMagicManager {
    
    let store = CoreDataManager.store
    
    let createdatstarttoken = "__smd__"
    let createdatendtoken = "__emd__"
    let completedatstarttoken = "__scd__"
    let completedatendtoken = "__ecd__"
    let duedatestarttoken = "__sdd__"
    let duedateendtoken = "__edd__"
    let projectstarttoken = "__s+__"
    let projectendtoken = "__e+__"
    let hashtagstarttoken = "__s#__"
    let hashtagendtoken = "__e#__"
    let titlestarttoken = "__st__"
    let titleendtoken = "__et__"
    let completedtoken = "[X]"
    let notcompletedtoken = "[ ]"
    
    var startingtoken : String {
        get {
            return createdatstarttoken + completedatstarttoken + duedatestarttoken + projectstarttoken + hashtagstarttoken + titlestarttoken
        }
    }
    
    var endingtoken : String {
        get {
            return createdatendtoken + completedatendtoken + duedateendtoken + projectendtoken + hashtagendtoken + titleendtoken
        }
    }
    
    lazy var textdata: String = ""
    
    lazy var filteredTxtData : [String] = {
        var strSplitByRow = textdata.components(separatedBy: "\n")
        
        var filteredSplitByRow = strSplitByRow.filter({ (item) -> Bool in
            let hasRequiredStart = item.starts(with: notcompletedtoken) || item.starts(with: completedtoken)
            let hasRequiredTags = item.contains(titlestarttoken) && item.contains(titleendtoken)
            
            return hasRequiredStart && hasRequiredTags
        })
        
        return filteredSplitByRow
    }()
    
    init() {
        textdata = ""
        
        if let filepath = Bundle.main.path(forResource: "testdata", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                textdata = contents
                for lineitem in filteredTxtData {
                    // if completed one thing
                    // if not completed another thing
                    let tokenizedlineitem = lineitem.components(separatedBy: "__")
//                    print(tokenized)
                    let lineitemsettings = LineItemSettings()
                    processTokens(tokenizedlineitem: tokenizedlineitem, lineitemsettings: lineitemsettings)
                }
                store.saveContext()
            } catch let error as NSError {
                print("\(error) \t ERROR \t \(error.userInfo)")
            }
        } else {
            print("file not found")
        }
    }
    
    func processTokens(tokenizedlineitem:[String], lineitemsettings:LineItemSettings) {
        for (index, token) in tokenizedlineitem.enumerated() {
            if !token.isEmpty {
//                print("token:" + token)
                // CONSTRAINT: DOES NOT AFFECT YOUR STREAK =)
                // ONLY STREAK IF IN APP OOPS
                
                //            processToken(token: token)
                if startingtoken.contains(token) {
                    //                print("found start")
                    //                processToken(token: token)
                    
                    let lastindex = index + 2
                    let arrmax = tokenizedlineitem.count - 1
                    
                    if lastindex <= arrmax {
                        
//                        let timestampnow = Date()
//
//                        var createdat : Date = timestampnow
//                        var completedat: Date?
//                        var dueat: Date?
//                        let updatedat: Date = timestampnow
//                        var title: String = ""
//                        let isNew: Bool = false
//                        var isCompleted: Bool = false
//                        var hasProject: Bool = false
//                        var projecttitle: String = ""
                        
//                        var hasTags: Bool = false
//                        var tags: [String]
                        
                        if createdatstarttoken.contains(token) {
//                            print("\t createdat")
                            let createdatisostring = tokenizedlineitem[index+1]
                            
                            lineitemsettings.createdat = Date(iso8601String: createdatisostring)
//                            print("\t\titem: \(createdatisostring)")
                        }
                        
                        if duedatestarttoken.contains(token) {
//                            print("\t duedateat")
                            let dueatisostring = tokenizedlineitem[index+1]
                            
                            lineitemsettings.dueat = Date(iso8601String: dueatisostring)
//                            print("\t\titem: \(dueatisostring)")
                        }
                        
                        if completedatstarttoken.contains(token) {
//                            print("\t completedat")
                            
                            let completedatisostring = tokenizedlineitem[index+1]
                            
                            lineitemsettings.isCompleted = true
                            lineitemsettings.completedat = Date(iso8601String: completedatisostring)
                            
//                            print("\t\titem: \(completedatisostring)")
                        }
                        
                        if projectstarttoken.contains(token) {
                            // findDVList(byLabel:tokenized[index+1]) -> DailyVibesList
                            let projectandemoji = tokenizedlineitem[index+1].components(separatedBy: "_")
                            let ptitle = projectandemoji.dropFirst().joined(separator: " ")
                            
//                            var project = tokenizedlineitem[index+1].replacingOccurrences(of: "_", with: " ")
//                            var projectemoji = .
                            
                            lineitemsettings.hasProject = true
                            lineitemsettings.projecttitle = ptitle
                            lineitemsettings.projectemoji = projectandemoji.first
                            
//                            print("\t ~~~~~~~~~~~~~ project")
//                            print("\t\titem: \(project)")
                        }
                        
                        if hashtagstarttoken.contains(token) {
                            // storeTag(withLabel:>>) --> Tag
//                            hasTags = true
                            
//                            print("\t ************* tags")
//                            print("\t\titem: \(tokenized[index+1])")
                        }
                        
                        if titlestarttoken.contains(token) {
                            
                            let itemtitle = tokenizedlineitem[index+1]
                            lineitemsettings.title = itemtitle
                            
                            let taskitem = store.findORCreateDVListItem(with: lineitemsettings.title, createdat: lineitemsettings.createdat, completedat: lineitemsettings.completedat, dueat: lineitemsettings.dueat, subtitle: nil)
                            
                            var project: DailyVibesList?
                            
                            if lineitemsettings.hasProject {
                                project = store.findDVList(byLabel: lineitemsettings.projecttitle)
                                
                                guard let _project = project else {
                                    fatalError("project failed to convert to DVList")
                                }
                                
                                _project.emoji = lineitemsettings.projectemoji
                                _project.addToListItems(taskitem)
                                _project.updatedAt = lineitemsettings.updatedat
                                
                                taskitem.list = _project
                                
//                                print("\t item title \t \(lineitemsettings.title) added to project : \(String(describing: _project.title))")
                            }
                            
                            taskitem.updatedAt = lineitemsettings.updatedat
                            taskitem.isNew = lineitemsettings.isNew
                            taskitem.completed = lineitemsettings.isCompleted
                        }
//                        if endingtoken.contains(tokenized[lastindex]) {
//                            //                processToken(token: token)
//                            print("found end")
//                        }
                    }
                    // createNewListItem(createdat:Date, completedat:Date?, dueat:Date?, title:String, subtitle:String?) -> TodoItem
                    // findORCreateDVListItem(with title:String, createdat: Date, completedat: Date?, dueat: Date?, subtitle: String?) -> TodoItem
                    // findDVList(byLabel:tokenized[index+1]) -> DailyVibesList
                    // storeTag(withLabel:>>) --> Tag
                }
            }
        }
        //    print(tokenized)
    }
}
