//
//  SignInController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 nus.cs3217. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

enum SignInInputType: Int {
    case email = 0, password
}

class SignInController: UIViewController {

    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var inputLabelGroup: [UILabel]!
    @IBOutlet private var facebookLoginButton: UIButton!
    @IBOutlet private var wechatLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: Constants.themeColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onSignInButtonPressed(_ sender: Any) {
        var emailInput: String?
        var passwordInput: String?

        inputGroup.forEach {
            switch $0.tag {
            case SignInInputType.email.rawValue:
                emailInput = $0.text
            case SignInInputType.password.rawValue:
                passwordInput = $0.text
            default:
                return
            }
        }

        guard let email = emailInput, let password = passwordInput else {
            print("Invalid email or password")
            return
        }

        //TODO: Check for match between email and password here, and get the user from DataSource

        signIn()
    }

    func setUpInputDelegate() {
        inputGroup.forEach { $0.delegate = self }
    }

    //TODO: should pass with a user object
    func signIn() {
        if let tabPageVC = storyboard?.instantiateViewController(withIdentifier: "TabPage") {
            show(tabPageVC, sender: self)
        }
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
                self.signIn()
                print("Logged in with facebook!")
            }
        }
    }
}
