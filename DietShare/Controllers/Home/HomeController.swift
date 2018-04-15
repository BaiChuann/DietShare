//
//  HomeController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    private var postsTableController: PostsTableController!
    @IBOutlet weak private var postsArea: UIView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    @IBOutlet weak private var segmentBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var postsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        //tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool){
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as! PostsTableController
        postsTableController.setParentController(self)
        postsTableController.setScrollDelegate(self)
        postsTableController.getFollowingPosts()
        self.addChildViewController(postsTableController)
        
//        postsTable = postsTableController.getTable()
        postsTableController.view.frame.size = postsArea.frame.size
        postsArea.addSubview(postsTableController.view)
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        let attr = NSDictionary(object: UIFont(name: "Verdana", size: 13.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.lightTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.themeColor], for: .selected)
        segmentBar.frame.origin.x = segmentedControl.frame.width / 8
        searchBar.backgroundImage = UIImage()
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = Constants.lightTextColor.cgColor
        searchBar.layer.cornerRadius = 10
    }
    @IBAction func onSegmentSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            UIView.animate(withDuration: 0.3) {
                self.segmentBar.frame.origin.x = self.segmentedControl.frame.width / 8
            }
            
            postsTableController.getFollowingPosts()
            searchBar.resignFirstResponder()
            //let indexPath = IndexPath(row: 0, section: 0)
            //postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
            
        case 1:
            UIView.animate(withDuration: 0.3) {
                self.segmentBar.frame.origin.x = self.segmentedControl.frame.width / 8 * 5
            }
            
            postsTableController.getLikePosts()
            searchBar.resignFirstResponder()
            //let indexPath = IndexPath(row: 0, section: 0)
            //postsTable.scrollToRow(at: indexPath, at: .top, animated: false)
            
        default:
            break
        }
    }
}

extension HomeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        postsTableController.search(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension HomeController: ScrollDelegate {
    func reachTop() {
    }
    func didScroll() {
        searchBar.resignFirstResponder()
    }
}
