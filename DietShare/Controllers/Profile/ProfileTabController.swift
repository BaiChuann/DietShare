//
//  HomeTabController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class ProfileTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = Bundle.main.loadNibNamed("Profile", owner: nil, options: nil)?.first as! ProfileController
        controller.setUser("1")
        addChildViewController(controller)
        controller.setTabShow(true)
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
}

