//
//  TodoItemUITableView.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-11-17.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit

class TodoItemUITableView: UITableView {
    
    var emptyView: LoadingTableViewEmptyView = UINib(nibName: "LoadingTableViewEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! LoadingTableViewEmptyView
    
    func showEmptyView() {
        emptyView.isHidden = false
        self.tableFooterView = UIView(frame: .zero)
        self.backgroundView = emptyView
    }
    
    func hideEmptyView() {
        emptyView.isHidden = true
        self.sendSubviewToBack(emptyView)
        self.backgroundView = nil
    }

}
