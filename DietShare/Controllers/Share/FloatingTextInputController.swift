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
    @IBOutlet weak private var okButton: UIButton!

    weak var delegate: FloatingContentAdderDelegate?
    private let textColorCellId = "TextColorCell"
    private let colors = [
        "#ffffff",
        "#000000",
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
    private var colorIndex = 0
    private var size: CGFloat = 20
    private var isNewLabel = true
    private var font = UIFont.systemFont(ofSize: 20)
    private let textPreview = UILabel()
    private let textPreviewHeight: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: textColorCellId, bundle: nil)
        colorCollectionView.register(nib, forCellWithReuseIdentifier: textColorCellId)
        colorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:))))
        textInput.delegate = self

        setUpUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        colorCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.addSubview(textPreview)
        view.bringSubview(toFront: textPreview)
        view.clipsToBounds = false
        textPreview.frame = CGRect(x: 0, y: -(view.bounds.height + textPreviewHeight) / 2, width: view.bounds.width, height: textPreviewHeight)
        originalViewY = view.frame.origin.y
        if let cell = colorCollectionView.cellForItem(at: IndexPath(item: colorIndex, section: 0)) as? TextColorCell {
            cell.setSelected(true)
        }
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {() -> Void in
            self.cursor.alpha = 0 }, completion: nil)

        fetchTextInfo()
        updateUI()
        updateTextPreview()
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        textPreview.removeFromSuperview()
    }

    override func viewDidDisappear(_ animated: Bool) {
        view.layer.removeAllAnimations()
        removeKeyboardNotifications()
        text = nil
        colorIndex = 0
        size = 20
    }

    @objc
    func tapHandler(sender: UIPanGestureRecognizer) {
        if let cell = colorCollectionView.cellForItem(at: IndexPath(item: colorIndex, section: 0)) as? TextColorCell {
            cell.setSelected(false)
        }

        if let indexPath = colorCollectionView.indexPathForItem(at: sender.location(in: colorCollectionView)),
            let cell = colorCollectionView.cellForItem(at: indexPath) as? TextColorCell {
            cell.setSelected(true)
            colorIndex = indexPath.item
        }

        updateTextPreview()
    }

    @IBAction func onTextValueChanged(_ sender: Any) {
        if let textField = sender as? UITextField {
            text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let textValue = text, textValue.isEmpty {
                text = nil
            }
            updateTextPreview()
        }
    }

    @IBAction func onSizeValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            size = CGFloat(slider.value)
            updateTextPreview()
        }
    }

    @IBAction func onCancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onOKButtonPressed(_ sender: Any) {
        if isNewLabel, let text = text {
            delegate?.addNewTextLabelInfo(text: text, color: hexToUIColor(hex: colors[colorIndex]), size: size, font: font)
        } else {
            delegate?.updateTextLabelInfo(text: text, color: hexToUIColor(hex: colors[colorIndex]), size: size, font: font)
        }

        dismiss(animated: true, completion: nil)
    }

    private func fetchTextInfo() {
        if let info = delegate?.getSelectedLabelInfo() {
            text = info.text
            colorIndex = colors.index { info.color.equals(hexToUIColor(hex: $0)) } ?? 0
            size = info.size
            font = info.font
            isNewLabel = false
        } else {
            guard let fontName = delegate?.getSelectedFont(),
                let selectedFont = UIFont(name: fontName, size: size) else {
                    return
            }
            font = selectedFont
            isNewLabel = true
        }
    }

    private func setUpUI() {
        okButton.layer.cornerRadius = Constants.cornerRadius
        textPreview.textAlignment = .center
    }

    private func updateTextPreview() {
        textPreview.text = text
        textPreview.textColor = hexToUIColor(hex: colors[colorIndex])
        textPreview.font = font.withSize(size)
    }

    private func updateUI() {
        let cells = colorCollectionView.visibleCells.filter { $0.isSelected }
        guard let selectedCells = cells as? [TextColorCell] else {
            return
        }

        selectedCells.forEach {
            guard let index = colorCollectionView.indexPath(for: $0) else {
                return
            }

            if index.item != colorIndex {
                $0.setSelected(false)
            }
        }

        if let cellToBeSelected = colorCollectionView.cellForItem(at: IndexPath(item: colorIndex, section: 0)) as? TextColorCell {
            cellToBeSelected.setSelected(true)
        }

        UIView.animate(withDuration: 0.2) {
            self.sizeSlider.setValue(Float(self.size), animated: true)
        }
        textInput.text = text
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (colorCollectionView.frame.width - 10) / CGFloat(colors.count)
        return CGSize(width: size, height: size)
    }
}

extension FloatingTextInputController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        cursor.isHidden = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = text, !text.isEmpty {
            cursor.isHidden = true
        } else {
            cursor.isHidden = false
        }
    }
}
