//
//  PostDetailController.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostDetailController: UIViewController {
    private weak var post: PostCell!
    
    @IBOutlet weak private var segmentBar: UIView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    @IBOutlet weak private var commentsTable: UITableView!
    private var textFieldController: TextFieldController!
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
        let cellNibName2 = UINib(nibName: "LikeCell", bundle: nil)
        commentsTable.register(cellNibName2, forCellReuseIdentifier: "likeCell")
        commentsTable.rowHeight = UITableViewAutomaticDimension
        commentsTable.estimatedRowHeight = 100
        setSegmentControl()
        setTextField()
        
    }
    func setSegmentControl() {
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        let attr = NSDictionary(object: UIFont(name: "Verdana", size: 13.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.lightTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.themeColor], for: .selected)
        segmentBar.frame.origin.x = segmentedControl.frame.width / 8
    }
    func setTextField() {
        textFieldController = Bundle.main.loadNibNamed("TextField", owner: nil, options: nil)?.first as! TextFieldController
        let textHeight = CGFloat(40)
        let width = view.frame.width
        let height = view.frame.height
        var tabHeight = CGFloat(0)
        if let tabBar = tabBarController?.tabBar {
            if !tabBar.isHidden {
                tabHeight = tabBar.frame.height
                print(tabBar.frame.origin)
            }
        }
        self.addChildViewController(textFieldController)
        textFieldController.setTabHeight(tabHeight)
        textFieldController.setDelegate(self)
        textFieldController.view.frame = CGRect(x: 0, y: height - tabHeight - textHeight, width: width, height: textHeight)
        view.addSubview(textFieldController.view)
    }
    func setPost(_ post: PostCell) {
        self.post = post
    }
    @IBAction func onSegmentSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell  else {
                fatalError("The dequeued cell is not an instance of PostCell.")
            }
            let comment = Comment(userId: "1", parentId: "1", content: "this is an example of comment", time: Date())
            let user = User(userId: "1", name: "BaiChuan", password: "12323", photo: UIImage(named: "profile-example")!)
            cell.setComment(user: user, comment: comment)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as? LikeCell  else {
                fatalError("The dequeued cell is not an instance of PostCell.")
            }
            
            let user = User(userId: "1", name: "BaiChuan", password: "12323", photo: UIImage(named: "profile-example")!)
            cell.setUser(user)
            cell.selectionStyle = .none
            return cell
        }
        
    }
}

extension PostDetailController: CommentDelegate {
    func onComment(_ text: String) {
        print(text)
    }
}

extension PostDetailController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldController.reset()
    }
}

