//
//  FoodAdderController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import PopupDialog

class FoodAdderController: UIViewController {

    @IBOutlet weak private var addIngredientImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAddIngredientImageTapped))
        addIngredientImage.isUserInteractionEnabled = true
        addIngredientImage.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    func onAddIngredientImageTapped() {
        let ingredientPopup = IngredientPopupController(nibName: "IngredientPopup", bundle: nil)
        let popup = PopupDialog(viewController: ingredientPopup, gestureDismissal: false)
        present(popup, animated: true, completion: nil)
    }
}
