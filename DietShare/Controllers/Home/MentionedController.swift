//
//  MentionedController.swift
//  DietShare
//
//  Created by baichuan on 15/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class is the view controller of the mentioned page.
 * used when user tap the bell shape button in the top bar of home page. 
 */
class MentionedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    private var comments: [Comment] = []
    private var likes: [Like] = []
    private var commentPointer = 0
    private var likePointer = 0
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        let userId = "2"
        let posts = PostManager.shared.getUserPosts(userId)
        for post in posts {
            comments += PostManager.shared.getComments(post.getPostId())
            likes += PostManager.shared.getLikes(post.getPostId())
        }
        comments.sort(by: {$0.getTime() > $1.getTime()})
        likes.sort(by: {$0.getTime() > $1.getTime()})
        setNavigation()
    }
    func setNavigation() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + likes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mentionedCell", for: indexPath) as? MentionedCell  else {
            fatalError("The dequeued cell is not an instance of MentionedCell.")
        }
        if commentPointer >= comments.count {
            let like = likes[likePointer]
            let user = UserModelManager.shared.getUserFromID(like.getUserId())!
            let post = PostManager.shared.getPost(like.getPostId())!
            cell.setContent(user.getPhotoAsImage(), user.getName(), "", post.getPhoto(), like.getTime())
            likePointer += 1
        }
        else if (likePointer >= likes.count) || (comments[commentPointer].getTime() >= likes[likePointer].getTime()) {
            let comment = comments[commentPointer]
            let user = UserModelManager.shared.getUserFromID(comment.getUserId())!
            let post = PostManager.shared.getPost(comment.getParentId())!
            cell.setContent(user.getPhotoAsImage(), user.getName(), comment.getContent(), post.getPhoto(), comment.getTime())
            commentPointer += 1
        }
        else {
            let like = likes[likePointer]
            let user = UserModelManager.shared.getUserFromID(like.getUserId())!
            let post = PostManager.shared.getPost(like.getPostId())!
            cell.setContent(user.getPhotoAsImage(), user.getName(), "", post.getPhoto(), like.getTime())
            likePointer += 1
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = Bundle.main.loadNibNamed("PostDetail", owner: nil, options: nil)?.first as! PostDetailController
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
