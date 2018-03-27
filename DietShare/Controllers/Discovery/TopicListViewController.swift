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
    
    private var topicModel = TopicsModelManager<Topic>()
    
    @IBOutlet weak var topicList: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicList {
            return Constants.defaultListDisplayCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicShortListCell, for: indexPath as IndexPath) as! TopicShortListCell
        let topicList = self.topicModel.getFullTopicList()
        if !topicList.isEmpty {
            cell.setImage(topicList[indexPath.item].getImage())
            cell.setName(topicList[indexPath.item].getName())
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
    
}

