//
//  MapViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 16/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import MapKit
import BTree

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate {
    
    private let locationManager = CLLocationManager()
    private let currentLocationMarker = GMSMarker()
    private var chosenPlace: Place?
    private var selectedRestaurant: Restaurant?
    private var allRestaurants = [Restaurant]()
    
    // Current zoom of the map
    private var currentZoom = Float(Constants.MapPage.defaultZoom)
    
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    private let textFieldSearch: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.placeholder = "  Where do you want to go?"
        textField.adjustsFontSizeToFitWidth = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let myLocationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage( #imageLiteral(resourceName: "my-location"), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(myLocationTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage(#imageLiteral(resourceName: "cross-white"), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(unwindButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let searchAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("  Search in this Area   ", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.alpha = 0.8
        addRoundedRectBackground(button, 20, 1, UIColor.clear.cgColor, hexToUIColor(hex: "4c8bef"))
        button.addTarget(self, action: #selector(serachAgainButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var restaurantCell: RestaurantFullListCell = {
        let view = RestaurantFullListCell()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCoreLocationPermission()
        mapView.delegate = self
        initViews()
        initGoogleMaps()
        loadMarkers(Constants.MapPage.maxNumOfMarkers - Int(Constants.MapPage.defaultZoom))
        textFieldSearch.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var restaurants = [Restaurant]()
        RestaurantsModelManager.shared.getAllRestaurants().forEach { restaurants.append(Restaurant($0)) }
        self.allRestaurants = restaurants
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Iniitalize location manager
    private func requestCoreLocationPermission() {
        print("asking for location permission")
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    private func initViews() {
        self.view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 60).isActive = true
        
        self.view.addSubview(textFieldSearch)
        textFieldSearch.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        textFieldSearch.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 60).isActive = true
        textFieldSearch.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        textFieldSearch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addShadowToView(view: textFieldSearch, offset: 3, radius: 2)
        
        restaurantCell = RestaurantFullListCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        
        self.view.addSubview(myLocationButton)
        myLocationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        myLocationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        myLocationButton.heightAnchor.constraint(equalTo: myLocationButton.widthAnchor).isActive = true
        
        self.view.addSubview(searchAgainButton)
        searchAgainButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80).isActive = true
        searchAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchAgainButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor).isActive = true
        addShadowToView(view: closeButton, offset: 2, radius: 2)
    }

    private func setUpTextField(_ textField: UITextField, _ image: UIImage) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: textField.frame.height * 0.75, height: textField.frame.height * 0.75))
        imageView.image = image
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: textField.frame.height, height: textField.frame.height))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    // Initialize Google Map with a default zoom
    private func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 1.3494, longitude: 108.9323, zoom: Float(Constants.MapPage.defaultZoom))
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }
    
    // MARK: textfield handling
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        return false
    }
    
    // MARK: CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last!
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: Float(Constants.MapPage.defaultZoom))
        
        self.mapView.animate(to: camera)
    }
    
    // MARK: Google Map Delegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return false
        }
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), borderColor: UIColor.white, restaurant: customMarkerView.restaurant)
        marker.iconView = customMarker
        return false
    }
    
    // Renders the returned restaurant snippet view when the marker is tapped
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return nil
        }
        restaurantCell.initData(customMarkerView.restaurant)
        if let location = mapView.myLocation {
            let distance = getDistanceBetweenLocations(location, customMarkerView.restaurant.getLocation())
            restaurantCell.setDistance("\(distance) km")
        }
        restaurantCell.layer.masksToBounds = true
        return restaurantCell
    }
    
    // Upon tapping on the restaurant snippet, go to the detail page of the restaurant
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return
        }
        self.selectedRestaurant = customMarkerView.restaurant
        performSegue(withIdentifier: Identifiers.mapToRestaurant, sender: self)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return
        }
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), borderColor: UIColor.darkGray, restaurant: customMarkerView.restaurant)
        marker.iconView = customMarker
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: {
            self.searchAgainButton.alpha = 0.9
        })
    }
    
    // When search again button is clicked, load all markers in the current region again
    @objc func serachAgainButtonTapped() {
        self.loadMarkers(Constants.MapPage.maxNumOfMarkers - Int(self.mapView.camera.zoom))
        UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: {
            self.searchAgainButton.alpha = 0
        })
    }

    // MARK: Autocomplete logic handling
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: Float(Constants.MapPage.defaultZoom))
        mapView.camera = camera
        textFieldSearch.text = place.formattedAddress!
        loadMarkers(Constants.MapPage.maxNumOfMarkers - Int(camera.zoom))
        chosenPlace = Place(name: place.formattedAddress!, lattitude: lat, longitude: long)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(place.name)"
        marker.snippet = "\(place.formattedAddress!)"
        marker.map = mapView
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error autocomplete: \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Display all markers, ranked by the restaurant's rating, up to the provided limit of numbers within the current screen
    private func loadMarkers(_ numberLimit: Int) {
        mapView.clear()
        var count = 0
        for restaurant in self.allRestaurants {
            if count <= numberLimit && isCoordinateWithinScreen(restaurant.getLocation().coordinate) {
                let marker = GMSMarker()
                let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), borderColor: UIColor.darkGray, restaurant: restaurant)
                marker.iconView = customMarker
                marker.position = restaurant.getLocation().coordinate
                marker.map = self.mapView
                count += 1
            }
        }
    }
    
    private func isCoordinateWithinScreen(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let region = self.mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        return bounds.contains(coordinate)
    }

    // Move map to the current location of the user
    @objc func myLocationTapped() {
        if let location = mapView.myLocation {
            mapView.animate(toLocation: location.coordinate)
        }
    }
    
    @objc func unwindButtonTapped() {
        performSegue(withIdentifier: Identifiers.unwindMapToRestaurantList, sender: self)
    }
    
    func setRestaurants(_ restaurants: [Restaurant]) {
        self.allRestaurants = restaurants
    }
    
    @IBAction func unwindToMapView(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RestaurantViewController {
            dest.setRestaurant(self.selectedRestaurant)
            dest.enableUnwindButton()
            dest.tabBarController?.tabBar.isHidden = true
        }
    }
}
