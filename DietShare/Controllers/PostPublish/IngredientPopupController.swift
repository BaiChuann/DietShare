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

    private var currentSelectedUnit = 0
    private let normalColor = hexToUIColor(hex: "#9CA0A1")
    private let highlightColor = hexToUIColor(hex: "FFD147")

    override func viewDidLoad() {
        super.viewDidLoad()

//        setUpUnitButton()
        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: hexToUIColor(hex: "#CACFD0"))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @IBAction func onUnitSelected(_ sender: UIButton!) {
        let highlightColor = hexToUIColor(hex: "FFD147")
        sender.tintColor = highlightColor
        sender.isSelected = true

        let previouslySelected = unitButtonGroup.first { $0.tag == currentSelectedUnit }
        previouslySelected?.isSelected = false
        previouslySelected?.tintColor = normalColor

        currentSelectedUnit = sender.tag
    }

    func setUpUnitButton() {
        unitButtonGroup.forEach {

            $0.setTitleColor(highlightColor, for: .selected)
            $0.setTitleColor(normalColor, for: .normal)

            if $0.tag == currentSelectedUnit {
                $0.isSelected = true
            }
        }
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
