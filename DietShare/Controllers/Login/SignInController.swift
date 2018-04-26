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
import SwiftMessages

enum SignInInputType: Int {
    case email = 0, password
}

class SignInController: UIViewController {

    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var inputLabelGroup: [UILabel]!
    @IBOutlet private var facebookLoginButton: UIButton!
    @IBOutlet private var wechatLoginButton: UIButton!

    private let testEmail = "dietshare@gmail.com"
    private let testPassword = "12345678"

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: Constants.themeColor)

        inputGroup.forEach {
            switch $0.tag {
            case SignInInputType.email.rawValue:
                $0.text = testEmail
            case SignInInputType.password.rawValue:
                $0.text = testPassword
            default:
                return
            }
        }
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

        if email == testEmail, password == testPassword {
            signIn()
        } else {
            let warningView = MessageView.viewFromNib(layout: .cardView)
            warningView.configureTheme(.warning)
            warningView.configureDropShadow()
            warningView.configureContent(title: "Failed to sign in", body: "Email or password is incorrect.")
            warningView.button?.isHidden = true
            warningView.configureBackgroundView(sideMargin: 12)
            SwiftMessages.show(view: warningView)
        }
    }

    private func setUpInputDelegate() {
        inputGroup.forEach { $0.delegate = self }
    }

    private func signIn() {
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
