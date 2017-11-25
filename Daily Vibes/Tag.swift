//
//  Tag.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-19.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Tag: NSManagedObject {
    class func createTag(in context: NSManagedObjectContext) -> Tag {
        let tag = Tag(context: context)
        tag.uuid = UUID.init()
        tag.createdAt = Date()
        tag.updatedAt = Date()
        return tag
    }
}
