//
//  DiscoveryTabController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class DiscoveryTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let controller = AppStoryboard.discovery.instance.instantiateInitialViewController() {
            addChildViewController(controller)
            view.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
}
