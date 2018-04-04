//
//  HomeTabController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class HomeTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let controller = AppStoryboard.home.instance.instantiateInitialViewController() {
            addChildViewController(controller)
            view.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
    }
}