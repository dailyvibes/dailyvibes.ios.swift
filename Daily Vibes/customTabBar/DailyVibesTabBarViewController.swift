//
//  DailyVibesTabBarViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-09.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class DailyVibesTabBarViewController: UITabBarController, UITabBarControllerDelegate {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private let menuButton = UIButton(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
//        setupMiddleButton()
    }
    
    // MARK - Custom TabBarControllerAction
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("trying to show the new controller...")
        print("viewController = \(viewController)")
        if viewController is DummyViewController {
            print("trying to show the new controller...")
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "AddNavigationVC") {
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        
        return true
    }
    
    func setupMiddleButton() {
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        menuButton.frame = CGRect(x: 0, y: 0, width: tabBarItemSize.width, height: tabBar.frame.size.height)
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height - self.view.safeAreaInsets.bottom
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
//        menuButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        menuButton.setImage(#imageLiteral(resourceName: "tabbed_add"), for: .normal)
        menuButton.tintColor = .blue
        menuButton.addTarget(self, action: #selector(clickAddButton), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.layoutIfNeeded()
    }
    
    @objc private func clickAddButton() {
        performSegue(withIdentifier: "AddTodoItem", sender: nil)
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        guard let items = tabBar.items else { return }
//        if items.index(of: item) == 1 {
//            // catch the add button
//            performSegue(withIdentifier: "AddTodoItem", sender: nil)
//        }
////        print("the selected index is : \(String(describing: items.index(of: item)))")
//    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        menuButton.frame.origin.y = self.view.bounds.height - menuButton.frame.height - self.view.safeAreaInsets.bottom
//    }

}
