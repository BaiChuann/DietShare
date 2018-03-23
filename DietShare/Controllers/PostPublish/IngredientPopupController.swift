//
//  IngredientPopupController.swift
//  DietShare
//
//  Created by Fan Weiguang on 23/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import DropDown

enum IngredientInfoType: Int {
    case name = 0, quantity, uint
}

class IngredientPopupController: UIViewController {
    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var unitButtonGroup: [UIButton]!
    @IBOutlet weak private var warningLabel: UILabel!
    @IBOutlet weak private var saveButton: UIButton!

    weak var delegate: FoodAdderDelegate?
    private var currentSelectedUnit = 0
    private let normalColor = hexToUIColor(hex: "#9CA0A1")
    private let highlightColor = hexToUIColor(hex: "FFD147")
    private let ingredientDropDown = DropDown()
    private var name: String?
    private var quantity: Int?
    private var unit = IngredientUnit.sBowl
    private var image = UIImage(named: "ingredient-example")

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpIngredientDropDown()
        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: hexToUIColor(hex: "#CACFD0"))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let name = name, let quantity = quantity, let image = image else {
            return
        }

        let currentIngredient = Ingredient(name: name, image: image, quantity: quantity, unit: unit)
        delegate?.addIngredient(currentIngredient)
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
        for input in inputGroup {
            guard let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            switch input.tag {
            case IngredientInfoType.name.rawValue:
                name = text 
            case IngredientInfoType.quantity.rawValue:
                quantity = Int(text)
            default:
                continue
            }
        }

        guard let name = name, let quantity = quantity, !name.isEmpty, quantity > 0 else {
            warningLabel.isHidden = false
            return
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCloseButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func setUpUI() {
        inputGroup.forEach {
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

        warningLabel.isHidden = true
    }

    func setUpIngredientDropDown() {
        if let font = UIFont(name: "Verdana", size: 14) {
            ingredientDropDown.textFont = font
        }
        ingredientDropDown.textColor = normalColor
        ingredientDropDown.backgroundColor = UIColor.white
        ingredientDropDown.shadowOpacity = 0
        ingredientDropDown.cellNib = UINib(nibName: "IngredientDropDownCell", bundle: nil)
        ingredientDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? IngredientDropDownCell else {
                return
            }
            cell.ingredientIcon.image = self.image
            cell.optionLabel.text = "food \(index)"
        }

        ingredientDropDown.selectionAction = { [weak self] index, item in
            guard let ingredientNameInput = self?.inputGroup.first(where: { input in
                input.tag == IngredientInfoType.name.rawValue
            }) else {
                print("Ingredient name input not found")
                return
            }

            ingredientNameInput.text = item
        }
    }

    func setUpInputDelegate() {
        inputGroup.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == IngredientInfoType.name.rawValue {
            ingredientDropDown.hide()
        }
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == IngredientInfoType.name.rawValue, let text = textField.text {
            let input = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let exampleDataSource = ["food1", "food2", "food3", "food4"]
            ingredientDropDown.anchorView = textField
            ingredientDropDown.bottomOffset = CGPoint(x: 0, y: textField.bounds.height)
            ingredientDropDown.dataSource = exampleDataSource.filter { $0.contains(input) }

            if !ingredientDropDown.dataSource.isEmpty {
                ingredientDropDown.show()
            }
        }
    }
}
