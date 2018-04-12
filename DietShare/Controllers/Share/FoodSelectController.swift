//
//  FoodSelectController.swift
//  DietShare
//
//  Created by Fan Weiguang on 22/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class FoodSelectController: UIViewController {
    @IBOutlet weak private var loader: NVActivityIndicatorView!
    @IBOutlet weak private var addFoodButton: UIButton!
    @IBOutlet weak private var foodCollectionView: UICollectionView!

    var shareState: ShareState?
    private let foodCellIdentifier = "FoodCell"
    private let numberOfSections = 2
    private let numberOfRows = 2
    private let spacingBetweenCells: CGFloat = 20
    private var foods = [Food]()
    private var isFetchingData = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        fetchFoodImage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFoodAdder" {
            if let destinationVC = segue.destination as? FoodAdderController {
                destinationVC.shareState = shareState
            }
        }
    }

    private func fetchFoodImage() {
        updateFetchingStatus(status: true)

        let names = ["Dou Hua", "Fish Ball Noodle", "Kopi", "Char siew bao"]
        let queryUrl = "https://api.cognitive.microsoft.com/bing/v7.0/images/search"
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "f8726113e2df45b8a64d8d3c0155b2a6"
        ]

        for name in names {
            let request_params: Parameters = [
                "q": name,
                "count": 1,
                "size": "Small",
                "safeSearch": "Strict"
            ]

            Alamofire.request(queryUrl, parameters: request_params, headers: headers).responseData { response in
                guard let data = response.data,
                    let json = try? JSON(data: data),
                    let url = json["value"][0]["contentUrl"].string else {
                        return
                }

                if let imageUrl = URL(string: url),
                    let imageData = try? Data(contentsOf: imageUrl),
                    let image = UIImage(data: imageData) {
                    self.foods.append(Food(name: name, image: image))
                }

                self.updateFetchingStatus(status: name != names.last)
            }
        }
    }

    private func updateFetchingStatus(status: Bool) {
        isFetchingData = status
        loader.isHidden = !status

        if !isFetchingData {
            loader.stopAnimating()
            foodCollectionView.reloadData()
        }
    }

    private func setUpUI() {
        loader.startAnimating()

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
        return foods.count / numberOfSections
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
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "StickerAdderViewController") as? PhotoModifierController else {
                return
        }

        destinationVC.shareState = shareState
        foodCell.setSelected()

        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
