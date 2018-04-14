//
//  PublisherController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
//  swiftlint:disable implicitly_unwrapped_optional force_unwrapping

import Foundation
import UIKit
import TagListView
import Cosmos
import Darwin

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
    @IBOutlet private weak var facebookView: UIImageView!
    @IBOutlet private weak var starRateView: CosmosView!

    private var restaurantId: String = "-1"
    private var topicsId: [String] = []
    private var rating: Double = 0.0

    private var isPostingOnFacebook: Bool = false
    private var offSetMultiplier: Int = 0

    private let placeholder: String = "Say something ..."
    private let toRestaurantSegueIdentifier: String = "ShowRestaurantListInPublisher"
    private let toTopicSegueIdentifier: String = "ShowTopicListInPublisher"
    private let maximumCharacter: Int = 140
    private let starRateAppearOffset: Int = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addGestureRecognizer()
        setUpTextView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStarRateView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toRestaurantSegueIdentifier {
            let destinationVC = segue.destination as! RestaurantListController
            destinationVC.delegate = self
        } else if segue.identifier == toTopicSegueIdentifier {
            let destinationVC = segue.destination as! TopicListController
            destinationVC.delegate = self
            destinationVC.selectedTopicID = topicsId
        }
    }

    private func setUpUI() {
        addTopBorder(view: restaurantButton, color: .lightGray)
        addTopBorder(view: topicButton, color: .lightGray)
        addBottomBorder(view: topicButton, color: .lightGray)

        tagListView.tagBackgroundColor = .orange
        tagListView.textFont = UIFont(name: "Verdana", size: 15)!

        facebookView.alpha = 0.5
        facebookView.isUserInteractionEnabled = true

        starRateView.isHidden = true
        starRateView.settings.fillMode = .half
        starRateView.didFinishTouchingCosmos = { rating in self.rating = rating }

        let publishButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(publish(_:)))
        publishButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = publishButton
    }

    private func setUpTextView() {
        textView.text = placeholder
        textView.textColor = UIColor.lightGray

        textView.becomeFirstResponder()

        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        textView.delegate = self
    }

    private func addGestureRecognizer() {
        let fbTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFacebookIconTap(_:)))
        facebookView.addGestureRecognizer(fbTapGestureRecognizer)
    }

    private func showStarRateView() {
        if offSetMultiplier == -1 {
            shiftBottomComponent(dx: 0, dy: CGFloat(-1 * starRateAppearOffset))
            starRateView.isHidden = true
        } else if offSetMultiplier == 1 {
            shiftBottomComponent(dx: 0, dy: CGFloat(starRateAppearOffset))
            starRateView.isHidden = false
            starRateView.rating = 0
        }
        offSetMultiplier = 0
    }

    // Add only bottom border for a UIView
    private func addBottomBorder(view: UIView, color: UIColor) {
        let frame = view.frame
        let lineView = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 1))
        lineView.backgroundColor = color
        view.addSubview(lineView)
    }

    // Add only top border for a UIView
    private func addTopBorder(view: UIView, color: UIColor) {
        let frame = view.frame
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        lineView.backgroundColor = color
        view.addSubview(lineView)
    }

    // Shift all component below restaurant
    private func shiftBottomComponent(dx: CGFloat, dy: CGFloat) {
        topicLabel.frame = topicLabel.frame.offsetBy(dx: dx, dy: dy)
        topicButton.frame = topicButton.frame.offsetBy(dx: dx, dy: dy)
        tagListView.frame = tagListView.frame.offsetBy(dx: dx, dy: dy)
        hashtagIcon.frame = hashtagIcon.frame.offsetBy(dx: dx, dy: dy)
        facebookView.frame = facebookView.frame.offsetBy(dx: dx, dy: dy)
    }

    @objc private func handleFacebookIconTap(_ sender: UITapGestureRecognizer) {
        if isPostingOnFacebook {
            isPostingOnFacebook = false
            facebookView.image = UIImage(named: "facebook-logo-gray")
            facebookView.alpha = 0.5
        } else {
            isPostingOnFacebook = true
            facebookView.image = UIImage(named: "facebook-logo-blue")
            facebookView.alpha = 1.0
        }
    }

    @objc private func publish(_ sender: UIBarButtonItem) {
        let text: String = textView.text != placeholder ? textView.text : ""
        let image = imageView.image!
        let restaurantId = self.restaurantId
        let topicsId = self.topicsId
        let rating = floor(self.rating * 2) / 2
        print("text: \(text)")
        print("image: \(image)")
        print("restaurantId: \(restaurantId)")
        print("topicsId: \(topicsId)")
        print("rating: \(rating)")
    }
}

extension PublisherController: RestaurantSenderDelegate {
    func sendRestaurant(restaurant: (id: String, name: String)) {

        if restaurant.id == "-1" {
            restaurantLabel.text = "Restaurant"
            restaurantLabel.textColor = UIColor.black
            locationIcon.image = UIImage(named: "location-mark-black")
            if restaurantId != "-1" {
                offSetMultiplier = -1
            }
        } else {
            restaurantLabel.text = restaurant.name
            restaurantLabel.textColor = UIColor.orange
            locationIcon.image = UIImage(named: "location-mark-orange")
            if restaurantId == "-1" {
                offSetMultiplier = 1
            } else if restaurantId != restaurant.id {
                starRateView.rating = 0
            }
        }

        restaurantId = restaurant.id
    }
}

extension PublisherController: TopicSenderDelegate {
    func sendTopics(topics: [(id: String, name: String)]) {
        let topicNames = topics.map { $0.name }
        self.topicsId = topics.map { $0.id }
        tagListView.removeAllTags()
        tagListView.addTags(topicNames)
        if self.topicsId.isEmpty {
            topicLabel.textColor = UIColor.black
            hashtagIcon.image = UIImage(named: "hashtag-black")
        } else {
            topicLabel.textColor = UIColor.orange
            hashtagIcon.image = UIImage(named: "hashtag-orange")
        }
    }
}

extension PublisherController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        if updatedText.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

            return false
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }

        return updatedText.count < maximumCharacter
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}
