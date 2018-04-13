//
//  ProfileController.swift
//  DietShare
//
//  Created by baichuan on 12/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var userName: UILabel!
    
    @IBOutlet weak private var descrip: UILabel!
    @IBOutlet weak private var userPhoto: UIImageView!
    @IBOutlet weak private var followerCount: UIButton!
    @IBOutlet weak private var followingCount: UIButton!
    @IBOutlet weak private var topicCount: UIButton!
    @IBOutlet weak private var followButton: UIButton!
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak private var postsArea: UIView!
    private var userId = ""
    private var postsTableController: PostsTableController!
    private var tableView: UITableView!
    private var tab = true
    override func viewWillAppear(_ animated: Bool) {
        //tabBarController?.tabBar.isHidden = false
        if tab {
            print("yes")
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = true
        }
        //scrollView.frame.size = view.frame.size
        //view.frame.size = CGSize(width: 375, height: 667)
    }
    override func viewDidLoad() {
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as! PostsTableController
        postsTableController.setParentController(self)
        postsTableController.getFollowingPosts()
        //SCROLL VIEW IMPLEMENTATION
        postsTableController.setScrollDelegate(self)
        tableView = postsTableController.getTable()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        //===============================
        self.addChildViewController(postsTableController)
        postsTableController.view.frame.size = postsArea.frame.size
        postsArea.addSubview(postsTableController.view)
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        setUser("1")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditor" {
            if let destinationVC = segue.destination as? ProfileEditor {
                destinationVC.photo = UIImage(named: "profile-example")!
                destinationVC.data = ["Bai Chuan", "eat less eat healthy", "1234"]
            }
        }
    }
    func setTabShow(_ tab: Bool) {
        self.tab = tab
    }
    func setUser(_ id: String) {
        userId = id
        userName.text = "Bai Chuan"
        descrip.text = "eat less eat healthy"
        userPhoto.image = UIImage(named: "profile-example")!
        followerCount.setTitle("378", for: .normal)
        followingCount.setTitle("201", for: .normal)
        topicCount.setTitle("5", for: .normal)
        postsTableController.getUserPosts("1")
        
    }
    @IBAction func onFollowClicked(_ sender: Any) {
    }
    @IBAction func onEditClick(_ sender: Any) {
    }
    @IBAction func onFollowerClicked(_ sender: Any) {
    }
    @IBAction func onFollowingClicked(_ sender: Any) {
    }
    @IBAction func onTopicClicked(_ sender: Any) {
    }
}
// SCROLL VIEW IMPLEMENTATION
extension ProfileController: UIScrollViewDelegate, ScrollDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0)
        {
            //change the following line accordingly. the "postsArea.frame.height means the table height in my component screen"
            if yOffset >= scrollView.contentSize.height - postsArea.frame.height {
                scrollView.isScrollEnabled = false
                tableView.isScrollEnabled = true
            }
            
        }
    }
    func reachTop() {
        scrollView.isScrollEnabled = true
        tableView.isScrollEnabled = false
    }
}
//================
