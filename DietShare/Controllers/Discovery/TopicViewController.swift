//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast implicitly_unwrapped_optional

import UIKit

class TopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var topic: Topic?
    private var topicsModel = TopicsModelManager.shared
    private var userModel = UserModelManager.shared
    private var currentUser = UserModelManager.shared.getCurrentUser()
    private var selectedUserId: String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicDescription: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followers: UICollectionView!
    @IBOutlet weak var postsArea: UIView!
    private var postsTable: UITableView!
    private var postsTableController: PostsTableController!
    @IBOutlet weak var postAreaHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        initPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentTopic = self.topic {
            return topicsModel.getActiveUsers(currentTopic).count
        }
        return Constants.TopicPage.numOfDisplayedUsers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.followerListCell, for: indexPath as IndexPath) as! FollowerListCell
        if let currentTopic = self.topic {
            let id = topicsModel.getActiveUsers(currentTopic)[indexPath.item]
            if let user = userModel.getUserFromID(id) {
                cell.setName(user.getName())
                cell.setImage(user.getPhotoAsImage())
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentTopic = self.topic {
            self.selectedUserId = topicsModel.getActiveUsers(currentTopic)[indexPath.item]
            performSegue(withIdentifier: "topicToUser", sender: self)
        }
    }
    
    /**
     * View Related functions
     */
    
    private func initView() {
        print("InitView called")
        if let currentTopic = self.topic {
            self.topicName.text = currentTopic.getName()
            let currentImage = currentTopic.getImageAsUIImage()
            let currentAlpha = CGFloat(Constants.TopicPage.topicImageAlpha)
            setFittedImageAsSubview(view: topicImage, image: currentImage, alpha: currentAlpha)
            self.topicDescription.text = currentTopic.getDescription()
        }
        
        followButton.layer.cornerRadius = Constants.cornerRadius
        followButton.layer.borderColor = Constants.themeColor.cgColor
        followButton.layer.borderWidth = 2
        topicImage.layer.cornerRadius = Constants.cornerRadius
        
        initFollowButton()
    }
    
    private func initPosts() {
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as! PostsTableController
        postsTableController.setParentController(self)
        if let topic = self.topic {
            postsTableController.getTopicPosts(topic.getID())
        }
        self.addChildViewController(postsTableController!)
        postsTableController.setScrollDelegate(self)
        postsTable = postsTableController.getTable()
        postAreaHeight.constant = postsTable.contentSize.height
        postsTableController.view.frame.size = postsArea.frame.size
        postsArea.addSubview(postsTableController.view)
        postsTable.bounces = false
        postsTable.isScrollEnabled = false
    }
    
    private func initFollowButton() {
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

    // Hide navigation bar when scrolling up
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y > 0) {
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
        if let user = self.currentUser, let topic = self.topic {
            if followButton.tag == FollowStatus.notFollowed.rawValue {
                followButton.tag = FollowStatus.followed.rawValue
                followButton.setTitle(Text.unfollow, for: .normal)
                followButton.setTitleColor(Constants.themeColor, for: .normal)
                followButton.backgroundColor = UIColor.white
                self.topicsModel.addNewFollower(user, topic)
            } else {
                followButton.tag = FollowStatus.notFollowed.rawValue
                followButton.setTitle(Text.follow, for: .normal)
                followButton.setTitleColor(UIColor.white, for: .normal)
                followButton.backgroundColor = Constants.themeColor
                self.topicsModel.removeFollower(user, topic)
            }
        }
    }
    
    /**
     * Utility functions
     */
    
    func setTopic(_ topic: Topic?) {
        self.topic = topic
    }
    
    func setModelManager(_ modelManager: TopicsModelManager) {
        self.topicsModel = modelManager
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileController, let userId = self.selectedUserId {
            dest.setUserId(userId)
            dest.setPreviousSceneId(Identifiers.topicPage)
        }
    }
    
}

extension TopicViewController: ScrollDelegate {
    func didScroll() {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0)
//        {
//            if yOffset >= scrollView.contentSize.height - postsTable.frame.height {
//                scrollView.isScrollEnabled = false
//                postsTable.isScrollEnabled = true
//            }
//
//        }
    }
    func reachTop() {
//        scrollView.isScrollEnabled = true
//        postsTable.isScrollEnabled = false
    }
}

