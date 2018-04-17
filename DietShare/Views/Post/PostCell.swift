//
//  PostCell.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak private var userPhoto: UIButton!
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var postImage: UIImageView!
    @IBOutlet weak private var caption: UILabel!
    @IBOutlet weak private var likeCount: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak private var commentCount: UIButton!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var restaurant: UIButton!
    @IBOutlet weak private var topics: UICollectionView!
    @IBOutlet weak var topicsLayout: UICollectionViewFlowLayout!
    private var post: Post!
    private var topicsData: [String] = []
    var cellDelegate: PostCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "TopicCell", bundle: nil)
        topics.register(nibName, forCellWithReuseIdentifier: "topicCell")
        topicsLayout.estimatedItemSize = CGSize(width: 100, height: 12)
    }
    func setUserPhoto(_ photo: UIImage) {
        userPhoto.setImage(photo, for: .normal)
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
        likeCount.setTitle(count, for: .normal)
    }
    func setCommentCount(_ count: String) {
        commentCount.setTitle(count, for: .normal)
    }
    func setTime(_ time: String) {
        self.time.text = time
    }
    func setTopics(_ topics: [String]?) {
        guard let tps = topics else {
            self.topics.frame.size = CGSize(width: 0, height: 0.0)
            return
        }
        topicsData = []
        for topic in tps {
            topicsData.append(topic)
        }
    }
    func setRestaurant(_ restaurant: String?) {
        guard let res = restaurant else {
            self.restaurant.frame.size = CGSize(width: 0, height: 0.0)
            return
        }
        self.restaurant.setTitle(res, for: .normal)
    }
    func setContent(userPhoto: UIImage, userName: String, _ post: Post) {
        self.post = post
        setUserPhoto(userPhoto)
        setUserName(userName)
        setPostImage(post.getPhoto())
        setCaption(post.getCaption())
        setLikeCount(String(post.getLikesCount()))
        setCommentCount(String(post.getCommentsCount()))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        setTime(dateFormatter.string(from: post.getTime()))
        setTopics(post.getTopics())
        setRestaurant(post.getRestaurant())
    }
    func setDelegate(_ cellDelegate: PostCellDelegate) {
        self.cellDelegate = cellDelegate
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCell  else {
            fatalError("The dequeued cell is not an instance of TopicCell.")
        }

        cell.topicLabel.text = "#\(topicsData[indexPath.item])"
        //cell.topicLabel.sizeToFit()
        cell.layer.cornerRadius = 3
        cell.topicLabel.clipsToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    @IBAction func onUserClicked(_ sender: Any) {
        self.cellDelegate?.goToUser("2")
    }
    @IBAction func onCommentCountClicked(_ sender: Any) {
        self.cellDelegate?.goToDetail(post.getPostId(), 0)
    }
    @IBAction func onCommentClicked(_ sender: Any) {
        self.cellDelegate?.onCommentClicked(post.getPostId())
    }
    @IBAction func onLikeCountClicked(_ sender: Any) {
        self.cellDelegate?.goToDetail(post.getPostId(), 1)
    }
    @IBAction func onLikeClicked(_ sender: Any) {
        if likeButton.currentTitle == "unlike" {
            likeButton.setImage(UIImage(named: "heart")!, for: .normal)
            likeButton.setTitle("liked", for: .normal)
            PostManager.shared.postLike(Like(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), postId: post.getPostId(), time: Date()))
            self.cellDelegate?.updateCell()
        } else {
            likeButton.setImage(UIImage(named: "like")!, for: .normal)
            likeButton.setTitle("unlike", for: .normal)
            PostManager.shared.deleteLike(Like(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), postId: post.getPostId(), time: Date()))
            self.cellDelegate?.updateCell()
        }
    }
    func getPost() -> Post{
        return post
    }
}
