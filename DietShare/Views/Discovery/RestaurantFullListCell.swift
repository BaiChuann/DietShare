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
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    func setImage(_ image: UIImage) {
        restaurantImage.image = image
    }
    
    func setName(_ name: String) {
        // TODO - decide on what to put here for restaurantName
        restaurantName.text = "  #" + name + "  "
        
        restaurantNameLabel.text = name
        addRoundedRectBackground(restaurantNameLabel, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
    }
    
    
}

