//
//  PostsTableController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class is the viewController of a posts table.
 * it provide functions which allows the user interaction with post.
 * used as a child controller in home page, discover page, restaurant page, topic page, profile page.
 */
class PostsTableController: UIViewController {
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
        postsTable.allowsSelection = false
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
    func search(_ text: String) {
        filteredData = text.isEmpty ? dataSource :dataSource.filter { $0.getCaption().lowercased().contains(text.lowercased()) || (UserModelManager.shared.getUserFromID($0.getUserId())!.getName().lowercased().contains(text.lowercased())) }
        postsTable.reloadData()
    }
    func didScroll() {
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
    }
}

extension PostsTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell  else {
            fatalError("The dequeued cell is not an instance of PostCell.")
        }
        let post = filteredData[indexPath.item]
        guard let user = UserModelManager.shared.getUserFromID(post.getUserId()) else {
            return cell
        }
        cell.setContent(userPhoto: user.getPhotoAsImage(), userName: user.getName(), post)
        cell.setDelegate(self)
        return cell
    }
}

extension PostsTableController: PostCellDelegate {
    func goToDetail(_ post: String, _ session: Int) {
        let controller = Bundle.main.loadNibNamed("PostDetail", owner: nil, options: nil)?.first as! PostDetailController
        controller.setPost(post, session)
        parentController.navigationController?.pushViewController(controller, animated: true)
    }
    func goToUser(_ id: String) {
        let controller = AppStoryboard.profile.instance.instantiateViewController(withIdentifier: "profile") as! ProfileController
        controller.setUserId(id)
        if id == UserModelManager.shared.getCurrentUser()!.getUserId() {
            tabBarController?.selectedIndex = 4
        } else {
            parentController.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func goToRestaurant(_ id: String) {
        let controller = AppStoryboard.discovery.instance.instantiateViewController(withIdentifier: "restaurant") as! RestaurantViewController
        controller.setRestaurant(RestaurantsModelManager.shared.getRestaurantFromID(id))
        parentController.navigationController?.pushViewController(controller, animated: true)
    }
    func goToTopic(_ id: String) {
        let controller = AppStoryboard.discovery.instance.instantiateViewController(withIdentifier: "topic") as! TopicViewController
        controller.setTopic(TopicsModelManager.shared.getTopicFromID(id))
        parentController.navigationController?.pushViewController(controller, animated: true)
    }
    func updateCell() {
        postsTable.reloadData()
    }
    func onCommentClicked(_ postId: String) {
        commentingPost = postId
        let textHeight = CGFloat(40)
        let width = parentController.view.frame.width
        let height = parentController.view.frame.height
        var tabHeight = CGFloat(0)
        if let tabBar = parentController.tabBarController?.tabBar {
            if !tabBar.isHidden {
                tabHeight = tabBar.frame.height
            }
        }
        parentController.addChildViewController(textFieldController)
        textFieldController.setTabHeight(tabHeight)
        textFieldController.setDelegate(self)
        textFieldController.view.frame = CGRect(x: 0, y: height - tabHeight - textHeight, width: width, height: textHeight)
        parentController.view.addSubview(textFieldController.view)
        textFieldController.startEditing()
    }
}

extension PostsTableController: CommentDelegate {
    func onComment(_ text: String) {
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
