//
//  WIPSyncData.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-03-06.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation

struct WIPTodoItem: Codable {
    let body: String
}

struct WIPTodoItemSyncData: Codable {
    let todo: WIPTodoItem
}

struct WIPSyncData: Codable {
    let operationName: String
    let variables: WIPTodoItemSyncData
    let query: String
}
