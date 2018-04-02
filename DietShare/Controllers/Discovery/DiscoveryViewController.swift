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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicListViewController {
            dest.setModelManager(self.topicModel)
        }
    }
}
