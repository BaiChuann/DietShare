//
//  RestaurantViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RestaurantViewController: UIViewController {
    
    private var restaurant: Restaurant?
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet var currentRatingStars: [UIImageView]!
    @IBOutlet weak var numOfRatings: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var types: UILabel!
    @IBOutlet weak var restaurantDescription: UILabel!
    @IBOutlet weak var restaurantPhone: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    
    @IBOutlet weak var ratingArea: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: Constants.RestaurantPage.longScrollViewHeight)
        
//        initRatingStars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            self.types.text = currentRestaurant.getTypesAsString()
            self.numOfRatings.text = "\(currentRestaurant.getRatingsID().getListAsSet().count) ratings"
            if let location = self.currentLocation {
                let distance = Int(location.distance(from: currentRestaurant.getLocation()) / 1000)
                self.distance.text = "\(distance) km"
            } else {
                self.distance.text = Text.unknownDistance
            }
            self.restaurantPhone.text = currentRestaurant.getPhone()
            self.restaurantAddress.text = currentRestaurant.getAddress()
            self.setRating(currentRestaurant.getRatingScore())
        }
        
    }
    
    @IBOutlet var newRatings: [UIButton]!
    
    @IBAction func ratingTapped(_ sender: UIButton) {
        let ratingScore = sender.tag
        UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: {
            for i in 0..<5 {
                if i < ratingScore {
                    self.newRatings[i].setBackgroundImage(#imageLiteral(resourceName: "star-filled"), for: .normal)
                } else {
                    self.newRatings[i].setBackgroundImage(#imageLiteral(resourceName: "star-empty"), for: .normal)
                }
            }
            })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RestaurantListViewController {
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
    
    func setLocationManager(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    /**
     * Test functions
     */
}

extension RestaurantViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
    }
}

