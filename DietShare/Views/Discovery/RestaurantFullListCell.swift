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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak private var restaurantImage: UIImageView!
    @IBOutlet weak private var restaurantName: UILabel!
    @IBOutlet weak var restaurantType: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    convenience init(_ frame: CGRect, _ restaurant: Restaurant) {
        self.init(frame: frame)
        initViews()
        initData(restaurant)
    }
    
    private func initViews() {
        Bundle.main.loadNibNamed("RestaurantFullListCell", owner: self, options: nil)
        addSubview(containerView)
    }
    
    func initData(_ restaurant: Restaurant) {
        setImage(restaurant.getImage())
        setName(restaurant.getName())
        setNumOfRating(restaurant.getRatingsID().getListAsSet().count)
        setRating(restaurant.getRatingScore())
        setTypes(restaurant.getTypesAsStringSet())
    }
    
    func setImage(_ image: UIImage) {
        restaurantImage.image = image
//        restaurantImage.layer.cornerRadius = Constants.cornerRadius
        addRoundedRectBackground(restaurantImage, Constants.defaultCornerRadius, 0, UIColor.clear.cgColor, UIColor.clear)
    }
    
    func setName(_ name: String) {
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
    
    func setDistance(_ distance: String) {
        self.distance.text = distance
    }
    
    func setTypes(_ types: Set<String>) {
        var typeString = ""
        types.forEach { typeString += "\($0)  " }
        self.restaurantType.text = typeString
    }
    
}
