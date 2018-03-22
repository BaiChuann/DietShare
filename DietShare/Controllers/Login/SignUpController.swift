//
//  SignUpController.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 nus.cs3217. All rights reserved.
//

import UIKit
import Validator

enum SignUpInputType: Int {
    case username = 0, email, password
}

enum ValidationErrors: String, Error {
    typealias RawValue = String

    case usernameInvalid = "Should be between 4-30 characters"
    case emailInvalid = "Invalid"
    case passwordDigitInvalid = "Should contain at least one number"
    case passwordLowerCaseInvalid = "Should contain at least one lowercase letter"
    case passwordUpperCaseInvalid = "Should contain at least one uppercase letter"
    case passwordLengthInvalid = "Should contain at least 8 characters"

    var message: String { return self.rawValue }
}

class SignUpController: UIViewController {

    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var inputLabelGroup: [UILabel]!
    @IBOutlet private var inputValidationGroup: [UIImageView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInput()
        addInputBorder(for: inputGroup, withColor: hexToUIColor(hex: "#FFD547"))
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

        var result: ValidationResult?

        if textField.tag == SignUpInputType.username.rawValue {
            let numericRule = ValidationRuleLength(min: 4, max: 20, error: ValidationErrors.usernameInvalid)
            result = text.validate(rule: numericRule)
        } else if textField.tag == SignUpInputType.email.rawValue {
            let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid)
            result = text.validate(rule: emailRule)
        } else if textField.tag == SignUpInputType.password.rawValue {
            var passwordRules = ValidationRuleSet<String>()

            let minLengthRule = ValidationRuleLength(min: 8, error: ValidationErrors.passwordLengthInvalid)
            let digitRule = ValidationRulePattern(pattern: ContainsNumberValidationPattern(), error: ValidationErrors.passwordDigitInvalid)
            let lowerCaseAlphabetRule = ValidationRulePattern(pattern: CaseValidationPattern.lowercase, error: ValidationErrors.passwordLowerCaseInvalid)
            let upperCaseAlphabetRule = ValidationRulePattern(pattern: CaseValidationPattern.uppercase, error: ValidationErrors.passwordUpperCaseInvalid)

            passwordRules.add(rule: minLengthRule)
            passwordRules.add(rule: digitRule)
            passwordRules.add(rule: lowerCaseAlphabetRule)
            passwordRules.add(rule: upperCaseAlphabetRule)

            result = text.validate(rules: passwordRules)
        }

        if let result = result {
            switch result {
            case .valid: validationMark.isHidden = false
            case .invalid: validationMark.isHidden = true
            }
        }
    }
}
