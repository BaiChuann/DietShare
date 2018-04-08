//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var topic: Topic?
    private var userModel = UserModelManager.shared
    var currentUser: User?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicDescription: UITextView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
        scrollView.delegate = self
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.followerListCell, for: indexPath as IndexPath) as! FollowerListCell
        if let currentTopic = self.topic {
            let id = currentTopic.getFollowersID().getListAsArray()[indexPath.item]
            if let user = userModel.getUserFromID(id) {
                cell.setName(user.getName())
                cell.setImage(user.getPhoto())
            }
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
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }
    
    // Handle tapping of follow button
    @IBAction func followButtonPressed(_ sender: UIButton) {
        assert(currentUser != nil)
        if let user = self.currentUser {
            if followButton.tag == FollowStatus.notFollowed.rawValue {
                followButton.tag = FollowStatus.followed.rawValue
                followButton.setTitle(Text.unfollow, for: .normal)
                followButton.layer.borderColor = UIColor.gray.cgColor
                self.topic?.addFollower(user)
            } else {
                followButton.tag = FollowStatus.notFollowed.rawValue
                followButton.setTitle(Text.follow, for: .normal)
                followButton.layer.borderColor = UIColor.white.cgColor
                self.topic?.removeFollower(user)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicListViewController {
            dest.currentUser = self.currentUser
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
