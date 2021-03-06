//
//  TextFieldController.swift
//  DietShare
//
//  Created by baichuan on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class represent a comment bar.
 * used when user tap the comment button of any post as well as in post detail page.
 */
class TextFieldController: UIViewController {
    
    @IBOutlet weak private var sendButton: UIButton!
    @IBOutlet weak private var textField: UITextField!
    private var tabHeight = CGFloat(0)
    private var commentDelegate: CommentDelegate!
    private var distance = CGFloat(0)
    override func viewDidLoad() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
//                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        let topBorder = UIView()
        topBorder.backgroundColor = Constants.darkTextColor
        topBorder.frame = CGRect(x: 0, y: 0, width:
            view.frame.width, height:
            0.5)
        view.addSubview(topBorder)
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = Constants.lightTextColor.cgColor
        sendButton.setTitleColor(Constants.lightTextColor, for: .normal)
    }
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        distance = keyboardHeight - tabHeight
        view.frame.origin.y -= (distance)
    }
    @objc func keyboardWillChangeFrame(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        print(keyboardHeight)
        view.frame.origin.y += (distance)
        distance = keyboardHeight - tabHeight
        view.frame.origin.y -= (distance)
    }
    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y += (distance)
        distance = CGFloat(0)
    }
    func setTabHeight(_ height: CGFloat) {
        tabHeight = height
    }
    func setDelegate(_ parent: CommentDelegate) {
        commentDelegate = parent
    }
    @IBAction func onSend(_ sender: Any) {
        reset()
        commentDelegate.onComment(textField.text!)
        textField.text = ""
    }
    func reset() {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    func setText(_ text: String) {
        startEditing()
        textField.text = text
    }
    func startEditing() {
        textField.becomeFirstResponder()
    }
}

extension TextFieldController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // return NO to disallow editing.
        print("TextField should begin editing method called")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
        print("TextField should snd editing method called")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
        print("TextField did end editing method called")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if updatedString == "" {
            sendButton.setTitleColor(Constants.lightTextColor, for: .normal)
            sendButton.layer.borderColor = Constants.lightTextColor.cgColor
            sendButton.isUserInteractionEnabled = false
        } else {
            sendButton.setTitleColor(Constants.themeColor, for: .normal)
            sendButton.layer.borderColor = Constants.themeColor.cgColor
            sendButton.isUserInteractionEnabled = true
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // called when clear button pressed. return NO to ignore (no notifications)
        print("TextField should clear method called")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        return true
    }
}
