//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var topic: Topic?
    var currentUser: User?
    
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicDescription: UITextView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initUser()
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentTopic = self.topic {
            return currentTopic.getFollowersID().getListAsArray().count
        }
        return Constants.TopicPage.numOfDisplayedUsers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.followerListCell, for: indexPath as! IndexPath) as! FollowerListCell
        if let currentTopic = self.topic {
            cell.setName(currentTopic.getFollowersID().getListAsArray()[indexPath.item])
            // TODO - obtain image of the user (after UserManager is implemented)
        }
        return cell
    }
    
    /**
     * View Related functions
     */
    
    private func initView() {
        print("InitView called")
        if let currentTopic = self.topic {
            self.topicName.text = currentTopic.getName()
            addRoundedRectBackground(self.topicName, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
            self.topicImage.image = currentTopic.getImage()
            self.topicImage.alpha = CGFloat(Constants.TopicPage.topicImageAlpha)
            self.topicDescription.text = currentTopic.getDescription()
        }
        
        addRoundedRectBackground(self.followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.white.cgColor, UIColor.clear)
        
        initFollowButton()
    }
    
    private func initFollowButton() {
        assert(topic != nil)
        assert(currentUser != nil)
        if let user = self.currentUser, let currentTopic = self.topic {
            let followers = currentTopic.getFollowersID().getListAsSet()
            if followers.contains(user.getUserId()) {
                self.followButton.tag = FollowStatus.followed.rawValue
                self.followButton.setTitle(Text.unfollow, for: .normal)
            } else {
                self.followButton.tag = FollowStatus.notFollowed.rawValue
                self.followButton.setTitle(Text.follow, for: .normal)
            }
        }
    }
    
    // Handle tapping of follow button
    @IBAction func followButtonPressed(_ sender: UIButton) {
        assert(currentUser != nil)
        // TODO - change button selected background color
        if let user = self.currentUser {
            if followButton.tag == FollowStatus.followed.rawValue {
                
                followButton.tag = FollowStatus.notFollowed.rawValue
                followButton.setTitle(Text.unfollow, for: .normal)
                followButton.layer.borderColor = UIColor.gray.cgColor
                self.topic?.addFollower(user)
            } else {
                followButton.tag = FollowStatus.followed.rawValue
                followButton.setTitle(Text.follow, for: .normal)
                followButton.layer.borderColor = UIColor.white.cgColor
                self.topic?.removeFollower(user)
            }
        }
    }
    
    /**
     * Utility functions
     */
    
    func setTopic(_ topic: Topic?) {
        self.topic = topic
    }
    
    /**
     * Test functions
     */
    private func initUser() {
        self.currentUser = User(userId: "1", name: "James", password: "0909", photo: #imageLiteral(resourceName: "vegi-life"))
    }
    
}