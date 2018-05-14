//
//  DVTagViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVTagViewModel: Codable {
    var uuid: UUID
    var label: String
    var version: Int?
    var versionId: UUID?
    var versionPrevId: UUID?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool = false
    var isPublic: Bool = false
    var colourRepresentation: String?
    var emoji: String?
    var active: Int = 0
    var completed: Int = 0
    var tagged: [DVTodoItemTaskViewModel]
    
    // WARNING: API
    var synced: Bool? = false
    var syncedID: String?
    var syncedBeganAt: Date?
    var syncedFinishedAt: Date?
    var syncedDeviceID: String?
    
    init(uuid: UUID, label:String, createdAt:Date, updatedAt: Date) {
        self.uuid = uuid
        self.label = label
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagged = [DVTodoItemTaskViewModel]()
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case label
        case version
        case versionId
        case versionPrevId
        case createdAt
        case updatedAt
        case isArchived
        case isPublic
        case colourRepresentation
        case emoji
        case active
        case completed
        case tagged
        case syncedID = "_id"
        case syncedBeganAt
        case syncedFinishedAt
        case syncedDeviceID
    }
    
//    enum TaggedCodingKeys: String, CodingKey {
//        case uuid
//        case versionId
//        case versionPrevId
//        case version
//        case todoItemText
//        case createdAt
//        case updatedAt
//        case duedateAt
//        case completedAt
//        case archivedAt
//        case isCompleted
//        case isArchived
//        case isNew
//        case isPublic
//        case isFavourite
//        case isRemindable
//        case tags
//        case list
//        case note
//        case syncedID = "_id"
//        case syncedBeganAt
//        case syncedFinishedAt
//    }
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.uuid = try values.decode(UUID.self, forKey: .uuid)
//        self.label = try values.decode(String.self, forKey: .label)
//        self.version = try values.decode(Int.self, forKey: .version)
//        self.versionId = try values.decode(UUID.self, forKey: .versionId)
//        self.versionPrevId = try values.decode(UUID.self, forKey: .versionPrevId)
//        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
//        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
//        self.isArchived = try values.decode(Bool.self, forKey: .isArchived)
//        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
//        self.colourRepresentation = try values.decode(String.self, forKey: .colourRepresentation)
//        self.emoji = try values.decode(String.self, forKey: .emoji)
//        self.active = try values.decode(Int.self, forKey: .active)
//        self.completed = try values.decode(Int.self, forKey: .completed)
//
////        let tagged = try values.nestedContainer(keyedBy: TaggedKeys.self, forKey: .tagged)
//
//        self.tagged = try values.decode([DVTodoItemTaskViewModel].self, forKey: .tagged)
////        self.tagged = try [DVTodoItemTaskViewModel(from: decoder)]
//
//        self.syncedID = try values.decodeIfPresent(String.self, forKey: .syncedID)
//        self.syncedBeganAt = try values.decodeIfPresent(Date.self, forKey: .syncedBeganAt)
//        self.syncedFinishedAt = try values.decodeIfPresent(Date.self, forKey: .syncedFinishedAt)
//    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(uuid, forKey: .uuid)
//        try container.encode(label, forKey: .label)
//        try container.encode(version, forKey: .version)
//        try container.encode(versionId, forKey: .versionId)
//        try container.encode(versionPrevId, forKey: .versionPrevId)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(updatedAt, forKey: .updatedAt)
//        try container.encode(isArchived, forKey: .isArchived)
//        try container.encode(isPublic, forKey: .isPublic)
//        try container.encode(colourRepresentation, forKey: .colourRepresentation)
//        try container.encode(emoji, forKey: .emoji)
//        try container.encode(active, forKey: .active)
//        try container.encode(completed, forKey: .completed)
//
////        var taggedArray = container.nestedContainer(keyedBy: TaggedCodingKeys.self, forKey: .tagged)
//        var taggedArray = container.nestedUnkeyedContainer(forKey: .tagged)
//
//        try tagged.forEach {
//            try taggedArray.encode($0.uuid)
//        }
//
////        try tagged.forEach {
////            try taggedArray.encode($0.uuid, forKey: .uuid)
////            try taggedArray.encode($0.version, forKey: .version)
////            try taggedArray.encode($0.versionId, forKey: .versionId)
////            try taggedArray.encode($0.versionPrevId, forKey: .versionPrevId)
////            try taggedArray.encode($0.todoItemText, forKey: .todoItemText)
////            try taggedArray.encode($0.createdAt, forKey: .createdAt)
////            try taggedArray.encode($0.updatedAt, forKey: .updatedAt)
////            try taggedArray.encode($0.duedateAt, forKey: .duedateAt)
////            try taggedArray.encode($0.completedAt, forKey: .completedAt)
////            try taggedArray.encode($0.archivedAt, forKey: .archivedAt)
////            try taggedArray.encode($0.isCompleted, forKey: .isCompleted)
////            try taggedArray.encode($0.isArchived, forKey: .isArchived)
////            try taggedArray.encode($0.isNew, forKey: .isNew)
////            try taggedArray.encode($0.isPublic, forKey: .isPublic)
////            try taggedArray.encode($0.isFavourite, forKey: .isFavourite)
////            try taggedArray.encode($0.isRemindable, forKey: .isRemindable)
////            try taggedArray.encode($0.tags, forKey: .tags)
////            try taggedArray.encode($0.list, forKey: .list)
////            try taggedArray.encode($0.note, forKey: .note)
////        }
//
////        try container.encode(tagged, forKey: .tagged)
//        try container.encodeIfPresent(syncedID, forKey: .syncedID)
//        try container.encodeIfPresent(syncedBeganAt, forKey: .syncedBeganAt)
//        try container.encodeIfPresent(syncedFinishedAt, forKey: .syncedFinishedAt)
//    }
}

extension DVTagViewModel {
    static func fromCoreData(tag: Tag) -> DVTagViewModel {
        var converted: DVTagViewModel?
        tag.managedObjectContext?.performAndWait {
            converted = DVTagViewModel(uuid: tag.uuid!, label: tag.label!, createdAt: tag.createdAt!, updatedAt: tag.updatedAt!)
            
            converted?.synced = tag.synced
            converted?.syncedID = tag.syncedID
            converted?.syncedBeganAt = tag.syncedBeganAt
            converted?.syncedFinishedAt = tag.syncedFinishedAt
            converted?.syncedDeviceID = tag.syncedDeviceID ?? UIDevice.current.identifierForVendor?.uuidString
        }
//        if let todos = tag.todos?.allObjects, todos.count > 0 {
//            for todoitemtask in todos {
//                converted?.tagged.append(DVTodoItemTaskViewModel.fromCoreData(todoItem: todoitemtask as! TodoItem))
//            }
//        }
        return converted!
    }
}

extension DVTagViewModel {
    static func copyWithoutTagged(tag: DVTagViewModel) -> DVTagViewModel {
        var result = DVTagViewModel.init(uuid: tag.uuid, label: tag.label, createdAt: tag.createdAt, updatedAt: tag.updatedAt)
        
        result.syncedID = tag.syncedID
        result.synced = tag.synced
        result.syncedBeganAt = tag.syncedBeganAt
        result.syncedFinishedAt = tag.syncedFinishedAt
        result.syncedDeviceID = tag.syncedDeviceID
        
        return result
    }
}

//// MARK: - API
//extension DVTagViewModel {
//    fileprivate func dvPostSyncCreateFunc(_ tag:Tag) {
//        guard syncedDeviceID != nil else { fatalError() }
//        let urlString = "\(DVConstants.DVTagApi.baseURL)"
//        
//        do {
//            let jsonEncoder = JSONEncoder()
//            jsonEncoder.dateEncodingStrategy = .iso8601
//            
//            let jsonData = try jsonEncoder.encode(self)
//            let url = URL(string: urlString)!
//            var request = URLRequest(url: url)
//            
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
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
//                        let tagServerdata = try decoder.decode(DVTagViewModel.self, from: data)
//                        
//                        tag.syncedID = tagServerdata.syncedID
//                        tag.synced = true
//                        tag.syncedFinishedAt = Date()
//                        tag.syncedDeviceID = tagServerdata.syncedDeviceID
//                        
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
//    fileprivate func dvPostSyncPutFunc(_ tag:Tag) {
//        fatalError("not implemented yet")
//    }
//    
//    func dvPostSync(for tag:Tag) {
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            if syncedID == nil {
//                // new item, so make a post
//                dvPostSyncCreateFunc(tag)
//            } else {
//                // old item so make a put
//                dvPostSyncPutFunc(tag)
//            }
//        }
//    }
//    
//    static func dvDeleteSync(for id:String) {
//        if id.isEmpty { return }
//        
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            let urlString = "\(DVConstants.DVTagApi.baseURL)/\(id)"
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

