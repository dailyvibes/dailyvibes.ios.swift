//
//  String+Extension.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-02-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation

struct StringExtension {
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
//            return results.map {
//                String(text[Range($0.range, in: text)!])
//            }
            return results.compactMap {
                Range($0.range, in: text).map { String(text[$0]) }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
