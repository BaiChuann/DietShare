//
//  ProfileEditor.swift
//  DietShare
//
//  Created by baichuan on 13/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class ProfileEditor: UIViewController {
    
    @IBOutlet weak private var userPhoto: UIButton!
    @IBOutlet weak private var table: UITableView!
    private var attributes: [String] = []
    var photo: UIImage!
    var data: [String]!
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
        userPhoto.setImage(photo, for: .normal)
        userPhoto.layer.cornerRadius = userPhoto.frame.height / 8
        userPhoto.clipsToBounds = true
        attributes = ["User Name", "Description", "Password"]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditField" {
            if let destinationVC = segue.destination as? EditFieldController {
                guard let session = table.indexPathForSelectedRow?.item else {
                    return
                }
                destinationVC.session = session
                destinationVC.placeHolder = data[session]
            }
        }
    }
}

extension ProfileEditor: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as? EditCell  else {
            fatalError("The dequeued cell is not an instance of EditCell.")
        }
        let name = attributes[indexPath.item]
        cell.setAttribute(name)
        return cell
    }
    
    
}
