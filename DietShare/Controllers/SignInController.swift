//
//  SignInController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.cs3217. All rights reserved.
//

import UIKit

class SignInController: UIViewController {

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
}

extension SignInController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
}
