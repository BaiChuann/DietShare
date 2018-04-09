//
//  FloatingTextInputController.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import Presentr

class FloatingTextInputController: UIViewController {
    @IBOutlet weak private var textInput: UITextField!
    @IBOutlet weak private var colorCollectionView: UICollectionView!
    @IBOutlet weak private var cursor: UIView!
    @IBOutlet weak private var sizeSlider: UISlider!

    private let textColorCellId = "TextColorCell"
    private let colors = [
        "#000000",
        "#ffffff",
        "#0984e3",
        "#55efc4",
        "#00b894",
        "#fdcb6e",
        "#ff7675",
        "#d63031",
        "#e84393",
        "#6c5ce7"
    ]
    private var originalViewY: CGFloat = 0
    private var text: String?
    private var colorIndex: Int?
    private var size: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        textInput.delegate = self
        let nib = UINib(nibName: textColorCellId, bundle: nil)
        colorCollectionView.register(nib, forCellWithReuseIdentifier: textColorCellId)
        colorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:))))
    }

    override func viewDidAppear(_ animated: Bool) {
        originalViewY = view.frame.origin.y
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {() -> Void in
            self.cursor.alpha = 0 }, completion: nil)
        addKeyboardNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }

    @objc
    func tapHandler(sender: UIPanGestureRecognizer) {
        if let index = colorIndex,
            let cell = colorCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TextColorCell {
            cell.isSelected = false
        }

        if let indexPath = colorCollectionView.indexPathForItem(at: sender.location(in: colorCollectionView)),
            let cell = colorCollectionView.cellForItem(at: indexPath) {
            cell.isSelected = true
            colorIndex = indexPath.item
        }
    }

    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    private func updateKeyboardFrame(notification: NSNotification, keyboardHeight: CGFloat) {
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        self.view.frame.origin.y = originalViewY - keyboardHeight
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        updateKeyboardFrame(notification: notification, keyboardHeight: keyboardSize.height)
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        updateKeyboardFrame(notification: notification, keyboardHeight: 0)
    }

    @objc
    private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        updateKeyboardFrame(notification: notification, keyboardHeight: keyboardSize.height)
    }
}

extension FloatingTextInputController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textColorCellId, for: indexPath)

        guard let textColorCell = cell as? TextColorCell else {
            return cell
        }

        let color = hexToUIColor(hex: colors[indexPath.item])
        textColorCell.setColor(color)

        return textColorCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FloatingTextInputController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        cursor.isHidden = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        cursor.isHidden = text != nil
    }
}
