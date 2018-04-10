//
//  TopicListController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class TopicListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var topicModel: TopicsModelManager<Topic>?
    private var selectedTopic: Topic?
    private var topics = [Topic]()
    
    var currentUser: User?
    
    
    @IBOutlet weak var topicListView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicListView {
            // TODO - only show 10 entries at a time
            return self.topics.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicFullListCell, for: indexPath as IndexPath) as! TopicFullListCell
        
        let topicList = self.topics
        cell.setImage(topicList[indexPath.item].getImageAsUIImage())
        cell.setName(topicList[indexPath.item].getName())
        cell.initFollowButtonView()
        addTapHandler(cell, topicList, indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let model = self.topicModel {
            let lastElement = self.topics.count - 1
            if indexPath.row == lastElement {
                if lastElement + Constants.numOfItemPerLoad < model.getNumOfTopics() {
    //                startAnimating()
                    let moreTopics = model.getTopics(self.topics.count, Constants.numOfItemPerLoad)
                    self.topics.append(contentsOf: moreTopics)
                    self.topicListView.reloadData()
                }
            }
        }

    }
    
    // Add handling of tapping on follow button
    
    private func addTapHandler(_ cell: TopicFullListCell, _ topicList: [Topic], _ indexPath: IndexPath) {
        cell.addSubview(cell.followButton)
        if let user = self.currentUser {
            let currentTopic = topicList[indexPath.item]
            let followers = currentTopic.getFollowersID().getListAsSet()
            if followers.contains(user.getUserId()) {
                toggleToFollowed(cell.followButton)
            } else {
                toggleToUnfollowed(cell.followButton)
            }
        }
        cell.followButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
    }
    
    // Toggle the followButton to "followed" state
    private func toggleToFollowed(_ button: UIButton) {
        button.tag = FollowStatus.followed.rawValue
        button.setTitle(Text.unfollow, for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.layer.borderColor = UIColor.gray.cgColor
    }
    
    // Toggle the followButton to "unfollowed" state
    private func toggleToUnfollowed(_ button: UIButton) {
        button.tag = FollowStatus.notFollowed.rawValue
        button.setTitle(Text.follow, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    // Changes display text of button upon tapping, and handle follow/unfollow logic
    @objc func followButtonTapped(_ sender: UIButton) {
        assert(currentUser != nil)
        
        // Locate the exact cell where the follow button is tapped
        let cell = sender.superview as! TopicFullListCell
        guard let index = self.topicListView.indexPath(for: cell)?.item else {
            fatalError("Cannot find corresponding cell for follow button")
        }
        
        // Handle follow/unfollow logic
        if let user = self.currentUser, let model = self.topicModel {
            if sender.tag == FollowStatus.notFollowed.rawValue {
                toggleToFollowed(sender)
                self.topics[index].addFollower(user)
            } else {
                toggleToUnfollowed(sender)
                self.topics[index].removeFollower(user)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.topicModel {
            let topicsList = self.topics
            self.selectedTopic = topicsList[indexPath.item]
            performSegue(withIdentifier: Identifiers.topicListToDetailPage, sender: self)
        }
    }
    
    func setModelManager(_ topicModel: TopicsModelManager<Topic>) {
        self.topicModel = topicModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let model = self.topicModel {
            self.topics = model.getTopics(0, 10)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initUser()
        self.topicListView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicViewController {
            dest.setTopic(self.selectedTopic)
            dest.currentUser = self.currentUser
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            //Code will work without the animation block.I am using animation block incase if you want to set any delay to it.
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }
    
    /**
     * Test functions
     */
    // TODO - change to actual user manager when user manager is available
    private func initUser() {
        self.currentUser = User(userId: "1", name: "James", password: "0909", photo: #imageLiteral(resourceName: "vegi-life"))
    }
    
}

