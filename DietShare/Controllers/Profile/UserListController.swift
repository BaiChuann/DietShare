//
//  userListController.swift
//  DietShare
//
//  Created by baichuan on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class UserListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var users: [User] = []
    private var topics: [Topic] = []
    @IBOutlet weak private var table: UITableView!
    var session = 0
    override func viewDidLoad() {
        users.append(User(userId: "1", name: "Bai Chuan", password: "123", photo: "profile-example"))
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUser" {
            if let destinationVC = segue.destination as? ProfileController {
//                guard let item = table.indexPathForSelectedRow?.item else {
//                    return
//                }
                destinationVC.setUserId("2")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if session == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell  else {
                fatalError("The dequeued cell is not an instance of EditCell.")
            }
            let user = users[0]
            cell.setUser(user)
            cell.selectionStyle = .none
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "topicTableCell", for: indexPath as IndexPath) as? TopicTableCell else {
                fatalError("The dequeued cell is not an instance of TopicTableCell.")
            }
            cell.setImage(UIImage(named:"food-result-3")!)
            cell.setName("Eat Healthy")
            cell.selectionStyle = .none
            return cell
        }
    }
}
