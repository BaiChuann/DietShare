//
//  userListController.swift
//  DietShare
//
//  Created by baichuan on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class is the view controller of the userlist.
 * used when viewing the list of followers, followings and following topics.
 */
class UserListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var data: [String] = []
    @IBOutlet weak private var table: UITableView!
    var session = 0
    var userId: String!
    override func viewWillAppear(_ animated: Bool) {
        switch session {
        case 0:
            data = ProfileManager.shared.getProfile(userId)!.getFollowers()
            break
        case 1:
            data = ProfileManager.shared.getProfile(userId)!.getFollowings()
            break
        case 2:
            data = ProfileManager.shared.getProfile(userId)!.getTopics()
            break
        default:
            return
        }
        table.reloadData()
    }
    override func viewDidLoad() {
        switch session {
        case 0:
            data = ProfileManager.shared.getProfile(userId)!.getFollowers()
            break
        case 1:
            data = ProfileManager.shared.getProfile(userId)!.getFollowings()
            break
        case 2:
            data = ProfileManager.shared.getProfile(userId)!.getTopics()
            break
        default:
            return
        }
        setNavigation()
        table.tableFooterView = UIView()
    }
    func setNavigation() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUser" {
            if let destinationVC = segue.destination as? ProfileController {
                guard let item = table.indexPathForSelectedRow?.item else {
                    return
                }
                destinationVC.setUserId(data[item])
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if session != 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell  else {
                fatalError("The dequeued cell is not an instance of EditCell.")
            }
            guard let user = UserModelManager.shared.getUserFromID(data[indexPath.item]) else {
                return cell
            }
            cell.setUser(user)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "topicTableCell", for: indexPath as IndexPath) as? TopicTableCell else {
                fatalError("The dequeued cell is not an instance of TopicTableCell.")
            }
            guard let topic = TopicsModelManager.shared.getTopicFromID(data[indexPath.item]) else {
                return cell 
            }
            cell.setImage(UIImage(named: topic.getImagePath())!)
            cell.setName(topic.getName())
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("asdiuaiufywefuytwg")
        if session == 2 {
            let controller = AppStoryboard.discovery.instance.instantiateViewController(withIdentifier: "topic") as! TopicViewController
            controller.setTopic(TopicsModelManager.shared.getTopicFromID(data[indexPath.item])!)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
