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
    @IBOutlet weak private var commentCount: UIButton!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var restaurant: UILabel!
    @IBOutlet weak private var topics: UICollectionView!
    @IBOutlet weak var topicsLayout: UICollectionViewFlowLayout!
    private var topicsData: [String] = []
    var cellDelegate: PostCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "TopicCell", bundle: nil)
        topics.register(nibName, forCellWithReuseIdentifier: "topicCell")
        topicsLayout.estimatedItemSize = CGSize(width: 100, height: 12)
    }
    func setUserPhoto(_ photo: UIImage) {
        userPhoto.image = photo
        userPhoto.layer.cornerRadius = userPhoto.frame.height / 8
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
        commentCount.setTitle(count, for: .normal)
    }
    func setTime(_ time: String) {
        self.time.text = time
    }
    func setTopics(_ topics: [(String, String)]) {
        if topics.isEmpty {
            self.topics.frame.size = CGSize(width: 0, height: 0.0)
            return
        }
        topicsData = []
        for topic in topics {
            topicsData.append(topic.1)
        }
    }
    func setRestaurant(_ restaurant: String) {
        if restaurant == "" {
            self.restaurant.frame.size = CGSize(width: 0, height: 0.0)
            return
        }
        self.restaurant.text = restaurant
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCell  else {
            fatalError("The dequeued cell is not an instance of TopicCell.")
        }

        cell.topicLabel.text = " " + topicsData[indexPath.item] + " "
        cell.topicLabel.sizeToFit()
        cell.topicLabel.layer.cornerRadius = 4
        cell.topicLabel.clipsToBounds = true
        return cell
    }
    @IBAction func onCommentCountClicked(_ sender: Any) {
        self.cellDelegate.goToDetail(self)
    }
}
