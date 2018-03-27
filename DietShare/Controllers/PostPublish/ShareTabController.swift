//
//  ShareTabController.swift
//  DietShare
//
//  Created by Fan Weiguang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class ShareTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let controller = AppStoryboard.share.instance.instantiateInitialViewController() {
            addChildViewController(controller)
            view.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
    }
}
