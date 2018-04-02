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
    
    @IBOutlet weak var topicList: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicList {
            return Constants.defaultListDisplayCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicFullListCell, for: indexPath as IndexPath) as! TopicFullListCell
        if let model = self.topicModel {
            let topicList = model.getFullTopicList()
            cell.setImage(topicList[indexPath.item].getImage())
            cell.setName(topicList[indexPath.item].getName())
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.topicModel {
            let topicsList = model.getFullTopicList()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicViewController {
            dest.setTopic(self.selectedTopic)
            print("setTopic is \(selectedTopic?.getID())")
        }
    }
    
}

