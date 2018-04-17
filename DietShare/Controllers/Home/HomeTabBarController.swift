//
//  HomeTabBarController.swift
//  DietShare
//
//  Created by ZiyangMou on 17/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.

import Foundation
import UIKit

class HomeTabBarController: UITabBarController {

    var currentTab: Int = 0

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = self.tabBar.items else {
            return
        }
        if item == items[0] {
            currentTab = 0
        } else if item == items[1] {
            currentTab = 1
        } else if item == items[2] {
 
        } else if item == items[3] {
            currentTab = 3
        } else if item == items[4] {
            currentTab = 4
        }
    }
}
