//
//  RestaurantViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {
    
    private var restaurant: Restaurant?
    var currentUser: User?
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet var currentRatingStars: [UIImageView]!
    @IBOutlet weak var numOfRatings: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var types: UILabel!
    @IBOutlet weak var restaurantDescription: UILabel!
    @IBOutlet weak var restaurantPhone: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var newRatingStars: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: Constants.RestaurantPage.longScrollViewHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initUser()
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     * View Related functions
     */
    
    private func initView() {
        print("InitView called")
        assert(self.restaurant != nil)
        if let currentRestaurant = self.restaurant {
            //TODO - combine the common parts between this page and restaurantFullListPage
            self.restaurantName.text = currentRestaurant.getName()
            self.restaurantImage.image = currentRestaurant.getImage()
            self.restaurantDescription.text = currentRestaurant.getDescription()
            self.numOfRatings.text = "\(currentRestaurant.getRatingsID().getListAsSet().count) ratings"
            //TODO - get current location
            self.distance.text = "\(0) km"
            self.restaurantPhone.text = currentRestaurant.getPhone()
            self.restaurantAddress.text = currentRestaurant.getAddress()
            self.setRating(currentRestaurant.getRatingScore())
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RestaurantListViewController {
            dest.currentUser = self.currentUser
        }
    }
    
    /**
     * Utility functions
     */
    
    func setRestaurant(_ restaurant: Restaurant?) {
        self.restaurant = restaurant
    }
    
    private func setRating(_ ratingScore: Double) {
        let roundedScore = Int(ratingScore)
        for i in 0..<roundedScore {
            currentRatingStars[i].image = #imageLiteral(resourceName: "star-filled")
        }
        
        let residual = ratingScore - Double(roundedScore)
        if residual >= 0.5 {
            currentRatingStars[roundedScore].image = #imageLiteral(resourceName: "star-half")
        } else if roundedScore < 5 {
            currentRatingStars[roundedScore].image = #imageLiteral(resourceName: "star-empty")
        }
        
        if roundedScore < 5 {
            for j in roundedScore + 1..<5 {
                currentRatingStars[j].image = #imageLiteral(resourceName: "star-empty")
            }
        }
    }
    
    /**
     * Test functions
     */
    private func initUser() {
        self.currentUser = User(userId: "1", name: "James", password: "0909", photo: #imageLiteral(resourceName: "vegi-life"))
    }
    
}

