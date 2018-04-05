//
//  RestaurantFullListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class RestaurantFullListCell: UICollectionViewCell {
    
    @IBOutlet weak private var restaurantImage: UIImageView!
    @IBOutlet weak private var restaurantName: UILabel!
    @IBOutlet weak var restaurantType: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    func setImage(_ image: UIImage) {
        restaurantImage.image = image
        addRoundedRectBackground(restaurantImage, Constants.defaultCornerRadius, 0, UIColor.clear.cgColor, UIColor.clear)
    }
    
    func setName(_ name: String) {
        // TODO - decide on what to put here for restaurantName
        restaurantName.text = name
    }
    
    // Set the rating stars view according to the given score
    func setRating(_ ratingScore: Double) {
        let roundedScore = Int(ratingScore)
        for i in 0..<roundedScore {
            stars[i].image = #imageLiteral(resourceName: "star-filled")
        }
        
        let residual = ratingScore - Double(roundedScore)
        if residual >= 0.5 {
            stars[roundedScore].image = #imageLiteral(resourceName: "star-half")
        } else if roundedScore < 5 {
            stars[roundedScore].image = #imageLiteral(resourceName: "star-empty")
        }
        
        if roundedScore < 5 {
            for j in roundedScore + 1..<5 {
                stars[j].image = #imageLiteral(resourceName: "star-empty")
            }
        }
    }
    
    func setNumOfRating(_ numOfRating: Int) {
        self.ratingNumber.text = "\(numOfRating) ratings"
    }
    
    func setDistance(_ distance: Double) {
        self.distance.text = "\(distance) km"
    }
}

