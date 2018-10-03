//
//  DailyVibesTabBarViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-09.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import DeckTransition

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
        
        var preferredStatusBarStyle : UIStatusBarStyle {
            return .lightContent
        }
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
            let storyboard = UIStoryboard.init(name: "DVMultipleTodoitemtaskItems", bundle: nil)
            let tvc = storyboard.instantiateViewController(withIdentifier: "DVMultipleTodoitemtaskItemsNC")
            
            let transitionDelegate = DeckTransitioningDelegate(isSwipeToDismissEnabled: false)
            tvc.transitioningDelegate = transitionDelegate
            tvc.modalPresentationStyle = .custom
//            UIApplication.shared.statusBarStyle = .lightContent
            
            self.present(tvc, animated: true, completion: nil)
            
            return false
        }
        
        if viewController is DVMainNavigationViewController {
            if viewController == tabBarController.selectedViewController {
//                print("selected the same DVMainNavigationViewController controller")
                let nav = viewController as! DVMainNavigationViewController
                guard let tableCont = nav.topViewController as? TodoItemsTableViewController else {
                    return true
                }
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

//extension UITabBarController {
//    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
//        if (tabBarIsVisible() == visible) { return }
//        let frame = self.tabBar.frame
//        let height = frame.size.height
//        let offsetY = (visible ? -height : height)
//
//        // animation
//        UIViewPropertyAnimator(duration: duration, curve: .linear) {
//            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
//            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
//            self.view.setNeedsDisplay()
//            self.view.layoutIfNeeded()
//            }.startAnimation()
//    }
//
//    func tabBarIsVisible() ->Bool {
////        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
//        return self.tabBar.frame.origin.y < view.bounds.height
//    }
//}


extension UITabBarController {
    
    private struct AssociatedKeys {
        // Declare a global var to produce a unique address as the assoc object handle
        static var orgFrameView:     UInt8 = 0
        static var movedFrameView:   UInt8 = 1
    }
    
    var orgFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.orgFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.orgFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    var movedFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.movedFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.movedFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let movedFrameView = movedFrameView {
            view.frame = movedFrameView
        }
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        //since iOS11 we have to set the background colour to the bar color it seams the navbar seams to get smaller during animation; this visually hides the top empty space...
        view.backgroundColor =  self.tabBar.barTintColor
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        //we should show it
        if visible {
            tabBar.isHidden = false
            UIView.animate(withDuration: animated ? 0.3 : 0.0) {
                //restore form or frames
                self.view.frame = self.orgFrameView!
                //errase the stored locations so that...
                self.orgFrameView = nil
                self.movedFrameView = nil
                //...the layoutIfNeeded() does not move them again!
                self.view.layoutIfNeeded()
            }
        }
            //we should hide it
        else {
            //safe org positions
            orgFrameView   = view.frame
            // get a frame calculation ready
            let offsetY = self.tabBar.frame.size.height
            movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
            //animate
            UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
                self.view.frame = self.movedFrameView!
                self.view.layoutIfNeeded()
            }) {
                (_) in
                self.tabBar.isHidden = true
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return orgFrameView == nil
    }
}
