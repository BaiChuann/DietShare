//
//  SignUpController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.cs3217. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {

    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var inputLabelGroup: [UILabel]!
    @IBOutlet private var inputValidationGroup: [UIImageView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInput()
        addInputBorder(for: inputGroup)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onSignInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func setUpInput() {
        inputValidationGroup.forEach { $0.isHidden = true }

        inputGroup.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

}

extension SignUpController: UITextFieldDelegate {
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

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let validationMark = inputValidationGroup.first(where: { $0.tag == textField.tag }) else {
            return
        }

        if text.isEmpty {
            validationMark.isHidden = true
            return
        }

        if textField.tag == 2 {
            validationMark.isHidden = text.count < 8
        } else {
            validationMark.isHidden = false
        }
    }
}
