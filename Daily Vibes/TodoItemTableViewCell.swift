//
//  TodoItemTableViewCell.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-04.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var todoItemLabel: UILabel!
    @IBOutlet weak var todoItemTagsLabel: UILabel!
    @IBOutlet weak var emotionsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.addGradientBackground(firstColor: .green, secondColor: .blue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        self.addGradientBackground(firstColor: .green, secondColor: .blue)
        // Configure the view for the selected state
    }

}

//extension UIView{
//    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
//        clipsToBounds = true
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
//        gradientLayer.frame = self.bounds
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
//        print(gradientLayer.frame)
//        self.layer.insertSublayer(gradientLayer, at: 0)
//    }
//}

