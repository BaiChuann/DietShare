//
//  RestaurantListController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import DropDown

class RestaurantListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    private var restaurantModel: RestaurantsModelManager<Restaurant>?
    private var selectedRestaurant: Restaurant?
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    private var currentSort = Sorting.byRating
    
    @IBOutlet weak var restaurantListView: UICollectionView!
    
    @IBOutlet var buttonBar: [UIButton]!
    @IBOutlet weak var ratingLogo: UIImageView!
    @IBOutlet weak var distanceLogo: UIImageView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == restaurantListView, let model = self.restaurantModel {
            return model.getNumOfRestaurants()
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantFullListCell, for: indexPath as IndexPath) as! RestaurantFullListCell
        if let model = self.restaurantModel {
            let restaurantList = model.getFullRestaurantList(currentSort)
            cell.setImage(restaurantList[indexPath.item].getImage())
            cell.setName(restaurantList[indexPath.item].getName())
            cell.setRating(restaurantList[indexPath.item].getRatingScore())
            cell.setNumOfRating(restaurantList[indexPath.item].getRatingsID().getListAsSet().count)
            // TODO - get current location
            if let location = self.currentLocation {
                let distance = Int(location.distance(from: restaurantList[indexPath.item].getLocation()) / 1000)
                cell.setDistance("\(distance) km")
            } else {
                cell.setDistance("unknown distance")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.restaurantModel {
            let restaurantsList = model.getFullRestaurantList(currentSort)
            self.selectedRestaurant = restaurantsList[indexPath.item]
            performSegue(withIdentifier: Identifiers.restaurantListToDetailPage, sender: self)
        }
    }
    
    func setModelManager(_ restaurantModel: RestaurantsModelManager<Restaurant>) {
        self.restaurantModel = restaurantModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initUser()
        self.restaurantListView.reloadData()
        requestCoreLocationPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RestaurantViewController {
            dest.setRestaurant(self.selectedRestaurant)
        }
    }
    
    /**
     * Handle user action (sorting and filtering)
     */
    @IBAction func sortByRatingButtonClicked(_ sender: UIButton) {
        self.currentSort = .byRating
        self.ratingLogo.image = #imageLiteral(resourceName: "sort-highlighted")
        self.distanceLogo.image = #imageLiteral(resourceName: "sort-normal")
        restaurantListView.reloadData()
    }
    
    @IBAction func sortByDistanceButtonClicked(_ sender: UIButton) {
        self.currentSort = .byDistance
        self.ratingLogo.image = #imageLiteral(resourceName: "sort-normal")
        self.distanceLogo.image = #imageLiteral(resourceName: "sort-highlighted")
        restaurantListView.reloadData()
    }
    
    
    /**
     * View-related functions
     */
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }
    
    
    /**
     * Utility functions
     */
    private func requestCoreLocationPermission() {
        print("asking for location permission")
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
//        self.restaurantListView.reloadData()
    }
    
    /**
     * Test functions
     */
    
    
}


