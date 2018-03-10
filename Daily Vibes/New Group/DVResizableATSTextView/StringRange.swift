////
////  StringRange.swift
////
////
////  Copyright (c) 2015 Barry Allard <barry.allard@gmail.com>
////
////  Available at: https://gist.github.com/steakknife/78daa13c6773dc23d73b
////
////  MIT License
////
//
//import Foundation
//
//func +<T: Int>(lhs: String.Index, rhs: T) -> String.Index {
//    var r = lhs
//    var x = rhs
//    while x > 0 { // advance() won't work because IntegerType and String.Index are incompatible
//        r = r.successor()
//        x--
//    }
//    while x < 0 {
//        r = r.predecessor()
//        x++
//    }
//    return r
//}
//
//func -<T: IntegerLiteralType>(lhs: String.Index, rhs: T) -> String.Index {
//    var r = lhs
//    var x = rhs
//    while x > 0 {
//        r = r.predecessor()
//        x--
//    }
//    while x < 0 {
//        r = r.successor()
//        x++
//    }
//    return r
//}
//
//extension NSRange {
//    init(range: Range<Int>) {
//        location = range.startIndex
//        length = range.endIndex - range.startIndex
//    }
//    
//    var range: Range<Int> { return Range<Int>(start: location, end: location + length) }
//}
//
//extension String {
//    var nsrange: NSRange { return NSMakeRange(0, count(self)) }
//    
//    var range: Range<Int> { return Range<Int>(start: 0, end: count(self)) }
//    
//    subscript (index: Int) -> String {
//        return self[index...index]
//    }
//    
//    subscript (index: Int) -> Character {
//        return self[index] as Character
//    }
//    
//    subscript (range: Range<String.Index>) -> String {
//        return substringWithRange(range)
//    }
//    
//    subscript (range: NSRange) -> String {
//        return self[toStringRange(range)]
//    }
//    
//    // allows "abcd"[0...1] // "ab"
//    subscript (range: Range<Int>) -> String {
//        return self[toStringRange(range)]
//    }
//    
//    func toStringRange(range: NSRange) -> Range<String.Index> {
//        return toStringRange(range.range)
//    }
//    
//    func toStringRange(range: Range<Int>) -> Range<String.Index> {
//        let start = startIndex + max(range.startIndex, 0)
//        let end = startIndex + min(range.endIndex, count(self))
//        return Range<String.Index>(start: start, end: end)
//    }
//}

