//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicViewController<T: ReadOnlyTopic> : UIViewController {
    
    private var topic = Topic()
    
//    @IBOutlet weak var topicName: UILabel!
//    @IBOutlet weak var topicDescription: UITextView!
//    @IBOutlet weak var topicImage: UIImageView!
    
    @IBOutlet weak var activeUsers: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == activeUsers {
            return Constants.TopicPage.numOfDisplayedUsers
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.activeUserListCell, for: indexPath as IndexPath) as! ActiveUserListCell
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
