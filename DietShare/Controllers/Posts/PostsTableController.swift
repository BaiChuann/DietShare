//
//  PostsTableController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostsTableController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostCellDelegate {
    private var dataSource: [Post] = []
    private var filteredData: [Post] = []
    @IBOutlet weak private var postsTable: UITableView!
    private var parentController: UIViewController!
    private var postManager = PostManager.shared
    private var textFieldController: TextFieldController!
    private var scrollDelegate: ScrollDelegate?
    private var commentingPost: String?
    override func viewDidLoad() {
        let cellNibName = UINib(nibName: "PostCell", bundle: nil)
        postsTable.register(cellNibName, forCellReuseIdentifier: "PostCell")
        postsTable.rowHeight = UITableViewAutomaticDimension
        postsTable.estimatedRowHeight = 600
        postsTable.tableFooterView = UIView()
        textFieldController = Bundle.main.loadNibNamed("TextField", owner: nil, options: nil)?.first as! TextFieldController
        postsTable.allowsSelection = false;
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
    }
    func setScrollDelegate(_ delegate: ScrollDelegate) {
        scrollDelegate = delegate
    }
    func getFollowingPosts() {
        dataSource = postManager.getFollowingPosts()
        filteredData = dataSource
        postsTable.reloadData()
        if !filteredData.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    func getLikePosts() {
        dataSource = postManager.getLikePosts()
        filteredData = dataSource
        postsTable.reloadData()
        if !filteredData.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
    }
    func getTrendingPosts() {
        dataSource = postManager.getTrendingPosts()
        filteredData = dataSource
        postsTable.reloadData()
    }
    func getTopicPosts(_ id: String) {
        dataSource = postManager.getTopicPosts(id)
        filteredData = dataSource
        postsTable.reloadData()
    }
    func getRestaurantPosts(_ id: String) {
        dataSource = postManager.getRestaurantPosts(id)
        filteredData = dataSource
        postsTable.reloadData()
    }
    func getUserPosts(_ id: String) {
        dataSource = postManager.getUserPosts(id)
        filteredData = dataSource
        postsTable.reloadData()
    }
    func setParentController(_ controller: UIViewController) {
        parentController = controller
    }
    func getTable() -> UITableView {
        return postsTable
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell  else {
            fatalError("The dequeued cell is not an instance of PostCell.")
        }
        let post = filteredData[0]
        cell.setContent(userPhoto: UIImage(named: "profile-example")!, userName: "Bai Chuan", post)
        cell.setDelegate(self)
        return cell
    }
    
    func goToDetail(_ post: PostCell) {
        let controller = Bundle.main.loadNibNamed("PostDetail", owner: nil, options: nil)?.first as! PostDetailController
        print(parentController.view.frame.height)
        controller.setPost(post.getPost().getPostId())
        parentController.navigationController?.pushViewController(controller, animated: true)
        print("clicked")
    }
    func goToUser(_ id: String) {
        let controller = AppStoryboard.profile.instance.instantiateViewController(withIdentifier: "profile") as! ProfileController
        controller.setUserId(id)
        print(parentController.view.frame.height)
        parentController.navigationController?.pushViewController(controller, animated: true)
        print("clicked")
    }
    func onCommentClicked(_ postId: String) {
        print("clicked")
        commentingPost = postId 
        let textHeight = CGFloat(40)
        let width = parentController.view.frame.width
        let height = parentController.view.frame.height
        var tabHeight = CGFloat(0)
        if let tabBar = parentController.tabBarController?.tabBar {
            if !tabBar.isHidden {
                tabHeight = tabBar.frame.height
                print(tabBar.frame.origin)
            }
        }
        parentController.addChildViewController(textFieldController)
        textFieldController.setTabHeight(tabHeight)
        textFieldController.setDelegate(self)
        textFieldController.view.frame = CGRect(x: 0, y: height - tabHeight - textHeight, width: width, height: textHeight)
        parentController.view.addSubview(textFieldController.view)
        textFieldController.startEditing()
    }
    func search(_ text: String) {
        filteredData = text.isEmpty ? dataSource :dataSource.filter { $0.getCaption().contains(text) }
        postsTable.reloadData()
    }
}

extension PostsTableController: CommentDelegate {
    func onComment(_ text: String) {
        print(text)
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
        postManager.postComment(Comment(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), parentId: commentingPost!, content: text, time: Date()))
        postsTable.reloadData()
    }
}

extension PostsTableController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
        if scrollDelegate != nil {
            scrollDelegate?.didScroll()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDelegate != nil {
            let yOffset = scrollView.contentOffset.y
            if yOffset <= 0 {
                scrollDelegate?.reachTop()
            }
        }
    }
}
