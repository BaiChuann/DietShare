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
    
    @IBOutlet weak private var postsTable: UITableView!
    private var parentController: UIViewController!
    private var postManager = PostManager.shared
    private var textFieldController: TextFieldController!
    private var scrollDelegate: ScrollDelegate?
    override func viewDidLoad() {
        let cellNibName = UINib(nibName: "PostCell", bundle: nil)
        postsTable.register(cellNibName, forCellReuseIdentifier: "PostCell")
        postsTable.rowHeight = UITableViewAutomaticDimension
        postsTable.estimatedRowHeight = 600
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
        postsTable.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
        
    }
    func getLikePosts() {
        dataSource = postManager.getLikePosts()
        postsTable.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
        
    }
    func getTrendingPosts() {
        dataSource = postManager.getTrendingPosts()
        postsTable.reloadData()
    }
    func getTopicPosts(_ id: String) {
        dataSource = postManager.getTopicPosts(id)
        postsTable.reloadData()
    }
    func getRestaurantPosts(_ id: String) {
        dataSource = postManager.getRestaurantPosts(id)
        postsTable.reloadData()
    }
    func getUserPosts(_ id: String) {
        dataSource = postManager.getUserPosts(id)
        postsTable.reloadData()
    }
    func setParentController(_ controller: UIViewController) {
        parentController = controller
    }
    func getTable() -> UITableView {
        return postsTable
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell  else {
            fatalError("The dequeued cell is not an instance of PostCell.")
        }
        let post = dataSource[0]
        cell.setContent(userPhoto: UIImage(named: "profile-example")!, userName: "Bai Chuan", post)
        cell.setDelegate(self)
        return cell
    }
    
    func goToDetail(_ post: PostCell) {
        let controller = Bundle.main.loadNibNamed("PostDetail", owner: nil, options: nil)?.first as! PostDetailController
        controller.setPost(post)
//        parentController.addChildViewController(controller)
//        parentController.view.addSubview(controller.view)
//        controller.didMove(toParentViewController: self)
        parentController.tabBarController?.tabBar.isHidden = true
        parentController.navigationController?.navigationBar.isHidden = false
        print(parentController.view.frame.height)
        parentController.navigationController?.pushViewController(controller, animated: true)
        print("clicked")
        
    }
    func onCommentClicked() {
        print("clicked")
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
}

extension PostsTableController: CommentDelegate {
    func onComment(_ text: String) {
        print(text)
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
    }
}

extension PostsTableController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldController.view.removeFromSuperview()
        textFieldController.removeFromParentViewController()
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
