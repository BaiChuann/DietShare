//
//  CustomMarkerView.swift
//  DietShare
//
//  Created by Shuang Yang on 16/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class CustomMarkerView: UIView {
    var image: UIImage!
    var borderColor: UIColor!
    let restaurant: Restaurant
    
    init(frame: CGRect, borderColor: UIColor, restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(frame: frame)
        self.image = restaurant.getImage()
        self.borderColor = borderColor
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.restaurantLogoHeight)
        imageView.layer.cornerRadius = Constants.RestaurantListPage.restaurantLogoHeight / 2
        imageView.layer.borderColor = borderColor.cgColor
        imageView.layer.borderWidth = Constants.RestaurantListPage.restaurantLogoBorderWidth
        imageView.clipsToBounds = true
        
        let label = UILabel(frame: CGRect(x: 0, y: Constants.RestaurantListPage.restaurantLogoHeight * 0.97, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.restaurantLogoHeight * 0.03))
        label.text = "▼"
        label.textColor = borderColor
        label.textAlignment = .center
        
        self.addSubview(imageView)
        self.addSubview(label)
    }
}
