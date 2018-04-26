//
//  PostDetailController.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostDetailController: UIViewController {
    private var postId: String!
    
    @IBOutlet weak private var segmentBar: UIView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    @IBOutlet weak private var commentsTable: UITableView!
    @IBOutlet weak var textFieldContainer: UIView!
    private var textFieldController: TextFieldController!
    private var comments: [Comment] = []
    private var likes: [Like] = []
    override func viewWillAppear(_ animated: Bool) {
       // print(textFieldContainer.frame.origin.y)
        self.navigationController?.navigationBar.isHidden = false
        //self.tabBarController?.tabBar.isHidden = true
        comments = PostManager.shared.getComments(postId)
        commentsTable.reloadData()
        likes = PostManager.shared.getLikes(postId)
    }
    override func viewDidAppear(_ animated: Bool) {
        setTextField()
    }
    override func viewDidLoad() {
//        let postCell = Bundle.main.loadNibNamed("PostCell", owner: nil, options: nil)?.first as! PostCell
        
        //postCell.translatesAutoresizingMaskIntoConstraints = false
        //postArea.frame.size = CGSize(width: postArea.frame.width, height: UITableViewAutomaticDimension)
        //postArea.addSubview(postCell)
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        let cellNibName = UINib(nibName: "CommentCell", bundle: nil)
        commentsTable.register(cellNibName, forCellReuseIdentifier: "commentCell")
        let cellNibName2 = UINib(nibName: "UserCell", bundle: nil)
        commentsTable.register(cellNibName2, forCellReuseIdentifier: "userCell")
        commentsTable.rowHeight = UITableViewAutomaticDimension
        commentsTable.estimatedRowHeight = 100
        commentsTable.tableFooterView = UIView()
        //setTextField()
        setSegmentControl()
//        view.frame.size = CGSize(width: 375, height: 667)
        textFieldController = Bundle.main.loadNibNamed("TextField", owner: nil, options: nil)?.first as! TextFieldController
        let width = view.frame.width
        let textHeight = textFieldContainer.frame.height
        print(textFieldContainer.frame.origin.y)
        //textFieldController.view.frame.size = CGSize(width: width, height: textHeight)
        textFieldController.view.frame = CGRect(x: 0, y: 0, width: width, height: textHeight)
        textFieldContainer.addSubview(textFieldController.view)
        
    }
    
    func setSegmentControl() {
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        let attr = NSDictionary(object: UIFont(name: "Verdana", size: 13.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.lightTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.themeColor], for: .selected)
        segmentBar.frame.origin.x = segmentedControl.frame.width / 8
    }
    func setTextField() {
        textFieldController = Bundle.main.loadNibNamed("TextField", owner: nil, options: nil)?.first as! TextFieldController
        let width = view.frame.width
        let textHeight = textFieldContainer.frame.height
        self.addChildViewController(textFieldController)
        textFieldController.setDelegate(self)
        print(textFieldContainer.frame.origin.y)
        //textFieldController.view.frame.size = CGSize(width: width, height: textHeight)
        textFieldController.view.frame = CGRect(x: 0, y: textFieldContainer.frame.origin.y, width: width, height: textHeight)
        view.addSubview(textFieldController.view)
    }
    func setPost(_ postId: String, _ session: Int) {
        self.postId = postId
        self.segmentedControl.selectedSegmentIndex = session
        self.segmentBar.frame.origin.x = self.segmentedControl.frame.width / 8 * CGFloat(1 + session * 4)
    }
    @IBAction func onSegmentSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.3) {
                self.segmentBar.frame.origin.x = self.segmentedControl.frame.width / 8
            }
            commentsTable.reloadData()
            commentsTable.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        case 1:
            UIView.animate(withDuration: 0.3) {
                self.segmentBar.frame.origin.x = self.segmentedControl.frame.width / 8 * 5
            }
            commentsTable.reloadData()
            commentsTable.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            
        default:
            break
        }
    }
}

extension PostDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return comments.count
        } else {
            return likes.count 
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell  else {
                fatalError("The dequeued cell is not an instance of PostCell.")
            }
            let comment = comments[indexPath.item]
            guard let user = UserModelManager.shared.getUserFromID(comment.getUserId()) else {
                return cell
            }
            cell.setComment(user: user, comment: comment)
            cell.setDelegate(self)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell  else {
                fatalError("The dequeued cell is not an instance of PostCell.")
            }
            let like = likes[indexPath.item]
            guard let user = UserModelManager.shared.getUserFromID(like.getUserId()) else {
                return cell
            }
            cell.setUser(user)
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let userName = UserModelManager.shared.getUserFromID(comments[indexPath.item].getUserId())?.getName() else {
                return
            }
            textFieldController.setText("reply to " + userName + " : ")
        }
    }
}
extension PostDetailController: PostCellDelegate {
    func goToTopic(_ id: String) {
    }
    func goToRestaurant(_ id: String) {
    }
    
    func goToDetail(_ post: String, _ session: Int) {
    }
    
    func goToUser(_ id: String) {
        let controller = AppStoryboard.profile.instance.instantiateViewController(withIdentifier: "profile") as! ProfileController
        controller.setUserId(id)
        self.navigationController?.pushViewController(controller, animated: true)
        print("clicked")
    }
    
    func onCommentClicked(_ postId: String) {
    }
    
    func updateCell() {
    }
    
}
extension PostDetailController: CommentDelegate {
    func onComment(_ text: String) {
        print(text)
        PostManager.shared.postComment(Comment(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), parentId: postId, content: text, time: Date()))
        comments = PostManager.shared.getComments(postId)
        commentsTable.reloadData()
    }
}

extension PostDetailController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldController.reset()
    }
}
