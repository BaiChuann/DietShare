//
//  MentionedController.swift
//  DietShare
//
//  Created by baichuan on 15/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class MentionedController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mentionedCell", for: indexPath) as? MentionedCell  else {
            fatalError("The dequeued cell is not an instance of MentionedCell.")
        }
        cell.setContent(UIImage(named: "profile-example")!, "Baichuan", "", UIImage(named: "post-example")!, Date())
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = Bundle.main.loadNibNamed("PostDetail", owner: nil, options: nil)?.first as! PostDetailController
        navigationController?.pushViewController(controller, animated: true)
        print("clicked")
    }
    
}
