//
//  IngredientPopupController.swift
//  DietShare
//
//  Created by Fan Weiguang on 23/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.

import UIKit
import DropDown
import SwiftMessages
import AMPopTip

enum IngredientInfoType: Int {
    case name = 0, quantity, uint
}

/*
 A view controller for the popup where user can add ingredients for custom food.
 */
class IngredientPopupController: UIViewController {
    @IBOutlet private var inputGroup: [UITextField]!
    @IBOutlet private var unitButtonGroup: [UIButton]!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var infoButton: UIButton!
    @IBOutlet weak private var inputsView: UIStackView!
    
    weak var delegate: FoodAdderDelegate?
    private var currentSelectedUnit = 0
    private let ingredientDropDown = DropDown()
    private var quantity: Int?
    private var unit = IngredientUnit.sBowl
    private var image = UIImage(named: "ingredient-example")
    private var selectedIngredient: RawIngredient?
    private var ingredientList = [RawIngredient]()
    private let popTip = PopTip()
    private var isShowingTip = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpIngredientDropDown()
        setUpInputDelegate()
        addInputBorder(for: inputGroup, withColor: Constants.lightTextColor)
        fetchIngredientDataList()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let quantity = quantity,
            let image = image,
            let rawIngredient = selectedIngredient else {
            return
        }

        let currentIngredient = Ingredient(image: image, quantity: quantity, unit: unit, rawInfo: rawIngredient)
        delegate?.addIngredient(currentIngredient)
    }

    @IBAction func onUnitSelected(_ sender: Any) {
        if let button = sender as? UIButton {
            button.tintColor = Constants.themeColor
            button.isSelected = true

            let previouslySelected = unitButtonGroup.first { $0.tag == currentSelectedUnit }
            previouslySelected?.isSelected = false
            previouslySelected?.tintColor = Constants.normalTextColor

            currentSelectedUnit = button.tag
        }
    }

    /*
     Add ingredient if all fields are not empty, show warning messages otherwise.
     */
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        for input in inputGroup {
            guard let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            switch input.tag {
            case IngredientInfoType.name.rawValue:
                selectedIngredient = ingredientList.first { $0.name.lowercased() == text.lowercased() }
            case IngredientInfoType.quantity.rawValue:
                quantity = Int(text)
            default:
                continue
            }
        }

        guard let quantity = quantity, quantity > 0, selectedIngredient != nil else {
            let warningView = MessageView.viewFromNib(layout: .cardView)
            warningView.configureTheme(.warning)
            warningView.configureDropShadow()
            warningView.configureContent(title: "Failed to save", body: "Please provide all information for the ingredient. For ingredients, please choose from our list.")
            warningView.button?.isHidden = true
            warningView.configureBackgroundView(sideMargin: 12)
            SwiftMessages.show(view: warningView)
            return
        }

        dismissPopUp()
    }

    @IBAction func onCloseButtonPressed(_ sender: Any) {
        dismissPopUp()
    }
    
    @IBAction func onInfoButtonPressed(_ sender: Any) {
        let spacing: CGFloat = 10
        let frame = CGRect(
            x: infoButton.frame.maxX,
            y: inputsView.frame.origin.x + infoButton.frame.height * 2 + spacing,
            width: infoButton.frame.width,
            height: infoButton.frame.height
        )
        popTip.edgeMargin = spacing

        if isShowingTip {
            popTip.hide()
        } else {
            popTip.show(
                text: "Currently only ingredients from the dropdown list are supported.",
                direction: .down,
                maxWidth: 200,
                in: view,
                from: frame
            )
        }

        isShowingTip = !isShowingTip
    }

    // Fetch ingredients data from plist and stores as RawIngredient list. (Real situation would be fetching from database)
    private func fetchIngredientDataList() {
        let INGREDIENT_LIST_PATH = Bundle.main.path(forResource: "Ingredient_list", ofType: "plist")
        let INGREDIENT_LIST_KEY_NAME = "name"
        let INGREDIENT_LIST_KEY_ENERGY = "energy"
        let INGREDIENT_LIST_KEY_PROTEIN = "protein"
        let INGREDIENT_LIST_KEY_CARBOHYDRATE = "carbohydrate"
        let INGREDIENT_LIST_KEY_FAT = "fat"
        
        if let path = INGREDIENT_LIST_PATH, let data = NSArray(contentsOf: URL(fileURLWithPath: path)) {
            for entry in data {
                guard let dict = entry as? [String: AnyObject] else {
                    continue
                }
                
                guard let proteins = dict[INGREDIENT_LIST_KEY_PROTEIN] as? Double,
                    let carbohydrate = dict[INGREDIENT_LIST_KEY_CARBOHYDRATE] as? Double,
                    let fats = dict[INGREDIENT_LIST_KEY_FAT] as? Double,
                    let calories = dict[INGREDIENT_LIST_KEY_ENERGY] as? Double,
                    let name = dict[INGREDIENT_LIST_KEY_NAME] as? String else {
                    continue
                }
                
                let nutrition = [
                    NutritionType.proteins: proteins,
                    NutritionType.carbohydrate: carbohydrate,
                    NutritionType.fats: fats,
                    NutritionType.calories: calories
                ]
                
                ingredientList.append(RawIngredient(name: name, nutrition: nutrition))
            }
        }
    }

    private func setUpUI() {
        inputGroup.forEach {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: $0.frame.height))
            $0.leftView = paddingView
            $0.leftViewMode = .always
        }

        unitButtonGroup.forEach {
            let tintedImage = $0.currentImage?.withRenderingMode(.alwaysTemplate)

            $0.setImage(tintedImage, for: .normal)
            $0.setTitleColor(Constants.themeColor, for: .selected)
            $0.setTitleColor(Constants.normalTextColor, for: .normal)

            if $0.tag == currentSelectedUnit {
                $0.isSelected = true
                $0.tintColor = Constants.themeColor
            }
        }

        saveButton.layer.cornerRadius = Constants.cornerRadius
        saveButton.backgroundColor = Constants.themeColor
        saveButton.setTitleColor(UIColor.white, for: .normal)

        popTip.bubbleColor = Constants.themeColor
        popTip.textColor = UIColor.white
        popTip.textAlignment = .center
        popTip.dismissHandler = { _ in
            self.isShowingTip = false
        }
        popTip.entranceAnimation = .fadeIn
        popTip.exitAnimation = .fadeOut
    }

    private func setUpIngredientDropDown() {
        if let font = UIFont(name: Constants.fontRegular, size: 14) {
            ingredientDropDown.textFont = font
        }
        ingredientDropDown.textColor = Constants.normalTextColor
        ingredientDropDown.backgroundColor = UIColor.white
        ingredientDropDown.shadowOpacity = 0
        ingredientDropDown.cellNib = UINib(nibName: "IngredientDropDownCell", bundle: nil)
        ingredientDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? IngredientDropDownCell else {
                return
            }
            cell.ingredientIcon.image = self.image
            cell.optionLabel.text = item
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

    private func setUpInputDelegate() {
        inputGroup.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func dismissPopUp() {
        dismiss(animated: true, completion: nil)
        delegate?.onPopUpDismissed()
    }

    @objc
    private func endEditing() {
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
            ingredientDropDown.anchorView = textField
            ingredientDropDown.bottomOffset = CGPoint(x: 0, y: textField.bounds.height)
            ingredientDropDown.dataSource = ingredientList.filter { $0.name.contains(input) }.map { $0.name }

            if !ingredientDropDown.dataSource.isEmpty {
                ingredientDropDown.show()
            }
        }
    }
}
