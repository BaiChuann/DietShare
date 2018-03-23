//
//  FoodAdderController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import PopupDialog

protocol FoodAdderDelegate: class {
    func addIngredient(_: Ingredient)
}

class FoodAdderController: UIViewController {

    @IBOutlet weak private var addIngredientImage: UIImageView!
    @IBOutlet weak private var ingredientCollectionView: UICollectionView!

    private let ingredientCellIdentifier = "IngredientCell"
    private let ingredientPopupNibName = "IngredientPopup"
    private var ingredients = [Ingredient]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAddIngredientImageTapped))
        addIngredientImage.isUserInteractionEnabled = true
        addIngredientImage.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    func onAddIngredientImageTapped() {
        let ingredientPopup = IngredientPopupController(nibName: ingredientPopupNibName, bundle: nil)
        let popup = PopupDialog(viewController: ingredientPopup, gestureDismissal: false)
        ingredientPopup.delegate = self
        present(popup, animated: true, completion: nil)
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

extension FoodAdderController: FoodAdderDelegate {
    func addIngredient(_ ingredient: Ingredient) {
        print("adding ingredient \(ingredient.name)")
        ingredients.append(ingredient)
        ingredientCollectionView.reloadData()
    }
}
