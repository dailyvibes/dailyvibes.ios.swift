//
//  DVMultipleTodoitemtaskItemsVM.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-02-18.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation

class DVMultipleTodoitemtaskItemsVM: NSObject {
    var curProject: DVListViewModel?
    var duedateAt: Date?
    var rawMultipleTaskText: String?
    var prevProject: DVListViewModel?
    var parsedText: [String]?
    var hasTags: Bool = false
    var tagListText: [String]?
    var isRemindable: Bool = false
}
