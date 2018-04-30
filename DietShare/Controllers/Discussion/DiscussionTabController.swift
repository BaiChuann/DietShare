//
//  DiscussionTabController.swift
//  DietShare
//
//  Created by Fan Weiguang on 17/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class DiscussionTabController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
//        tabBarController?.tabBar.isHidden = true
    }
}
