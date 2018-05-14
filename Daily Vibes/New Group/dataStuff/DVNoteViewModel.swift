//
//  DVNoteViewModel.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-22.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit

struct DVNoteViewModel: Codable {
    var uuid: UUID
    var title: String?
    var content: String?
    var version: Int = 0
    var versionId: UUID?
    var versionPrevId: UUID?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var archivedAt: Date?
    var isPublic: Bool = false
    var isFavourite: Bool = false
    var dvTodoItemTaskViewModelUUID: UUID?
    
    // WARNING: API
    var synced: Bool? = false
    var syncedID: String?
    var syncedBeganAt: Date?
    var syncedFinishedAt: Date?
    var syncedDeviceID: String?
    
    init(uuid: UUID, title: String?, content: String?, createdAt: Date, updatedAt: Date, completedAt: Date?, archivedAt: Date?, dvTodoItemTaskViewModelUUID: UUID?) {
        self.uuid = uuid
        self.title = title
        self.content = content
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.archivedAt = archivedAt
        self.dvTodoItemTaskViewModelUUID = dvTodoItemTaskViewModelUUID
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case content
        case version
        case versionId
        case versionPrevId
        case createdAt
        case updatedAt
        case completedAt
        case archivedAt
        case isPublic
        case isFavourite
        case dvTodoItemTaskViewModelUUID
        case syncedID = "_id"
        case syncedBeganAt
        case syncedFinishedAt
        case syncedDeviceID
    }
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.uuid = try values.decode(UUID.self, forKey: .uuid)
//        self.title = try values.decode(String.self, forKey: .title)
//        self.content = try values.decode(String.self, forKey: .content)
//        self.createdAt = try values.decode(Date.self, forKey: .createdAt)
//        self.updatedAt = try values.decode(Date.self, forKey: .updatedAt)
//        self.completedAt = try values.decode(Date.self, forKey: .completedAt)
//        self.archivedAt = try values.decode(Date.self, forKey: .archivedAt)
//        self.completedAt = try values.decode(Date.self, forKey: .completedAt)
//        self.archivedAt = try values.decode(Date.self, forKey: .archivedAt)
//        self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
//        self.isFavourite = try values.decode(Bool.self, forKey: .isFavourite)
//        self.dvTodoItemTaskViewModelUUID = try values.decodeIfPresent(UUID.self, forKey: .dvTodoItemTaskViewModelUUID)
//
//        self.syncedID = try values.decodeIfPresent(String.self, forKey: .syncedID)
//        self.syncedBeganAt = try values.decodeIfPresent(Date.self, forKey: .syncedBeganAt)
//        self.syncedFinishedAt = try values.decodeIfPresent(Date.self, forKey: .syncedFinishedAt)
//    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        
//        try container.encode(uuid, forKey: .uuid)
//        try container.encode(title, forKey: .title)
//        try container.encode(content, forKey: .content)
//        try container.encode(version, forKey: .version)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(updatedAt, forKey: .updatedAt)
//        try container.encode(completedAt, forKey: .completedAt)
//        try container.encode(archivedAt, forKey: .archivedAt)
//        try container.encode(isPublic, forKey: .isPublic)
//        try container.encode(isFavourite, forKey: .isFavourite)
//        try container.encode(dvTodoItemTaskViewModelUUID, forKey: .dvTodoItemTaskViewModelUUID)
//        try container.encodeIfPresent(syncedID, forKey: .syncedID)
//        try container.encodeIfPresent(syncedBeganAt, forKey: .syncedBeganAt)
//        try container.encodeIfPresent(syncedFinishedAt, forKey: .syncedFinishedAt)
//    }
}

extension DVNoteViewModel {
    static func fromCoreData(note: DailyVibesNote) -> DVNoteViewModel {
        var converted: DVNoteViewModel?
        note.managedObjectContext?.performAndWait {
            converted = DVNoteViewModel.init(uuid: note.uuid!, title: note.title, content: note.content, createdAt: note.createdAt!, updatedAt: note.updatedAt!, completedAt: note.completedAt, archivedAt: note.archivedAt, dvTodoItemTaskViewModelUUID: nil)
        }
        if let hasTodoitemtask = note.todoItemTask {
            converted?.dvTodoItemTaskViewModelUUID = hasTodoitemtask.id
        }
        converted?.synced = note.synced
        converted?.syncedID = note.syncedID
        converted?.syncedBeganAt = note.syncedBeganAt
        converted?.syncedFinishedAt = note.syncedFinishedAt
        converted?.syncedDeviceID = note.syncedDeviceID ?? UIDevice.current.identifierForVendor?.uuidString
        return converted!
    }
    
    static func makeEmpty() -> DVNoteViewModel {
        let fallbackString = UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")
        let curDate = Date()
        let emptyString = String()
        
        return DVNoteViewModel.init(uuid: fallbackString!, title: emptyString, content: emptyString, createdAt: curDate, updatedAt: curDate, completedAt: nil, archivedAt: nil, dvTodoItemTaskViewModelUUID: nil)
    }
}
//
//extension DVNoteViewModel {
//    fileprivate func dvPostSyncCreateFunc(_ project:DailyVibesNote) {
//        guard syncedDeviceID != nil else { fatalError() }
//        
//        let urlString = "\(DVConstants.DVNoteApi.baseURL)"
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
//                        let tagServerdata = try decoder.decode(DVNoteViewModel.self, from: data)
//                        
//                        project.syncedID = tagServerdata.syncedID
//                        project.synced = true
//                        project.syncedFinishedAt = Date()
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
//    fileprivate func dvPostSyncPutFunc(_ note:DailyVibesNote) {
//        fatalError("not implemented yet")
//    }
//    
//    func dvPostSync(for note: DailyVibesNote) {
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            if syncedID == nil {
//                // new item, so make a post
//                dvPostSyncCreateFunc(note)
//            } else {
//                // old item so make a put
//                dvPostSyncPutFunc(note)
//            }
//        }
//    }
//    
//    static func dvDeleteSync(for id:String) {
//        if id.isEmpty { return }
//        
//        let defaults = UserDefaults.standard
//        if defaults.bool(forKey: "canDVSync") && defaults.bool(forKey: "isDVSyncON") {
//            let urlString = "\(DVConstants.DVNoteApi.baseURL)/\(id)"
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

