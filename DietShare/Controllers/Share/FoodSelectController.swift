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
    @IBOutlet weak private var loaderLabel: UILabel!

    var shareState: ShareState?
    private let foodCellIdentifier = "FoodCell"
    private let numberOfSections = 2
    private let numberOfRows = 2
    private let spacingBetweenCells: CGFloat = 20
    private var foods = [Food]()
    private var isFetchingData = true
    private var elapsedTime = Date()
    private var requestTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

//        let nutrition = [
//            NutritionType.calories: 400.0,
//            NutritionType.carbohydrate: 100.0,
//            NutritionType.proteins: 80.0,
//            NutritionType.fats: 120.0
//        ]
//        for i in 0...3 {
//            foods.append(Food(id: 0, name: "Not food", nutrition: nutrition, image: UIImage()))
//        }

        fetchRecognitionResult()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFoodAdder" {
            if let destinationVC = segue.destination as? FoodAdderController {
                requestTimer.invalidate()
                destinationVC.shareState = shareState
            }
        }
    }

    private func fetchRecognitionResult() {
        elapsedTime = Date()
        requestTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateFetchingLabel), userInfo: nil, repeats: true)
        updateFetchingStatus(status: true)

        guard let image = shareState?.originalPhoto,
            let imageData = UIImageJPEGRepresentation(image, 0.7) else {
            return
        }

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let queryUrl = "https://47.88.223.32:5000/api/v1/search/image/"
        let key = "image_file"
        let type = "image/jpeg"
        let fileName = "test.jpg"
        let boundary = "Boundary-\(NSUUID().uuidString)"

        guard let url = URL(string: queryUrl) else {
            return
        }

        var request = URLRequest(url: url)
        var body = Data()

        request.httpMethod = "POST"
        request.setValue("Token 872efbb5389500158d017167a3f14e6ac8538aeb", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(type)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error when fetching food results")
            }

            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data,
                let json = try? JSON(data: data) {
                    print("network working")
                    let foodInfo = json["data"]["food_info"]
                    for i in 0...3 {
                        let food = foodInfo[i]
                        guard let label = food["food_name"].string else {
                            return
                        }
                        let id = food["id"].int ?? 0
                        let nutrition = [
                            NutritionType.calories: food["calories"].double ?? 0,
                            NutritionType.carbohydrate: food["carbohydrate"].double ?? 0,
                            NutritionType.proteins: food["protein"].double ?? 0,
                            NutritionType.fats: food["fat"].double ?? 0
                        ]
                        var image = UIImage()
                        if let url = food["food_sample_url"].url,
                            let imageData = try? Data(contentsOf: url),
                            let content = UIImage(data: imageData) {
                            image = content
                        }
                        self.foods.append(Food(id: id, name: label, nutrition: nutrition, image: image))

                        DispatchQueue.main.async {
                            self.updateFetchingStatus(status: false)
                        }
                    }
            } else {
                print("network failure")
            }
        }

        task.resume()
    }

    private func updateFetchingStatus(status: Bool) {
        isFetchingData = status
        loader.isHidden = !status

        if !isFetchingData {
            requestTimer.invalidate()
            loaderLabel.isHidden = true
            loader.stopAnimating()
            foodCollectionView.reloadData()
        }
    }

    @objc
    private func updateFetchingLabel() {
        let elapsedTime = -self.elapsedTime.timeIntervalSinceNow

        print("elapsed time: \(elapsedTime)")
        if elapsedTime < 5 {
            loaderLabel.isHidden = true
        } else {
            loaderLabel.isHidden = false
        }
    }

    private func setUpUI() {
        loader.startAnimating()
        loaderLabel.isHidden = true

        addFoodButton.layer.cornerRadius = Constants.cornerRadius
        addFoodButton.layer.borderWidth = Constants.buttonBorderWidth
        addFoodButton.layer.borderColor = Constants.lightTextColor.cgColor

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }

    private func onFoodSelected(index: Int) {
        if !foods[index].isFood {
            performSegue(withIdentifier: "ShowFoodAdder", sender: nil)
            return
        }

        guard let destinationVC = storyboard?.instantiateViewController(withIdentifier: "StickerAdderViewController") as? PhotoModifierController else {
            return
        }

        shareState?.food = foods[index]
        destinationVC.shareState = shareState
        self.navigationController?.pushViewController(destinationVC, animated: true)
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
        let index = indexPath.section * 2 + indexPath.item
        onFoodSelected(index: index)
    }
}

extension FoodSelectController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!) )
    }
}
