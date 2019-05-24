//
//  DVMainNavigationViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-27.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import SwiftTheme

class DVMainNavigationViewController: UINavigationController {
    
    lazy var projectlistitemstvc : DVProjectItemsTVC = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let cidentifier = "DailyVibesMainTableVC"
        
        guard let tvc = sb.instantiateViewController(withIdentifier: cidentifier) as? DVProjectItemsTVC else {
            fatalError("cast to TodoItemsTableViewController did not work")
        }
        
        return tvc
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationBar.isTranslucent = false
        navigationBar.theme_backgroundColor = "Global.backgroundColor"
        view.theme_backgroundColor = "Global.backgroundColor"
        
//        var vclrs = viewControllers
//        
//        if !viewControllers.contains(projectlistitemstvc) {
//            print("does not contain projectlistitemstvc ... adding")
////            viewControllers.append(projectlistitemstvc)
//            vclrs.append(projectlistitemstvc)
//            setViewControllers(vclrs, animated: false)
//            if viewControllers.contains(projectlistitemstvc) {
//                print("added projectlistitemstvc all good")
//            }
//        } else {
//            print("contains projectlistitemstvc ... doin nothing")
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}
