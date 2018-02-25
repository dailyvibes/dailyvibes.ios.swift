//
//  DailyVibesTabBarViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-09.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class DailyVibesTabBarViewController: UITabBarController, UITabBarControllerDelegate {

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
    
//    private let menuButton = UIButton(frame: CGRect.zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabLocalization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
//        setupMiddleButton()
    }
    
    fileprivate func setupTabLocalization() {
        self.tabBar.items?[0].title = NSLocalizedString("Home", tableName: "Localizable", bundle: .main, value: "**DID NOT FIND Home**", comment: "")
        self.tabBar.items?[1].title = NSLocalizedString("Add", tableName: "Localizable", bundle: .main, value: "**DID NOT FIND Add**", comment: "")
        self.tabBar.items?[2].title = NSLocalizedString("Progress", tableName: "Localizable", bundle: .main, value: "**DID NOT FIND Progress**", comment: "")
        self.tabBar.items?[3].title = NSLocalizedString("Settings", tableName: "Localizable", bundle: .main, value: "**DID NOT FIND Settings**", comment: "")
    }
    
//    var previousController: TodoItemsTableViewController?
    
//    @objc func handleListChange() {
//        let storyboard = UIStoryboard.init(name: "DVMultipleTodoitemtaskItems", bundle: nil)
//        let tvc = storyboard.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsController")
//        navigationController?.pushViewController(tvc, animated: true)
//    }
    
    // MARK - Custom TabBarControllerAction
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is DummyViewController {
            let titleText = NSLocalizedString("Add a to-do", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Add a to-do **", comment: "")
            let alertController = UIAlertController.init(title: titleText, message: nil, preferredStyle: .actionSheet)
            
            let singleText = NSLocalizedString("Single", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Single **", comment: "")
            
            let singleCreateAction = UIAlertAction.init(title: singleText, style: .default, handler: { (alertAction) in
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "AddNavigationVC")
                self.present(newVC, animated: true, completion: nil)
            })
//            singleCreateAction.accessibilityIdentifier = "single_create_action"
            
            alertController.addAction(singleCreateAction)
            
            let multipleText = NSLocalizedString("Multiple", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Multiple **", comment: "")
            let multipleCreateAction = UIAlertAction.init(title: multipleText, style: .default, handler: { (alertAction) in
                let storyboard = UIStoryboard.init(name: "DVMultipleTodoitemtaskItems", bundle: nil)
                let tvc = storyboard.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsNC")
                self.present(tvc, animated: true, completion: nil)
            })
//            multipleCreateAction.accessibilityIdentifier = "multiple_create_action"
            
            alertController.addAction(multipleCreateAction)
            
            let cancelText = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel **", comment: "")
            alertController.addAction(UIAlertAction.init(title: cancelText, style: .cancel, handler: nil))
            
            self.present(alertController, animated: true)
            
            return false
        }
        
        if viewController is DVMainNavigationViewController {
            if viewController == tabBarController.selectedViewController {
//                print("selected the same DVMainNavigationViewController controller")
                let nav = viewController as! DVMainNavigationViewController
                let tableCont = nav.topViewController as! TodoItemsTableViewController
//                tableCont.tableView.setContentOffset(CGPoint(x: 0.0, y: -tableCont.tableView.contentInset.top), animated: true)
//                tableCont.tableView.setContentOffset(CGPointZero, animated: true)
//                tableCont.tableView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
                tableCont.tableView.setContentOffset(CGPoint.zero, animated: true)
//                print("should have scrolled to the top")
            }
        }
        
        return true
    }
    
//    func setupMiddleButton() {
//        let numberOfItems = CGFloat(tabBar.items!.count)
//        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
//        menuButton.frame = CGRect(x: 0, y: 0, width: tabBarItemSize.width, height: tabBar.frame.size.height)
//        var menuButtonFrame = menuButton.frame
//        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height - self.view.safeAreaInsets.bottom
//        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
//        menuButton.frame = menuButtonFrame
////        menuButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
//        menuButton.setImage(#imageLiteral(resourceName: "tabbed_add"), for: .normal)
//        menuButton.tintColor = .blue
//        menuButton.addTarget(self, action: #selector(clickAddButton), for: .touchUpInside)
//        self.view.addSubview(menuButton)
//        self.view.layoutIfNeeded()
//    }
//
//    @objc private func clickAddButton() {
//        performSegue(withIdentifier: "AddTodoItem", sender: nil)
//    }
    
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
