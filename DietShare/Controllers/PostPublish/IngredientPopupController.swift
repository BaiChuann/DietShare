//
//  IngredientPopupController.swift
//  DietShare
//
//  Created by Fan Weiguang on 23/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class IngredientPopupController: UIViewController {
    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var unitButtonGroup: [UIButton]!
    @IBOutlet weak private var saveButton: UIButton!

    private var currentSelectedUnit = 0
    private let normalColor = hexToUIColor(hex: "#9CA0A1")
    private let highlightColor = hexToUIColor(hex: "FFD147")

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: hexToUIColor(hex: "#CACFD0"))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @IBAction func onUnitSelected(_ sender: Any) {
        if let button = sender as? UIButton {
            button.tintColor = highlightColor
            button.isSelected = true

            let previouslySelected = unitButtonGroup.first { $0.tag == currentSelectedUnit }
            previouslySelected?.isSelected = false
            previouslySelected?.tintColor = normalColor

            currentSelectedUnit = button.tag
        }
    }

    @IBAction func onSaveButtonPressed(_ sender: Any) {
    }

    func setUpUI() {
        inputGroup.forEach {
            $0.placeholder = nil

            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: $0.frame.height))
            $0.leftView = paddingView
            $0.leftViewMode = .always
        }

        unitButtonGroup.forEach {
            let tintedImage = $0.currentImage?.withRenderingMode(.alwaysTemplate)

            $0.setImage(tintedImage, for: .normal)
            $0.setTitleColor(highlightColor, for: .selected)
            $0.setTitleColor(normalColor, for: .normal)

            if $0.tag == currentSelectedUnit {
                $0.isSelected = true
                $0.tintColor = highlightColor
            }
        }

        saveButton.layer.cornerRadius = 10
        saveButton.backgroundColor = highlightColor
        saveButton.setTitleColor(UIColor.white, for: .normal)
    }

    func setUpInputDelegate() {
        inputGroup.forEach { $0.delegate = self }
    }

    @objc
    func endEditing() {
        view.endEditing(true)
    }
}

extension IngredientPopupController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}

