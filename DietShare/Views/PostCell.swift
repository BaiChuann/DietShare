//
//  PostCell.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak private var userPhoto: UIImageView!
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var postImage: UIImageView!
    @IBOutlet weak private var caption: UILabel!
    @IBOutlet weak private var likeCount: UILabel!
    @IBOutlet weak private var commentCount: UILabel!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var topic: UILabel!
    @IBOutlet weak private var restaurant: UILabel!
    @IBOutlet weak private var topics: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "TopicCell", bundle:nil)
        topics.register(nibName, forCellWithReuseIdentifier: "topicCell")
    }
    func setUserPhoto(_ photo: UIImage) {
        userPhoto.image = photo
        userPhoto.layer.cornerRadius = userPhoto.frame.height / 2
        userPhoto.clipsToBounds = true
    }
    func setUserName(_ name: String) {
        userName.text = name
    }
    func setPostImage(_ photo: UIImage) {
        postImage.image = photo
    }
    func setCaption(_ caption: String) {
        self.caption.text = caption
    }
    func setLikeCount(_ count: String) {
        likeCount.text = count
    }
    func setCommentCount(_ count: String) {
        commentCount.text = count
    }
    func setTime(_ time: String) {
        self.time.text = time 
    }
    func setTopic(_ topic: String) {
        self.topic.text = topic
        if topic == "" {
            self.topic.frame.size = CGSize(width: 0, height: 0.0)
        }
    }
    func setRestaurant(_ restaurant: String) {
        self.restaurant.text = restaurant
        if restaurant == "" {
            self.restaurant.frame.size = CGSize(width: 0, height: 0.0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCell  else {
            fatalError("The dequeued cell is not an instance of TopicCell.")
        }
        cell.setLabel("TestTopic")
        return cell
    }
}
