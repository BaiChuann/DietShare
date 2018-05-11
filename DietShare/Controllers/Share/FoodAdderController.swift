//
//  FoodAdderController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftMessages

protocol FoodAdderDelegate: class {
    func addIngredient(_: Ingredient)
    func onPopUpDismissed()
}

class FoodAdderController: UIViewController {
    @IBOutlet weak private var addIngredientImage: UIImageView!
    @IBOutlet weak private var cursorView: UIView!
    @IBOutlet weak private var nameInput: UITextField!
    @IBOutlet weak private var ingredientCollectionView: UICollectionView!
    @IBOutlet weak private var canvas: UIImageView!

    var shareState: ShareState?
    private let ingredientCellIdentifier = "IngredientCell"
    private let ingredientPopupNibName = "IngredientPopup"
    private var ingredients = [Ingredient]()
    private var foodName: String?
    private var originalViewY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAddIngredientImageTapped))
        addIngredientImage.isUserInteractionEnabled = true
        addIngredientImage.addGestureRecognizer(tapGestureRecognizer)
        canvas.image = shareState?.originalPhoto

        setUpUI()
        setUpInput()
    }

    override func viewDidAppear(_ animated: Bool) {
        originalViewY = view.frame.origin.y
        addKeyboardNotifications()
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {() -> Void in
            self.cursorView.alpha = 0 }, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let name = foodName, !name.isEmpty, shareState?.originalPhoto != nil else {
            let warningView = MessageView.viewFromNib(layout: .cardView)
            warningView.configureTheme(.warning)
            warningView.configureDropShadow()
            warningView.configureContent(title: "Sorry", body: "Please add food name and ingredients before proceeding.")
            warningView.button?.isHidden = true
            warningView.configureBackgroundView(sideMargin: 0)
            SwiftMessages.show(view: warningView)
            return false
        }
        
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoModifier" {
            if let destinationVC = segue.destination as? PhotoModifierController {
                guard let name = foodName, !name.isEmpty, let image = shareState?.originalPhoto else {
                    return
                }

                let food = Food(name: name, image: image, ingredients: ingredients, nutrition: getNutritionInfo())
                shareState?.food = food
                destinationVC.shareState = shareState
            }
        }
    }
    
    private func getNutritionInfo() -> [NutritionType: Double] {
        var carbohydrate = 0.0
        var calories = 0.0
        var proteins = 0.0
        var fats = 0.0
        
        ingredients.forEach {
            carbohydrate += $0.rawInfo.nutrition[NutritionType.carbohydrate] ?? 0
            calories += $0.rawInfo.nutrition[NutritionType.calories] ?? 0
            proteins += $0.rawInfo.nutrition[NutritionType.proteins] ?? 0
            fats += $0.rawInfo.nutrition[NutritionType.fats] ?? 0
        }
        
        let nutrition = [
            NutritionType.calories: calories,
            NutritionType.carbohydrate: carbohydrate,
            NutritionType.fats: fats,
            NutritionType.proteins: proteins
        ]
        
        return nutrition
    }

    private func setUpUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func setUpInput() {
        nameInput.delegate = self
        nameInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc
    private func onAddIngredientImageTapped() {
        removeKeyboardNotifications()

        let ingredientPopup = IngredientPopupController(nibName: ingredientPopupNibName, bundle: nil)
        let popup = PopupDialog(viewController: ingredientPopup, gestureDismissal: false)
        ingredientPopup.delegate = self
        present(popup, animated: true, completion: nil)
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

extension FoodAdderController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ingredientCellIdentifier, for: indexPath)

        guard let ingredientCell = cell as? IngredientCell else {
            return cell
        }

        let ingredient = ingredients[indexPath.item]
        // Disable image for now, as the api that provides ingredient image is not be ready yet.
        // ingredientCell.setImage(ingredient.image)
        ingredientCell.setName(ingredient.name)

        return ingredientCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }
}

extension FoodAdderController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        foodName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        cursorView.isHidden = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let foodName = foodName, !foodName.isEmpty else {
            cursorView.isHidden = false
            return
        }
    }
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            foodName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

extension FoodAdderController: FoodAdderDelegate {
    func addIngredient(_ ingredient: Ingredient) {
        print("adding ingredient \(ingredient.name)")
        ingredients.append(ingredient)
        ingredientCollectionView.reloadData()
    }

    func onPopUpDismissed() {
        addKeyboardNotifications()
    }
}
