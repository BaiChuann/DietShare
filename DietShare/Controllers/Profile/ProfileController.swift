//
//  ProfileController.swift
//  DietShare
//
//  Created by baichuan on 12/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class is the view controller of the profile page.
 * need to call setUserId() before navigate to this controller when display other users' profile or it will default to the current user.
 * displays user information and posts. 
 */
class ProfileController: UIViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var descrip: UILabel!
    @IBOutlet weak private var userPhoto: UIImageView!
    @IBOutlet weak private var followerCount: UIButton!
    @IBOutlet weak private var followingCount: UIButton!
    @IBOutlet weak private var topicCount: UIButton!
    @IBOutlet weak private var followButton: UIButton!
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak private var postsArea: UIView!
    @IBOutlet weak private var postsAreaHeight: NSLayoutConstraint!
    private var profile: Profile!
    private var userId = ""
    private var postsTableController: PostsTableController!
    private var tableView: UITableView!
    private var currentUser = UserModelManager.shared.getCurrentUser()!.getUserId()
    private var previousSceneId = ""
    override func viewWillAppear(_ animated: Bool) {
        if userId == currentUser && previousSceneId != Identifiers.topicPage  {
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = true
        } else {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
        }
        setUser(userId)
        postsTableController.getUserPosts(userId)
    }
    override func viewDidAppear(_ animated: Bool) {
        if userId == currentUser {
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        followButton.layer.cornerRadius = Constants.cornerRadius
        if userId == "" {
            setUserId(currentUser)
            if let pr = ProfileManager.shared.getProfile(currentUser) {
                self.profile = pr
            }
        } else {
            if let pr = ProfileManager.shared.getProfile(userId) {
                self.profile = pr
                if profile.getFollowers().contains(currentUser) {
                    followButton.setTitle("Unfollow", for: .normal)
                }
            }
        }
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as! PostsTableController
        postsTableController.setParentController(self)
        postsTableController.getUserPosts(userId)
        postsTableController.setScrollDelegate(self)
        tableView = postsTableController.getTable()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        self.addChildViewController(postsTableController)
        postsAreaHeight.constant = tableView.contentSize.height
        if let tabHeight = self.tabBarController?.tabBar.frame.height {
            postsAreaHeight.constant += tabHeight * 2
        }
        postsTableController.view.frame.size = postsArea.frame.size
        postsArea.addSubview(postsTableController.view)
        setNavigation()
    }
    func setNavigation() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        if userId == "" {
            setUserId(currentUser)
        }
        setUser("userId")
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "topic" {
            if let destinationVC = segue.destination as? UserListController {
                destinationVC.session = 2
                destinationVC.userId = userId
            }
        }
        if segue.identifier == "follower" {
            if let destinationVC = segue.destination as? UserListController {
                destinationVC.session = 0
                destinationVC.userId = userId
            }
        }
        if segue.identifier == "following" {
            if let destinationVC = segue.destination as? UserListController {
                destinationVC.session = 1
                destinationVC.userId = userId
            }
        }
    }
    func setUserId(_ id: String) {
        self.userId = id
    }
    func setPreviousSceneId(_ sceneId: String) {
        self.previousSceneId = sceneId
    }
    func setUser(_ id: String) {
        guard let user = UserModelManager.shared.getUserFromID(id) else {
            return
        }
        userName.text = user.getName()
        userPhoto.image = user.getPhotoAsImage()
        descrip.text = profile.getDescription()
        followerCount.setTitle(String(profile.getFollowers().count), for: .normal)
        followingCount.setTitle(String(profile.getFollowings().count), for: .normal)
        topicCount.setTitle(String(profile.getTopics().count), for: .normal)
        postsTableController.getUserPosts(id)
        if userId == currentUser {
            self.followButton.isHidden = true
        } else {
            self.editButton.isHidden = true
        }
    }
    @IBAction func onFollowClicked(_ sender: Any) {
        if followButton.currentTitle == "Follow" {
            followButton.setTitle("Unfollow", for: .normal)
            profile.addFollower(currentUser)
            if let pr = ProfileManager.shared.getProfile(currentUser) {
                pr.addFollowing(currentUser)
            }
            followerCount.setTitle(String(profile.getFollowers().count), for: .normal)
        } else {
            followButton.setTitle("Follow", for: .normal)
            profile.deleteFollower(currentUser)
            if let pr = ProfileManager.shared.getProfile(currentUser) {
                pr.deleteFollowing(userId)
            }
            followerCount.setTitle(String(profile.getFollowers().count), for: .normal)
        }
    }
    @IBAction func onEditClick(_ sender: Any) {
    }
    @IBAction func onFollowerClicked(_ sender: Any) {
    }
    @IBAction func onFollowingClicked(_ sender: Any) {
    }
    @IBAction func onTopicClicked(_ sender: Any) {
    }
}
// SCROLL VIEW IMPLEMENTATION
extension ProfileController: UIScrollViewDelegate, ScrollDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        postsTableController.didScroll()
    }
    func reachTop() {
    }
    func didScroll() {
    }
}

extension ProfileController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
