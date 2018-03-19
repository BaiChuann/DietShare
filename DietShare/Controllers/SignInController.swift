//
//  SignInController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.cs3217. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class SignInController: UIViewController {

    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var inputLabelGroup: [UILabel]!
    @IBOutlet private var facebookLoginButton: UIButton!
    @IBOutlet private var wechatLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInputDelegate()
        addInputBorder(for: inputGroup)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setUpInputDelegate() {
        inputGroup.forEach { $0.delegate = self }
    }
}

extension SignInController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let label = inputLabelGroup.first(where: { $0.tag == textField.tag }) {
            label.textColor = UIColor.black
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let label = inputLabelGroup.first(where: { $0.tag == textField.tag }) {
            label.textColor = hexToUIColor(hex: "#A9A9A9")
        }
    }
}

extension SignInController {
    @IBAction func facebookLoginClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            }
        }
    }
}
