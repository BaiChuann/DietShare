//
//  DiscoverPageViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 5/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class DiscoverPageViewController: ScrollingStackController {
    
    private var shortListsViewController = ShortListsViewController.create()
    private var postsTableController = PostsTableController.create()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func reload() {
        self.viewControllers = [shortListsViewController, postsTableController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
