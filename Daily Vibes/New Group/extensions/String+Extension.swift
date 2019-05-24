//
//  String+Extension.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-02-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit

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

extension String {
    func imageFromEmoji(_ width:Int=40, _ height:Int=40) -> UIImage? {
//        let width = 40
//        let height = 40
        
//        let size = CGSize(width: width, height: height)
//
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
////        UIColor.white.set()
//        UIColor.clear.set()
//
//        let rect = CGRect(origin: .zero, size: size)
//
//        UIRectFill(CGRect(origin: .zero, size: size))
//
//        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: CGFloat(height-3))])
//
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return image
        
        //////////////////////////////////
        do {
            let font = UIFont.systemFont(ofSize: CGFloat(height-3))
            
            let stringBounds = (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
            UIGraphicsBeginImageContextWithOptions(stringBounds, false, 3.0)
            
            let xCenter = (stringBounds.width - CGFloat(width))/3.0
            let rect = CGRect(origin: CGPoint(x: xCenter, y: 0.0), size: stringBounds)
            
            UIColor.clear.set()
            UIRectFill(CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: stringBounds))
            
            (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: font])
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image!
        } catch {
            return nil
        }
    }
    
    /*
     FROM https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e
     
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.
     
     - Returns: 'String' object.
     */
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
