//
//  PublisherController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit
import TagListView

protocol RestaurantSenderDelegate: class {
    func sendRestaurant(restaurant: (id: String, name: String))
}

protocol TopicSenderDelegate: class {
    func sendTopics(topics: [(id: String, name: String)])
}

class PublisherController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var restaurantLabel: UILabel!
    @IBOutlet private weak var topicLabel: UILabel!
    @IBOutlet private weak var restaurantButton: UIButton!
    @IBOutlet private weak var topicButton: UIButton!
    @IBOutlet private weak var locationIcon: UIImageView!
    @IBOutlet private weak var hashtagIcon: UIImageView!
    @IBOutlet private weak var tagListView: TagListView!
    
    private var restaurantName: String?
    private var restaurantID: String?
    private var topics: [String] = []
    private var topicsId: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRestaurantListInPublisher" {
            let destinationVC = segue.destination as! RestaurantListController
            destinationVC.delegate = self
        } else if segue.identifier == "ShowTopicListInPublisher" {
            let destinationVC = segue.destination as! TopicListController
            destinationVC.delegate = self
            destinationVC.selectedTopicID = topicsId
        }
    }

    private func setUpUI() {
        addTopBorder(view: restaurantButton, color: .lightGray)
        addBottomBorder(view: restaurantButton, color: .lightGray)
        addBottomBorder(view: topicButton, color: .lightGray)
        
        tagListView.tagBackgroundColor = .orange
        tagListView.textFont = UIFont(name: "Verdana", size: 15)!
    }

    private func addBottomBorder(view: UIView, color: UIColor) {
        let frame = view.frame
        let lineView = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 1))
        lineView.backgroundColor = color
        view.addSubview(lineView)
    }

    private func addTopBorder(view: UIView, color: UIColor) {
        let frame = view.frame
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        lineView.backgroundColor = color
        view.addSubview(lineView)
    }
}

extension PublisherController: RestaurantSenderDelegate {
    func sendRestaurant(restaurant: (id: String, name: String)) {
        restaurantID = restaurant.id
        if restaurantID == "-1" {
            restaurantLabel.text = "Restaurant"
            restaurantLabel.textColor = UIColor.black
            locationIcon.image = UIImage(named: "location-mark-black")
            restaurantName = nil
        } else {
            restaurantLabel.text = restaurant.name
            restaurantLabel.textColor = UIColor.orange
            locationIcon.image = UIImage(named: "location-mark-orange")
            restaurantName = restaurant.name
        }
    }
}

extension PublisherController: TopicSenderDelegate {
    func sendTopics(topics: [(id: String, name: String)]) {
        self.topics = topics.map { $0.name }
        self.topicsId = topics.map { $0.id }
        tagListView.removeAllTags()
        tagListView.addTags(self.topics)
        if self.topics.isEmpty {
            topicLabel.textColor = UIColor.black
            hashtagIcon.image = UIImage(named: "hashtag-black")
        } else {
            topicLabel.textColor = UIColor.orange
            hashtagIcon.image = UIImage(named: "hashtag-orange")
        }
    }
}
