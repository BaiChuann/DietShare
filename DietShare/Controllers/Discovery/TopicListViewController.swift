//
//  TopicListController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation
import UIKit

class TopicListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var topicModel = TopicsModelManager.shared
    private var selectedTopic: Topic?
    private var buttonTopicDict = [UIButton: TopicFullListCell]()
    
    var currentUser = UserModelManager.shared.getCurrentUser()
    
    @IBOutlet weak var topicListView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicListView {
            return topicModel.getNumOfTopics()
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicFullListCell, for: indexPath as IndexPath) as! TopicFullListCell
        
        let topicList = topicModel.getAllTopics()
        cell.setImage(topicList[indexPath.item].getImageAsUIImage())
        cell.setName(topicList[indexPath.item].getName())
        cell.setDescription(topicList[indexPath.item].getDescription())
        cell.initFollowButtonView()
        addTapHandler(cell, topicList, indexPath)
        
        return cell
    }

    // Add handling of tapping on follow button
    private func addTapHandler(_ cell: TopicFullListCell, _ topicList: [ReadOnlyTopic], _ indexPath: IndexPath) {
        cell.initFollowButtonView()
        buttonTopicDict[cell.followButton] = cell
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
        button.backgroundColor = Constants.themeColor
    }
    
    // Toggle the followButton to "unfollowed" state
    private func toggleToUnfollowed(_ button: UIButton) {
        button.tag = FollowStatus.notFollowed.rawValue
        button.setTitle(Text.follow, for: .normal)
        button.backgroundColor = Constants.themeColor
    }
    
    // Changes display text of button upon tapping, and handle follow/unfollow logic
    @objc func followButtonTapped(_ sender: UIButton) {
        assert(currentUser != nil)
        
        // Locate the exact cell where the follow button is tapped
        guard let cell = buttonTopicDict[sender],
            let index = self.topicListView.indexPath(for: cell)?.item else {
            fatalError("Cannot find corresponding cell for follow button")
        }
        
        // Handle follow/unfollow logic
        if let user = self.currentUser {
            if sender.tag == FollowStatus.notFollowed.rawValue {
                toggleToFollowed(sender)
                let topic = Topic(topicModel.getAllTopics()[index])
                topicModel.addNewFollower(user, topic)
            } else {
                toggleToUnfollowed(sender)
                topicModel.removeFollower(user, Topic(topicModel.getAllTopics()[index]))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let topicsList = topicModel.getAllTopics()
        self.selectedTopic = Topic(topicsList[indexPath.item])
        performSegue(withIdentifier: Identifiers.topicListToDetailPage, sender: self)
    
    }
    
    func setModelManager(_ topicModel: TopicsModelManager) {
        self.topicModel = topicModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = Text.topicListTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topicListView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicViewController {
            dest.setTopic(self.selectedTopic)
            dest.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 0 {
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
    
}
