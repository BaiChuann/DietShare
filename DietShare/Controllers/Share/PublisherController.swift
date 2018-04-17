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
import Cosmos
import Darwin
import FacebookShare
import SwiftMessages

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

    var shareState: ShareState?

    private var publishManager = PublishManager.shared
    private var restaurantId: String = "-1"
    private var topicsId: [String] = []
    private var rating: Double = 0.0
    private var additionalOptions: Set<PublishOption> = []

    private var offSetMultiplier: Int = 0
    private let amplifiedFrameTag: Int = 100
    private let placeholder: String = "Say something ..."
    private let toRestaurantSegueIdentifier: String = "ShowRestaurantListInPublisher"
    private let toTopicSegueIdentifier: String = "ShowTopicListInPublisher"
    private let maximumCharacter: Int = 140
    private let starRateAppearOffset: Int = 30
    private let notificationCenter = NotificationCenter.default
    private let facebookURL = NSURL(string: "fbauth2:/")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addGestureRecognizer()
        setUpTextView()
        setUpObserver()
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
        imageView.image = shareState?.modifiedPhoto
        imageView.isUserInteractionEnabled = true

        tagListView.tagBackgroundColor = Constants.themeColor
        tagListView.textFont = UIFont(name: "Verdana", size: 12)!

        facebookView.alpha = 0.5
        facebookView.isUserInteractionEnabled = true

        starRateView.isHidden = true
        starRateView.settings.fillMode = .half
        starRateView.didFinishTouchingCosmos = { rating in self.rating = rating }

        let publishButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(publish(_:)))
        publishButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = publishButton

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func setUpObserver() {
        notificationCenter.addObserver(self, selector: #selector(handleFacebookShareFail(_:)), name: .didFacebookShareFail, object: nil)
    }

    private func setUpTextView() {
        textView.text = placeholder
        textView.textColor = UIColor.lightGray

        //textView.becomeFirstResponder()

        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        textView.delegate = self
    }

    private func addGestureRecognizer() {
        let fbTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFacebookIconTap(_:)))
        facebookView.addGestureRecognizer(fbTapGestureRecognizer)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        view.addGestureRecognizer(tap)

        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(amplifyImage(_:)))
        imageView.addGestureRecognizer(imageTapGestureRecognizer)
    }

    @objc
    private func amplifyImage(_ sender: UITapGestureRecognizer) {
        guard let superView = view.superview else {
            return
        }
        self.navigationController?.isNavigationBarHidden = true
        let amplifiedFrame = UIView(frame: superView.frame)
        amplifiedFrame.backgroundColor = UIColor.black
        let image = imageView.image!
        let imageAspect = image.size.height / image.size.width
        let frameWidth = view.frame.width
        let frameHeight = frameWidth * imageAspect
        let frameY = view.frame.midY - frameHeight / 2
        let frame = CGRect(x: 0, y: frameY, width: frameWidth, height: frameHeight)
        let amplifiedImage = UIImageView(frame: frame)
        amplifiedImage.image = image
        amplifiedFrame.addSubview(amplifiedImage)
        amplifiedFrame.tag = amplifiedFrameTag
        superView.addSubview(amplifiedFrame)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAmplifiedImage(_:)))
        amplifiedFrame.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func dismissAmplifiedImage(_ sender: UITapGestureRecognizer) {
        guard let amplifiedFrame = view.superview?.viewWithTag(amplifiedFrameTag) else {
            return
        }
        amplifiedFrame.removeFromSuperview()
        navigationController?.isNavigationBarHidden = false
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

    // Shift all component below restaurant
    private func shiftBottomComponent(dx: CGFloat, dy: CGFloat) {
        topicLabel.frame = topicLabel.frame.offsetBy(dx: dx, dy: dy)
        topicButton.frame = topicButton.frame.offsetBy(dx: dx, dy: dy)
        tagListView.frame = tagListView.frame.offsetBy(dx: dx, dy: dy)
        hashtagIcon.frame = hashtagIcon.frame.offsetBy(dx: dx, dy: dy)
        facebookView.frame = facebookView.frame.offsetBy(dx: dx, dy: dy)
    }

    @objc
    private func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc
    private func handleFacebookShareFail(_ notification: NSNotification) {
        let warningView = MessageView.viewFromNib(layout: .cardView)
        warningView.configureTheme(.warning)
        warningView.configureDropShadow()
        warningView.configureContent(title: "Failed to share to Facebook", body: "Share to Facebook requires installation of Facebook app on your phone.")
        warningView.button?.isHidden = true
        SwiftMessages.show(view: warningView)
    }

    @objc
    private func handleFacebookIconTap(_ sender: UITapGestureRecognizer) {
        if additionalOptions.contains(.facebook) {
            additionalOptions.remove(.facebook)
            facebookView.image = UIImage(named: "facebook-logo-gray")
            facebookView.alpha = 0.5
        } else {
            guard let facebookURL = facebookURL, UIApplication.shared.canOpenURL(facebookURL as URL) else {
                notificationCenter.post(name: .didFacebookShareFail, object: nil)
                return
            }

            additionalOptions.insert(.facebook)
            facebookView.image = UIImage(named: "facebook-logo-blue")
            facebookView.alpha = 1.0
        }
    }

    @objc
    private func publish(_ sender: UIBarButtonItem) {
        let text: String = textView.text != placeholder ? textView.text : ""
        let image = imageView.image!
        let restaurantId = self.restaurantId
        let topicsId = self.topicsId
        let rating = floor(self.rating * 2) / 2
        let options = additionalOptions

        publishManager.post(text: text, image: image, restaurantId: restaurantId, topicsId: topicsId, rating: rating, additionalOption: options)
    }
}

extension PublisherController: RestaurantSenderDelegate {
    func sendRestaurant(restaurant: (id: String, name: String)) {

        if restaurant.id == "-1" {
            if restaurantId != "-1" {
                offSetMultiplier = -1
            }
        } else {
            restaurantLabel.text = restaurant.name
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
