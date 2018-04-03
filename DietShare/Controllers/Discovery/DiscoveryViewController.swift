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
    private var currentTopic: Topic?
    var currentUser: User?
    
    @IBOutlet weak var topicList: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicList {
            return Constants.DiscoveryPage.numOfDisplayedTopics
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicShortListCell, for: indexPath as IndexPath) as! TopicShortListCell
        let displayedTopicsList = self.topicModel.getDisplayedList()
        if !displayedTopicsList.isEmpty {
            cell.setImage(displayedTopicsList[indexPath.item].getImage())
            cell.setName(displayedTopicsList[indexPath.item].getName())
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

        // Do any additional setup after loading the view.
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
