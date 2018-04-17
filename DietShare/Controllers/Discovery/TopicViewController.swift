//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import UIKit

class TopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var topic: Topic?
    private var topicsModel: TopicsModelManager<Topic>?
    private var userModel = UserModelManager.shared
    private var currentUser = UserModelManager.shared.getCurrentUser()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicDescription: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followers: UICollectionView!
    @IBOutlet weak var postsArea: UIView!
    private var postsTable: UITableView!
    private var postsTableController: PostsTableController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: Constants.TopicPage.longScrollViewHeight)
        scrollView.delegate = self

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        initView()
        initPosts()
        
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
            self.topicImage.image = currentTopic.getImageAsUIImage()
            self.topicDescription.text = currentTopic.getDescription()
        }
        
        addRoundedRectBackground(self.followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.black.cgColor, UIColor.clear)
        
        initFollowButton()
    }
    
    private func initPosts() {
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as? PostsTableController
        postsTableController?.setParentController(self)
        if let topic = self.topic {
            postsTableController?.getTopicPosts(topic.getID())
        }
        self.addChildViewController(postsTableController!)
        
        postsTableController?.setScrollDelegate(self)
        postsTable = postsTableController?.getTable()
        postsTable.frame = postsArea.frame
        postsArea.removeFromSuperview()
        scrollView.addSubview(postsTable)
        postsTable.bounces = false
        postsTable.isScrollEnabled = false
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
        if let user = self.currentUser, let topic = self.topic {
            if followButton.tag == FollowStatus.notFollowed.rawValue {
                followButton.tag = FollowStatus.followed.rawValue
                followButton.setTitle(Text.unfollow, for: .normal)
                followButton.layer.borderColor = UIColor.gray.cgColor
                followButton.titleLabel?.textColor = UIColor.gray
                self.topicsModel?.addNewFollower(user, topic)
            } else {
                followButton.tag = FollowStatus.notFollowed.rawValue
                followButton.setTitle(Text.follow, for: .normal)
                followButton.layer.borderColor = UIColor.black.cgColor
                followButton.titleLabel?.textColor = UIColor.black
                self.topicsModel?.removeFollower(user, topic)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicListViewController {
        }
    }
    
    /**
     * Utility functions
     */
    
    func setTopic(_ topic: Topic?) {
        self.topic = topic
    }
    
    func setModelManager(_ modelManager: TopicsModelManager<Topic>) {
        self.topicsModel = modelManager
    }
    
    /**
     * Test functions
     */
    
}

extension TopicViewController: ScrollDelegate {
    func didScroll() {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0)
        {
            if yOffset >= scrollView.contentSize.height - postsTable.frame.height {
                scrollView.isScrollEnabled = false
                postsTable.isScrollEnabled = true
            }
            
        }
    }
    func reachTop() {
        scrollView.isScrollEnabled = true
        postsTable.isScrollEnabled = false
    }
}

