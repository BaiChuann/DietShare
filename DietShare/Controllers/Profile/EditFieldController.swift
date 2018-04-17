//
//  EditFieldController.swift
//  DietShare
//
//  Created by baichuan on 13/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class EditFieldController: UIViewController {
    var session: Int!
    var placeHolder: String!
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var textView: UITextView!
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        let saveButton = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(onSave))
        saveButton.tintColor = Constants.themeColor
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = saveButton
        if session == 0 {
            textView.isHidden = true
            textField.text = placeHolder
            textField.becomeFirstResponder()
        } else {
            textField.isHidden = true
            textView.layer.borderWidth = 0.5
            textView.layer.borderColor = Constants.lightTextColor.cgColor
            textView.text = placeHolder
            textView.becomeFirstResponder()
        }
    }
    @objc func onSave() {
        print("123123")
        let user = UserModelManager.shared.getUserFromID("1")!
        print(user.getName())
        switch session {
        case 0:
            if let txt = textField.text {
                if txt != "" {
                    user.setName(txt)
                }
            }
            break
        case 1:
            if let txt = textView.text {
                let profile = ProfileManager.shared.getProfile(user.getUserId())!
                profile.setDescription(txt)
            }
            break
        default:
            break
        }
        self.navigationController?.popViewController(animated: true)
    }
}
