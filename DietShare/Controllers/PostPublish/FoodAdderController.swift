//
//  FoodAdderController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import PopupDialog
import TweeTextField

protocol FoodAdderDelegate: class {
    func addIngredient(_: Ingredient)
    func onPopUpDismissed()
}

class FoodAdderController: UIViewController {
    @IBOutlet weak private var addIngredientImage: UIImageView!
    @IBOutlet weak private var cursorView: UIView!
    @IBOutlet weak private var nameInput: TweeActiveTextField!
    @IBOutlet weak private var ingredientCollectionView: UICollectionView!

    var currentPhoto: UIImage?
    private let ingredientCellIdentifier = "IngredientCell"
    private let ingredientPopupNibName = "IngredientPopup"
    private var ingredients = [Ingredient]()
    private var foodName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAddIngredientImageTapped))
        addIngredientImage.isUserInteractionEnabled = true
        addIngredientImage.addGestureRecognizer(tapGestureRecognizer)

        setUpUI()
        setUpInput()
    }

    override func viewDidAppear(_ animated: Bool) {
        addKeyboardNotifications()
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {() -> Void in
            self.cursorView.alpha = 0 }, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }

    private func setUpUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func setUpInput() {
        nameInput.delegate = self

        nameInput.minimizationAnimationType = .smoothly
        if let font = UIFont(name: Constants.fontBold, size: 24) {
            nameInput.font = font
        }
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

        self.view.frame.origin.y = -keyboardHeight
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
        ingredientCell.setImage(ingredient.image)
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
