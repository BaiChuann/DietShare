//
//  RestaurantListController.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation
import UIKit
import CoreLocation
import MapKit
import DropDown
import GoogleMaps
import GooglePlaces

class RestaurantListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    private var restaurantModel: RestaurantsModelManager<Restaurant>?
    private var selectedRestaurant: Restaurant?
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    private var currentSort = Sorting.byRating
    private var currentTypeFilters = Set<RestaurantType>()
    
    @IBOutlet weak var restaurantListView: UICollectionView!
    
    @IBOutlet var buttonBar: [UIButton]!
    @IBOutlet weak var ratingLogo: UIImageView!
    @IBOutlet weak var distanceLogo: UIImageView!
    private var cuisineDropDown = DropDown()
    @IBOutlet weak var mapButton: UIButton!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == restaurantListView, let model = self.restaurantModel, let location = self.currentLocation {
            return model.getFullRestaurantList(currentSort, currentTypeFilters, location).count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantFullListCell, for: indexPath as IndexPath) as! RestaurantFullListCell
        if let model = self.restaurantModel, let location = self.currentLocation {
            let restaurantList = model.getFullRestaurantList(currentSort, currentTypeFilters, location)
            cell.setImage(restaurantList[indexPath.item].getImage())
            cell.setName(restaurantList[indexPath.item].getName())
            cell.setRating(restaurantList[indexPath.item].getRatingScore())
            cell.setNumOfRating(restaurantList[indexPath.item].getRatingsID().getListAsSet().count)
            cell.setTypes(restaurantList[indexPath.item].getTypesAsStringSet())
            // Get current location
            if let location = self.currentLocation {
                let distance = Int(location.distance(from: restaurantList[indexPath.item].getLocation()) / 1000)
                cell.setDistance("\(distance) km")
            } else {
                cell.setDistance(Text.unknownDistance)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.restaurantModel, let location = self.currentLocation {
            let restaurantsList = model.getFullRestaurantList(currentSort, currentTypeFilters, location)
            self.selectedRestaurant = restaurantsList[indexPath.item]
            performSegue(withIdentifier: Identifiers.restaurantListToDetailPage, sender: self)
        }
    }
    
    func setModelManager(_ restaurantModel: RestaurantsModelManager<Restaurant>) {
        self.restaurantModel = restaurantModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.restaurantListView.reloadData()
        requestCoreLocationPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initView() {
        initDropDown()
        initMapButton()
    }
    
    private func initMapButton() {
        self.mapButton.layer.shadowColor = UIColor.black.cgColor
        self.mapButton.layer.shadowOpacity = 1
        self.mapButton.layer.shadowOffset = CGSize.zero
        self.mapButton.layer.shadowRadius = 10
//        self.mapButton.layer.shouldRasterize = true
    }
    
    private func initDropDown() {
        
        cuisineDropDown.anchorView = restaurantListView
        var allCuisineTypes = [String]()
        RestaurantType.cases().forEach {allCuisineTypes.append($0.rawValue)}
        assert(allCuisineTypes.count > 0)
        cuisineDropDown.dataSource = allCuisineTypes
        cuisineDropDown.width = self.view.frame.width
        DropDown.appearance().backgroundColor = UIColor.white
        
        cuisineDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            guard let typeSelected = RestaurantType(rawValue: item) else {
                fatalError("Illegal value of restaurant inputed")
            }
            if self.currentTypeFilters.contains(typeSelected) {
                self.currentTypeFilters.remove(typeSelected)
            } else {
                self.currentTypeFilters.insert(typeSelected)
            }
            self.restaurantListView.reloadData()
        }
        
        cuisineDropDown.willShowAction = { [unowned self] in
            
            self.cuisineDropDown.cellNib = UINib(nibName: "CuisineTypeCell", bundle: nil)
            self.cuisineDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? CuisineTypeCell else { return }
                guard let typeSelected = RestaurantType(rawValue: item) else {
                    fatalError("Illegal value of restaurant inputed")
                }
                if self.currentTypeFilters.contains(typeSelected) {
                    cell.optionLabel.textColor = Constants.themeColor
                    cell.tick.isHidden = false
                } else {
                    cell.optionLabel.textColor = UIColor.gray
                    cell.tick.isHidden = true
                }
            };
        }
        
        cuisineDropDown.dismissMode = .onTap
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
    
    @IBAction func showDropDown(_ sender: UIButton) {
        self.cuisineDropDown.show()
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
        //TODO - check if the following two lines break the location manager. if not, add them
//        locationManager.delegate = nil
//        locationManager.stopUpdatingLocation()
        currentLocation = manager.location
        self.restaurantListView.reloadData()
    }
    
    /**
     * Test functions
     */
    
    
}




