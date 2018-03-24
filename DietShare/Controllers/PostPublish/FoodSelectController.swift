//
//  FoodSelectController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class FoodSelectController: UIViewController {
    @IBOutlet weak private var addFoodButton: UIButton!

    private let foodCellIdentifier = "FoodCell"
    private let numberOfSections = 2
    private var numberOfItems = 4

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }

    func setUpUI() {
        addFoodButton.layer.cornerRadius = Constants.buttonBorderRadius
        addFoodButton.layer.borderWidth = Constants.buttonBorderWidth
        addFoodButton.layer.borderColor = Constants.lightTextColor.cgColor
    }
}

extension FoodSelectController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: foodCellIdentifier, for: indexPath)

        guard let foodCell = cell as? FoodCell else {
            return cell
        }
        

        return foodCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
}
