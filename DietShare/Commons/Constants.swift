//
//  Constants.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    case main = "Main"
    case share = "Share"
    case discovery = "Discovery"
    case home = "Home"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}


protocol EnumCollection : Hashable {}

extension EnumCollection {
    static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}

enum RestaurantType: String, EnumCollection {
    case Vegetarian = "Vegetarian"
    case European = "European"
    case Indian = "Indian"
    case Japanese = "Japanese"
    case American = "American"
    case Korean = "Korean"
    case Chinese = "Chinese"
    case Thai = "Thai"
}

enum ListType: String {
    case User = "user"
    case Post = "post"
    case Comment = "comment"
    case Rating = "rating"
    case RestaurantType = "restaurantType"
}

enum RatingScore: Int {
    case oneStar = 1
    case twoStar = 2
    case threeStar = 3
    case fourStar = 4
    case fiveStar = 5
}

struct Identifiers {
    public static let topicShortListCell = "topicShortListCell"
    public static let topicFullListCell = "topicFullListCell"
    public static let followerListCell = "followerListCell"
    public static let topicListToDetailPage = "topicListToDetailPage"
    public static let discoveryToTopicPage = "discoveryToTopicPage"
    public static let restaurantShortListCell = "restaurantShortListCell"
    public static let restaurantFullListCell = "restaurantFullListCell"
    public static let restaurantListToDetailPage = "restaurantListToDetailPage"
    public static let discoveryToRestaurantPage = "discoveryToRestaurantPage"
}

struct Text {
    public static let follow = "+Follow"
    public static let unfollow = "Unfollow"
    public static let unknownDistance = "Unknow Distance"
    public static let rateTheRestaurant = "Rate this restaurant"
    public static let yourRating = "Your Rating"
}

enum FollowStatus: Int {
    case followed = 1
    case notFollowed = 0
}

enum Sorting: Int {
    case byRating = 0
    case byDistance = 1
}

struct Constants {
    public static let fontRegular = "Verdana"
    public static let fontBold = "Verdana-Bold"
    public static let themeColor = hexToUIColor(hex: "FFD147")
    public static let photoLibraryBackgroundColor = hexToUIColor(hex: "D8D8D8")
    public static let lightBackgroundColor = hexToUIColor(hex: "EAEAEA")
    public static let lightTextColor = hexToUIColor(hex: "#CACFD0")
    public static let normalTextColor = hexToUIColor(hex: "#9CA0A1")
    public static let darkTextColor = hexToUIColor(hex: "#565859")
    public static let cornerRadius: CGFloat = 5
    public static let buttonBorderWidth: CGFloat = 1
    public static let defaultListDisplayCount = 10
    public static let defaultBottonBorderWidth: CGFloat = 1.0
    public static let defaultLabelBorderWidth: CGFloat = 3.0
    public static let defaultCornerRadius: CGFloat = 5.0
    public static let defaultTagCornerRadius: CGFloat = 8.0
    public static let numOfItemPerLoad = 10
    public static let voidBackgroundImagePath = "void-bg"
    public static let ratingAnimationDuration = 1.0

    struct DiscoveryPage {
        public static let numOfDisplayedTopics = 6
        public static let numOfDisplayedRestaurants = 5
        public static let shortListCellAlpha: CGFloat = 0.8
        public static let shortListsViewProportion: CGFloat = 0.6
        public static let longScrollViewHeight: CGFloat = 1200
    }

    struct TopicPage {
        public static let numOfDisplayedUsers = 10
        public static let topicImageAlpha: CGFloat = 0.8
        public static let longScrollViewHeight: CGFloat = 1400
    }

    struct RestaurantPage {
        public static let numOfDisplayedUsers = 10
        public static let restaurantImageAlpha: CGFloat = 0.8
        public static let longScrollViewHeight: CGFloat = 1200
    }
    
    struct Tables {
        public static let users = "users"
        public static let topics = "topics"
        public static let restaurants = "restaurants"
    }
    
    struct Test {
        public static let keyword = "Vegi"
        public static let withKeyword = "\(keyword)Life"
        public static let withoutKeyword = "Life"
    }
}
