//
//  SignUpController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.cs3217. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {

    @IBOutlet var inputGroup: [UITextField]!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInputDelegate()
        setUpInputBorder(for: inputGroup)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpInputDelegate() {
        inputGroup.forEach { $0.delegate = self }
    }

    @IBAction func onSignInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
}
