//
//  DiscoveryViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import ScrollingStackContainer
import CoreLocation

class ShortListsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var topicModel = TopicsModelManager<Topic>()
    private var restaurantModel = RestaurantsModelManager<Restaurant>()
    private var currentTopic: Topic?
    private var currentRestaurant: Restaurant?
    var currentUser: User?
    
    private var postsTableController: PostsTableController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicList: UICollectionView!
    @IBOutlet weak var restaurantList: UICollectionView!
    @IBOutlet weak var postsArea: UIView!
//    @IBOutlet weak var postList: UITableView!
    
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
        let displayedTopicsList = self.topicModel.getDisplayedList(Constants.DiscoveryPage.numOfDisplayedTopics)
        if !displayedTopicsList.isEmpty {
            cell.setImage(displayedTopicsList[indexPath.item].getImage())
            cell.setName(displayedTopicsList[indexPath.item].getName())
        }
        return cell
    }
    
    private func getCellForRestaurant(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantShortListCell, for: indexPath as IndexPath) as! RestaurantShortListCell
        let displayedRestaurantsList = self.restaurantModel.getDisplayedList(Constants.DiscoveryPage.numOfDisplayedRestaurants)
        if !displayedRestaurantsList.isEmpty {
            cell.setImage(displayedRestaurantsList[indexPath.item].getImage())
            cell.setName(displayedRestaurantsList[indexPath.item].getName())
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topicList {
            let topicsList = self.topicModel.getFullTopicList()
            self.currentTopic = topicsList[indexPath.item]
            performSegue(withIdentifier: Identifiers.discoveryToTopicPage, sender: self)
        } else if collectionView == restaurantList {
            let restuarantsList = self.restaurantModel.getFullRestaurantList(Sorting.byRating)
            self.currentRestaurant = restuarantsList[indexPath.item]
            performSegue(withIdentifier: Identifiers.discoveryToRestaurantPage, sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: Constants.DiscoveryPage.longScrollViewHeight)
        scrollView.delegate = self
        
        PostManager.loadData()
        postsTableController = PostsTableController()
        postsTableController?.retrieveTrendingPosts()
        if let postsTable = postsTableController?.getTable() {
            postsTable.frame = postsArea.frame
            postsArea.removeFromSuperview()
            scrollView.addSubview(postsTable)
//            self.postList = postsTable
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
        if let dest = segue.destination as? RestaurantListViewController {
            dest.setModelManager(self.restaurantModel)
            dest.currentUser = self.currentUser
            
        }
        if let dest = segue.destination as? RestaurantViewController {
            dest.setRestaurant(self.currentRestaurant)
            dest.currentUser = self.currentUser
        }
    }
    
    
    /**
     * View-related functions
     */
    
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
    
}

extension ShortListsViewController: StackContainable {
    public static func create() -> ShortListsViewController {
        return UIStoryboard(name: "Discovery", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShortListsView") as! ShortListsViewController
    }
    
    public func preferredAppearanceInStack() -> ScrollingStackController.ItemAppearance {
        let _ = self.view
        return .scroll(self.scrollView, insets: UIEdgeInsetsMake(50, 0, 50, 0))
    }
}
