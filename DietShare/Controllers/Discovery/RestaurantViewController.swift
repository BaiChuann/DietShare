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
    @IBOutlet weak var restaurantDescription: UITextView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if let currentRestaurant = self.restaurant {
            self.restaurantName.text = currentRestaurant.getName()
            addRoundedRectBackground(self.restaurantName, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
            self.restaurantImage.image = currentRestaurant.getImage()
            self.restaurantImage.alpha = CGFloat(Constants.RestaurantPage.restaurantImageAlpha)
            self.restaurantDescription.text = currentRestaurant.getDescription()
        }
        
        addRoundedRectBackground(self.followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.white.cgColor, UIColor.clear)
        
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
    
    /**
     * Test functions
     */
    private func initUser() {
        self.currentUser = User(userId: "1", name: "James", password: "0909", photo: #imageLiteral(resourceName: "vegi-life"))
    }
    
}

