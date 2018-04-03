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
    @IBOutlet weak private var foodCollectionView: UICollectionView!
    private let foodCellIdentifier = "FoodCell"
    private let numberOfSections = 2
    private let numberOfRows = 2
    private let spacingBetweenCells: CGFloat = 20
    private var foods = [Food]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

//        foodCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFoodCellTapped)))

        // prepare for dummy data here
        for i in 1...4 {
            guard let image = UIImage(named: "food-result-\(i)") else {
                print("image for food-result-\(i) not found")
                continue
            }

            let name = "food \(i)"
            foods.append(Food(name: name, image: image))
        }
    }

//    @objc
//    private func onFoodCellTapped(sender: UITapGestureRecognizer) {
//        guard let indexPath = foodCollectionView.indexPathForItem(at: sender.location(in: foodCollectionView)),
//            let foodCell = foodCollectionView.dequeueReusableCell(withReuseIdentifier: foodCellIdentifier, for: indexPath) as? FoodCell else {
//            return
//        }
//
//        print("tap at \(indexPath)")
//
//        foodCell.setSelected()
//    }

    private func setUpUI() {
        addFoodButton.layer.cornerRadius = Constants.cornerRadius
        addFoodButton.layer.borderWidth = Constants.buttonBorderWidth
        addFoodButton.layer.borderColor = Constants.lightTextColor.cgColor


        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
}

extension FoodSelectController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: foodCellIdentifier, for: indexPath)

        guard let foodCell = cell as? FoodCell else {
            return cell
        }

        let index = indexPath.section * 2 + indexPath.item
        let food = foods[index]
        foodCell.setFoodName(food.name)
        foodCell.setFoodImage(food.image)

        return foodCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (foodCollectionView.bounds.width - spacingBetweenCells) / 2
        let height = (foodCollectionView.bounds.height - 2 * spacingBetweenCells) / 2

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacingBetweenCells / 2, left: 0, bottom: spacingBetweenCells / 2, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let foodCell = foodCollectionView.dequeueReusableCell(withReuseIdentifier: foodCellIdentifier, for: indexPath) as? FoodCell,
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "StickerAdderViewController") else {
                return
        }

        print("selected cell at \(indexPath)")
        foodCell.setSelected()

        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
