//
//  WhatsNewViewController+TitleView.swift
//  WhatsNewKit-iOS
//
//  Created by Sven Tiigi on 06.06.18.
//  Copyright © 2018 WhatsNewKit. All rights reserved.
//

import UIKit

public extension WhatsNewViewController {
    
    /// The TitleView
    struct TitleView: Equatable {
        
        /// The title font
        public var titleFont: UIFont
        
        /// The title color
        public var titleColor: UIColor
        
        /// The title alignment
        public var titleAlignment: NSTextAlignment
        
        /// The Animation
        public var animation: Animation?
        
        /// The SecondaryColor
        public var secondaryColor: SecondaryColor?
        
        /// Default initializer
        ///
        /// - Parameters:
        ///   - titleFont: The title font. Default value `size: 30, weight: semibold`
        ///   - titleColor: The title color. Default value `.black`
        ///   - titleAlignment: The title alignment. Default value `center`
        ///   - animation: The Animation. Default value `nil`
        ///   - secondaryColor: The SecondaryColor. Default value `nil`
        public init(titleFont: UIFont = .systemFont(ofSize: 30, weight: .semibold),
                    titleColor: UIColor = .black,
                    titleAlignment: NSTextAlignment = .center,
                    animation: Animation? = nil,
                    secondaryColor: SecondaryColor? = nil) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.titleAlignment = titleAlignment
            self.animation = animation
            self.secondaryColor = secondaryColor
        }
        
    }
    
}

// MARK: - SecondaryColor

public extension WhatsNewViewController.TitleView {
    
    /// The SecondaryColor
    struct SecondaryColor: Equatable {
        
        /// The start index
        var startIndex: Int
        
        /// The length
        var length: Int
        
        /// The color
        var color: UIColor
        
        /// Designated Initializer
        ///
        /// - Parameters:
        ///   - startIndex: The start index
        ///   - length: The length
        ///   - color: The color
        public init(startIndex: Int,
                    length: Int,
                    color: UIColor) {
            self.startIndex = startIndex
            self.length = length
            self.color = color
        }
        
    }
    
}
