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
    var hasCustomDuedates: Date?
    var parsedDuedates: [Date]?
    var tagListText: [String]?
    var isRemindable: Bool = false
    var cookedData: [DVMultipleTodoitemtaskItemVM]?
}

class DVMultipleTodoitemtaskItemVM: NSObject {
    var text: String?
    var tags: [String]?
    var dueDate: Date?
    var dueDateText: String?
    var isRemindable: Bool = false
}
