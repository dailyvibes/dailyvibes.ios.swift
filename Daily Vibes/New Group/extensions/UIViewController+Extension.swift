//
//  UIViewController+Extension.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2019-01-10.
//  Copyright © 2019 Alex Kluew. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func adjustLargeTitleSize() {
        guard let title = title, #available(iOS 11.0, *) else { return }
        
        let maxWidth = UIScreen.main.bounds.size.width - 60
        var fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        var width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
        
        while width > maxWidth {
            fontSize -= 1
            width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
        }
        
//        if var titleAttributes = navigationController?.navigationBar.largeTitleTextAttributes {
//            titleAttributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: fontSize)
//            navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
//        }
        
        print("setting largetitle text attributes...")
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)
        ]
    }
}
