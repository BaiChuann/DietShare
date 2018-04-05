//
//  DiscoveryViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var topicModel = TopicsModelManager<Topic>()
    private var restaurantModel = RestaurantsModelManager<Restaurant>()
    private var currentTopic: Topic?
    private var currentRestaurant: Restaurant?
    var currentUser: User?
    
    private var postsTableController: PostsTableController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicList: UICollectionView!
    @IBOutlet weak var restaurantList: UICollectionView!
//    @IBOutlet weak var postsArea: UIView!
    @IBOutlet weak var postList: UITableView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicList {
            return Constants.DiscoveryPage.numOfDisplayedTopics
        }
        if collectionView == restaurantList {
            return Constants.DiscoveryPage.numOfDisplayedRestaurants
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topicList {
            return getCellForTopic(collectionView, indexPath)
        }
        if collectionView == restaurantList {
            return getCellForRestaurant(collectionView, indexPath)
        }
        
        return UICollectionViewCell()
    }
    
    private func getCellForTopic(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicShortListCell, for: indexPath as IndexPath) as! TopicShortListCell
        let displayedTopicsList = self.topicModel.getDisplayedList()
        if !displayedTopicsList.isEmpty {
            cell.setImage(displayedTopicsList[indexPath.item].getImage())
            cell.setName(displayedTopicsList[indexPath.item].getName())
        }
        return cell
    }
    
    private func getCellForRestaurant(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantShortListCell, for: indexPath as IndexPath) as! RestaurantShortListCell
        let displayedRestaurantsList = self.restaurantModel.getDisplayedList()
        if !displayedRestaurantsList.isEmpty {
            cell.setImage(displayedRestaurantsList[indexPath.item].getImage())
            cell.setName(displayedRestaurantsList[indexPath.item].getName())
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topicsList = self.topicModel.getFullTopicList()
        self.currentTopic = topicsList[indexPath.item]
        performSegue(withIdentifier: Identifiers.discoveryToTopicPage, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
        PostManager.loadData()
        postsTableController = PostsTableController()
        postsTableController?.retrieveTrendingPosts()
        if let postsTable = postsTableController?.getTable() {
//            postsTable.frame = postsArea.frame
//            postsArea.removeFromSuperview()
//            scrollView.addSubview(postsTable)
            self.postList = postsTable
            print("posts table added")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO - Add User Manager here and for all related view controllers

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicListViewController {
            dest.setModelManager(self.topicModel)
            dest.currentUser = self.currentUser
            
        }
        if let dest = segue.destination as? TopicViewController {
            dest.setTopic(self.currentTopic)
            dest.currentUser = self.currentUser
        }
    }
}
