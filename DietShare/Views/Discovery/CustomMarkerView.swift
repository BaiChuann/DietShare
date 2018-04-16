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
    
    init(frame: CGRect, image: UIImage, borderColor: UIColor, tag: Int) {
        super.init(frame: frame)
        self.image = image
        self.borderColor = borderColor
        self.tag = tag
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
        
        let label = UILabel(frame: CGRect(x: 0, y: Constants.RestaurantListPage.restaurantLogoHeight * 0.9, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.restaurantLogoHeight * 0.1))
        label.text = "label"
        label.textColor = borderColor
        label.textAlignment = .center
        
        self.addSubview(imageView)
        self.addSubview(label)
    }
}
