//
//  PublisherController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

protocol RestaurantSenderDelegate: class {
    func sendRestaurant(name: String)
}

protocol TopicSenderDelegate: class {
    func sendTopics(topics: [String])
}

class PublisherController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var restaurantLabel: UILabel!
    @IBOutlet private weak var topicLabel: UILabel!
    
    private var restaurantName: String?
    private var topics: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
    }
    
    func addGestureRecognizer() {
        let restaurantTap = UITapGestureRecognizer(target: self, action: #selector(goToRestaurantList(sender:)))
        restaurantLabel.isUserInteractionEnabled = true
        restaurantLabel.addGestureRecognizer(restaurantTap)
    }

    @objc func goToRestaurantList(sender: UITapGestureRecognizer) {
        print("restaurant tapped")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRestaurantListInPublisher" {
            let destinationVC = segue.destination as! RestaurantListController
            destinationVC.delegate = self
        } else if segue.identifier == "ShowTopicListInPublisher" {
            let destinationVC = segue.destination as! TopicListController
            destinationVC.delegate = self
        }
    }
}

extension PublisherController: RestaurantSenderDelegate {
    func sendRestaurant(name: String) {
        restaurantName = name
        restaurantLabel.text = name
    }
}

extension PublisherController: TopicSenderDelegate {
    func sendTopics(topics: [String]) {
        self.topics = topics
        print(self.topics)
    }
}
