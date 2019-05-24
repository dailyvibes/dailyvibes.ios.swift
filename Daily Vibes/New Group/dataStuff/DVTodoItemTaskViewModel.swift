//
//  DVTodoItemTaskViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

//
//The simplest way to make a type codable is to declare its properties using types that are already Codable. These types include standard library types like String, Int, and Double; and Foundation types like Date, Data, and URL. Any type whose properties are codable automatically conforms to Codable just by declaring that conformance.
//

import UIKit

struct DVTodoItemTaskViewModel: Codable {
    let uuid: UUID
    var versionId: UUID?
    var versionPrevId: UUID?
    var version: Int64
    var pos: Int64 = 0
    var priority: Int64 = 0
    var todoItemText: String
    var createdAt: Date
    var updatedAt: Date?
    var startdateAt: Date?
    var duedateAt: Date?
    var enddateAt: Date?
    var completedAt: Date?
    var archivedAt: Date?
    var isCompleted: Bool
    var isArchived: Bool
    var isNew: Bool
    var isPublic: Bool
    var isFavourite: Bool
    var isRemindable: Bool?
    var tags: [DVTagViewModel]?
    var list: DVListViewModel?
    var note: DVNoteViewModel?
    
    
    // WARNING: API
    var synced: Bool? = false
    var syncedID: String?
    var syncedBeganAt: Date?
    var syncedFinishedAt: Date?
    var syncedDeviceID: String?
    
    init(uuid:UUID, versionId:UUID?, versionPrevId: UUID?, version:Int64?, todoItemText:String, createdAt:Date, updatedAt:Date, duedateAt:Date?, completedAt:Date?, archivedAt:Date?, completed:Bool?, isArchived:Bool?, isNew:Bool?, isPublic:Bool?, isFavourite:Bool?, isRemindable: Bool? = false, startdateAt: Date?, enddateAt: Date?, pos:Int64, priority:Int64) {
        self.uuid = uuid
        self.versionId = versionId
        self.versionPrevId = versionPrevId
        self.version = version ?? 0
        self.todoItemText = todoItemText
        self.createdAt = createdAt
        self.startdateAt = startdateAt
        self.updatedAt = updatedAt
        self.duedateAt = duedateAt
        self.enddateAt = enddateAt
        self.pos = pos
        self.priority = priority
        self.completedAt = completedAt
        self.archivedAt = archivedAt
        self.isCompleted = completed ?? false
        self.isArchived = isArchived ?? false
        self.isNew = isNew ?? false
        self.isPublic = isPublic ?? false
        self.isFavourite = isFavourite ?? false
        self.isRemindable = isRemindable ?? false
        self.tags = [DVTagViewModel]()
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case versionId
        case versionPrevId
        case version
        case todoItemText
        case createdAt
        case updatedAt
        case startdateAt
        case duedateAt
        case enddateAt
        case pos
        case priority
        case completedAt
        case archivedAt
        case isCompleted
        case isArchived
        case isNew
        case isPublic
        case isFavourite
        case isRemindable
        case tags
        case list
        case note
        case syncedID = "_id"
        case syncedBeganAt
        case syncedFinishedAt
        case syncedDeviceID
    }
    
    //    let uuid: UUID
    //    var versionId: UUID?
    //    var versionPrevId: UUID?
    //    var version: Int64
    //    var todoItemText: String
    //    var createdAt: Date
    //    var updatedAt: Date
    //    var duedateAt: Date?
    //    var completedAt: Date?
    //    var archivedAt: Date?
    //    var isCompleted: Bool
    //    var isArchived: Bool
    //    var isNew: Bool
    //    var isPublic: Bool
    //    var isFavourite: Bool
    //    var isRemindable: Bool?
    //    var tags: [DVTagViewModel]?
    //    var list: DVListViewModel?
    //    var note: DVNoteViewModel?
    
    //    init(from decoder: Decoder) throws {
    //        let values = try decoder.container(keyedBy: CodingKeys.self)
    //
    //        self.uuid = try values.decode(UUID.self, forKey: .uuid)
    //        self.versionId = try values.decodeIfPresent(UUID.self, forKey: .versionId)
    //        self.versionPrevId = try values.decodeIfPresent(UUID.self, forKey: .versionPrevId)
    //        self.version = try values.decode(Int64.self, forKey: .version)
    //        self.todoItemText = try values.decode(String.self, forKey: .todoItemText)
    //        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
    //        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
    //        self.duedateAt = try values.decodeIfPresent(Date.self, forKey: .duedateAt)
    //        self.completedAt = try values.decodeIfPresent(Date.self, forKey: .completedAt)
    //        self.archivedAt = try values.decodeIfPresent(Date.self, forKey: .archivedAt)
    //        self.isCompleted = try values.decode(Bool.self, forKey: .isCompleted)
    //        self.isArchived = try values.decode(Bool.self, forKey: .isArchived)
    //        self.isNew = try values.decode(Bool.self, forKey: .isNew)
    //        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
    //        self.isFavourite = try values.decode(Bool.self, forKey: .isFavourite)
    //        self.isRemindable = try values.decodeIfPresent(Bool.self, forKey: .isRemindable)
    //        self.tags = try values.decodeIfPresent([DVTagViewModel].self, forKey: .tags)
    //        self.list = try values.decodeIfPresent(DVListViewModel.self, forKey: .list)
    //        self.note = try values.decodeIfPresent(DVNoteViewModel.self, forKey: .note)
    //        self.syncedID = try values.decodeIfPresent(String.self, forKey: .syncedID)
    //        self.syncedBeganAt = try values.decodeIfPresent(Date.self, forKey: .syncedBeganAt)
    //        self.syncedFinishedAt = try values.decodeIfPresent(Date.self, forKey: .syncedFinishedAt)
    //    }
    
    //    func encode(to encoder: Encoder) throws {
    //        var container = encoder.container(keyedBy: CodingKeys.self)
    //
    //        try container.encode(uuid, forKey: .uuid)
    //        try container.encode(versionId ?? nil, forKey: .versionId)
    //        try container.encode(versionPrevId ?? nil, forKey: .versionPrevId)
    //        try container.encode(version, forKey: .version)
    //        try container.encode(todoItemText, forKey: .todoItemText)
    //        try container.encode(createdAt, forKey: .createdAt)
    //        try container.encode(updatedAt, forKey: .updatedAt)
    //        try container.encode(duedateAt ?? nil, forKey: .duedateAt)
    //        try container.encode(completedAt ?? nil, forKey: .completedAt)
    //        try container.encode(archivedAt ?? nil, forKey: .archivedAt)
    //        try container.encode(isCompleted, forKey: .isCompleted)
    //        try container.encode(isArchived, forKey: .isArchived)
    //        try container.encode(isNew, forKey: .isNew)
    //        try container.encode(isPublic, forKey: .isPublic)
    //        try container.encode(isFavourite, forKey: .isFavourite)
    //        try container.encode(isRemindable, forKey: .isRemindable)
    //
    //        if let _tags = tags {
    //
    //            var tagsArray = container.nestedUnkeyedContainer(forKey: .tags)
    //
    //            try _tags.forEach {
    //                try tagsArray.encode($0)
    //            }
    //            //            var tagsArray = container.nestedContainer(keyedBy: DVTagViewModel.CodingKeys.self, forKey: .tags)
    //            //
    //            //            try _tags.forEach {
    //            //                try tagsArray.encode($0.uuid, forKey: .uuid)
    //            //                try tagsArray.encode($0.label, forKey: .label)
    //            //                try tagsArray.encode($0.version, forKey: .version)
    //            //                try tagsArray.encode($0.versionId, forKey: .versionId)
    //            //                try tagsArray.encode($0.versionPrevId, forKey: .versionPrevId)
    //            //                try tagsArray.encode($0.createdAt, forKey: .createdAt)
    //            //                try tagsArray.encode($0.updatedAt, forKey: .updatedAt)
    //            //                try tagsArray.encode($0.isArchived, forKey: .isArchived)
    //            //                try tagsArray.encode($0.isPublic, forKey: .isPublic)
    //            //                try tagsArray.encode($0.colourRepresentation, forKey: .colourRepresentation)
    //            //                try tagsArray.encode($0.emoji, forKey: .emoji)
    //            //                try tagsArray.encode($0.active, forKey: .active)
    //            //                try tagsArray.encode($0.completed, forKey: .completed)
    //            //                try tagsArray.encode($0.tagged, forKey: .tagged)
    //            //            }
    //        }
    //
    //        //        try container.encode(self.tags, forKey: .tags)
    //        try container.encode(list, forKey: .list)
    //        try container.encode(note, forKey: .note)
    //
    //        try container.encodeIfPresent(syncedID, forKey: .syncedID)
    //        try container.encodeIfPresent(syncedBeganAt, forKey: .syncedBeganAt)
    //        try container.encodeIfPresent(syncedFinishedAt, forKey: .syncedFinishedAt)
    //    }
    
    func tagsContains(tag: DVTagViewModel) -> Bool {
        var found = false
        
        if let hasTags = tags, hasTags.count > 0 {
            for _tag in hasTags {
                if _tag.uuid == tag.uuid {
                    found = true
                    break
                }
            }
        }
        
        return found
    }
}

//var tags: [DVTagViewModel]?
//var list: DVListViewModel?
//var note: DVNoteViewModel?

extension DVTodoItemTaskViewModel {
    func encodedString() -> String {
//        let dateFormatter = DateFormatter()
        var encodedString = ""
//
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        
//        let createdDate = "__STARTCREATEDATE__" + createdAt.iso8601String + "__ENDCREATEDATE__"
        let createdDate = "__smd__" + createdAt.iso8601String + "__emd__"
        
        if isCompleted {
            encodedString += "[X]"
            
            encodedString += createdDate
//            encodedString.append("[X] ")
            if let dateCompletedAt = completedAt {
//                let completedDate = "__STARTCOMPLETEDDATE__" + dateCompletedAt.iso8601String + "__ENDCOMPLETEDDATE__"
                let completedDate = "__scd__" + dateCompletedAt.iso8601String + "__ecd__"
                encodedString += completedDate
//                encodedString.append("\(completedDate) ")
            }
        } else {
            encodedString += "[ ]"
            
            encodedString += createdDate
            
            if let dueDate = duedateAt {
//                let encodedDueDate = "__STARTDUEDATE__" + dueDate.iso8601String + "__ENDDUEDATE__"
                let encodedDueDate = "__sdd__" + dueDate.iso8601String + "__edd__"
                encodedString += encodedDueDate
                //            encodedString.append("due:\(encodedDueDate)")
            }
//            encodedString.append("[ ] ")
        }
//        encodedString.append("\(createdDate) ")
//        encodedString.append("__STARTTEXT__\(todoItemText)__ENDTEXT__ ")
        
        if let project = list, let title = project.title {
            var convertedTitle = title.replacingOccurrences(of: " ", with: "_")
            
            if let _emoji = project.emoji {
                convertedTitle = _emoji + "_" + convertedTitle
            }
            
            let projectTitle = "__s+__" + convertedTitle + "__e+__"
            encodedString += projectTitle
//            encodedString.append("+\(title) ")
        }
        
        if let tagList = tags, tagList.count > 0 {
            var __tags = "__s#__"
            
            for tag in tagList {
                let tagLabelConverted = tag.label.replacingOccurrences(of: " ", with: "_")
                let tagLabel = "#" + tagLabelConverted + ""
                __tags += tagLabel
//                encodedString.append("#\(tag.label) ")
            }
            __tags +=  "__e#__"
            encodedString += __tags
        }
        
        let encodedText = "__st__" + todoItemText + "__et__"
        encodedString += encodedText
        
        return encodedString
    }
}

extension DVTodoItemTaskViewModel {
    static func fromCoreData(todoItem: TodoItem) -> DVTodoItemTaskViewModel {
        var converted: DVTodoItemTaskViewModel?
        todoItem.managedObjectContext?.performAndWait {
            if todoItem.id != nil, let dvCreatedAt = todoItem.createdAt, let dvUpdatedAt = todoItem.updatedAt, let dvTodoItemText = todoItem.todoItemText {
                converted = DVTodoItemTaskViewModel.init(uuid: todoItem.id!,
                                                         versionId: todoItem.versionId,
                                                         versionPrevId: todoItem.versionPrevId,
                                                         version: todoItem.version,
                                                         todoItemText: dvTodoItemText,
                                                         createdAt: dvCreatedAt,
                                                         updatedAt: dvUpdatedAt,
                                                         duedateAt: todoItem.duedateAt,
                                                         completedAt: todoItem.completedAt,
                                                         archivedAt: todoItem.archivedAt,
                                                         completed: todoItem.completed,
                                                         isArchived: todoItem.isArchived,
                                                         isNew: todoItem.isNew,
                                                         isPublic: todoItem.isPublic,
                                                         isFavourite: todoItem.isFavourite,
                                                         isRemindable: todoItem.isRemindable,
                                                         startdateAt: todoItem.startdateAt,
                                                         enddateAt: todoItem.enddateAt,
                                                         pos: todoItem.pos,
                                                         priority: todoItem.priority)
                if let hasNote = todoItem.notes {
                    converted?.note = DVNoteViewModel.fromCoreData(note: hasNote)
                }
                if let hasList = todoItem.list {
                    converted?.list = DVListViewModel.fromCoreData(list: hasList)
                }
                converted?.synced = todoItem.synced
                converted?.syncedID = todoItem.syncedID
                converted?.syncedBeganAt = todoItem.syncedBeganAt
                converted?.syncedFinishedAt = todoItem.syncedFinishedAt
                converted?.syncedDeviceID = todoItem.syncedDeviceID ?? UIDevice.current.identifierForVendor?.uuidString
                //                if let tags = todoItem.tags?.allObjects, tags.count > 0 {
                //                    var data = [DVTagViewModel]()
                //
                //                    for tag in tags {
                ////                        converted?.tags?.append(DVTagViewModel.fromCoreData(tag: tag as! Tag))
                //                        data.append(DVTagViewModel.fromCoreData(tag: tag as! Tag))
                //                    }
                //
                //                    converted?.tags = data
                //                }
            }
        }
        
        return converted!
        //        if converted == nil {
        //            return makeEmpty()
        //        } else {
        //            return converted!
        //        }
    }
    
    static func makeEmpty() -> DVTodoItemTaskViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        var result =  DVTodoItemTaskViewModel.init(uuid: fallbackString!, versionId: nil, versionPrevId: nil, version: nil, todoItemText: emptyString, createdAt: curDate, updatedAt: curDate, duedateAt: nil, completedAt: nil, archivedAt: nil, completed: false, isArchived: false, isNew: true, isPublic: false, isFavourite: false, isRemindable: false, startdateAt: nil, enddateAt: nil, pos: 0, priority: 0)
        
        result.tags = [DVTagViewModel]()
        
        return result
    }
}

// MARK: - API Sync
//extension DVTodoItemTaskViewModel {
//    fileprivate func dvPostSyncPutFunc(_ todotaskitem: TodoItem) {
//        guard let syncedID = syncedID else { fatalError() }
//        guard syncedDeviceID != nil else { fatalError() }
//        
//        let urlString = "\(DVConstants.DVTodotaskitemApi.baseURL)/\(syncedID)"
//        
//        do {
//            let jsonEncoder = JSONEncoder()
//            jsonEncoder.dateEncodingStrategy = .iso8601
//            
//            let jsonData = try jsonEncoder.encode(self)
//            let url = URL(string: urlString)!
//            var request = URLRequest(url: url)
//            request.httpMethod = "PUT"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { (data, response, error) in
//                if let error = error {
//                    print("error: \(error)")
//                    return
//                }
//                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                    print ("server error")
//                    return
//                }
//                if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
//                    do {
//                        let decoder = JSONDecoder()
//                        decoder.dateDecodingStrategy = .iso8601
//                        
//                        let todoitemtaskServerdata = try decoder.decode(DVTodoItemTaskViewModel.self, from: data)
//                        
//                        if todoitemtaskServerdata.uuid == todotaskitem.id {
//                            todotaskitem.syncedID = todoitemtaskServerdata.syncedID
//                            todotaskitem.synced = true
//                            todotaskitem.syncedFinishedAt = Date()
//                            todotaskitem.syncedDeviceID = todoitemtaskServerdata.syncedDeviceID
//                        } else {
//                            fatalError()
//                        }
//                    } catch let error as NSError {
//                        let errorMsg = """
//                        Domain: \(error.domain)
//                        Code: \(error.code)
//                        Description: \(error.localizedDescription)
//                        Failure Reason: \(error.localizedFailureReason ?? "")
//                        Suggestions: \(error.localizedRecoverySuggestion ?? "")
//                        """
//                        fatalError(errorMsg)
//                    }
//                }
//            }
//            task.resume()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }
//    
//    fileprivate func dvPostSyncCreateFunc(_ todotaskitem: TodoItem) {
//        guard syncedDeviceID != nil else { fatalError() }
//        let urlString = "\(DVConstants.DVTodotaskitemApi.baseURL)"
//        
//        do {
//            let jsonEncoder = JSONEncoder()
//            jsonEncoder.dateEncodingStrategy = .iso8601
//            
//            let jsonData = try jsonEncoder.encode(self)
//            let url = URL(string: urlString)!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { (data, response, error) in
//                if let error = error {
//                    print("error: \(error)")
//                    return
//                }
//                
//                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                    print ("server error")
//                    return
//                }
//                
//                if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
//                    do {
//                        let decoder = JSONDecoder()
//                        decoder.dateDecodingStrategy = .iso8601
//                        
//                        let todoitemtaskServerdata = try decoder.decode(DVTodoItemTaskViewModel.self, from: data)
//                        
//                        todotaskitem.syncedID = todoitemtaskServerdata.syncedID
//                        todotaskitem.synced = true
//                        todotaskitem.syncedFinishedAt = Date()
//                        todotaskitem.syncedDeviceID = todoitemtaskServerdata.syncedDeviceID
//                    } catch let error as NSError {
//                        fatalError("""
//                            Domain: \(error.domain)
//                            Code: \(error.code)
//                            Description: \(error.localizedDescription)
//                            Failure Reason: \(error.localizedFailureReason ?? "")
//                            Suggestions: \(error.localizedRecoverySuggestion ?? "")
//                            """)
//                    }
//                }
//            }
//            task.resume()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }
//    
//    func dvPostSync(for todotaskitem:TodoItem) {
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            if syncedID == nil {
//                // new item, so make a post
//                dvPostSyncCreateFunc(todotaskitem)
//            } else {
//                // old item so make a put
//                dvPostSyncPutFunc(todotaskitem)
//            }
//        }
//    }
//    
//    static func dvDeleteSync(for id:String) {
//        if id.isEmpty { return }
//        
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            let urlString = "\(DVConstants.DVTodotaskitemApi.baseURL)/\(id)"
//            let url = URL(string: urlString)!
//            var request = URLRequest(url: url)
//            
//            request.httpMethod = "DELETE"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                if let error = error {
//                    print("error: \(error)")
//                    return
//                }
//                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                    print ("server error")
//                    return
//                }
//                
//                if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("DELETED! data: \(dataString)")
//                }
//            })
//            task.resume()
//        }
//    }
//}

