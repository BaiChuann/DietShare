//
//  Constants.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard :String {
    case main = "Main"
    case share = "Share"
    case discovery = "Discovery"

    var instance :UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

enum RestaurantType: String {
    case Vegetarian = "Vegetarian"
    case Asian = "Asian"
    case European = "European"
    case Indian = "Indian"
    case Japanese = "Japanese"
}

enum IDType: String {
    case User = "user"
    case Post = "post"
    case Comment = "comment"
}

struct Identifiers {
    public static let topicShortListCell = "topicShortListCell"
    public static let topicFullListCell = "topicFullListCell"
    public static let activeUserListCell = "activeUserListCell"
}

struct Constants {
    public static let fontRegular = "Verdana"
    public static let fontBold = "Verdana-Bold"
    public static let themeColor = hexToUIColor(hex: "FFD147")
    public static let lightTextColor = hexToUIColor(hex: "#CACFD0")
    public static let normalTextColor = hexToUIColor(hex: "#9CA0A1")
    public static let darkTextColor = hexToUIColor(hex: "#565859")
    public static let cornerRadius: CGFloat = 5
    public static let buttonBorderWidth: CGFloat = 1
    public static let defaultListDisplayCount = 10
    
    struct DiscoveryPage {
        public static let numOfDisplayedTopics = 6
    }
    
    struct TopicPage {
        public static let numOfDisplayedUsers = 10
    }
}
