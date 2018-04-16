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

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate {
    
    let locationManager = CLLocationManager()
    let currentLocationMarker = GMSMarker()
    var chosenPlace: Place? = nil
    
    let mapDemoData = [(title: "Burger Shack", image: #imageLiteral(resourceName: "burger-shack")), (title: "Salad Heaven", image: #imageLiteral(resourceName: "vegie-bar"))]
    
    let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    let textFieldSearch: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.placeholder = "Where do you want to go?"
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let myLocationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage( #imageLiteral(resourceName: "my-location"), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(myLocationTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage(#imageLiteral(resourceName: "cross-white"), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(unwindButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var restaurantPreview: RestaurantPreview = {
        let view = RestaurantPreview()
        return view
    }()
    
    var restaurantCell: RestaurantFullListCell = {
       let view = RestaurantFullListCell()
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCoreLocationPermission()
        mapView.delegate = self
        initViews()
        initGoogleMaps()
        textFieldSearch.delegate = self
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
        textFieldSearch.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        textFieldSearch.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 50).isActive = true
        textFieldSearch.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        textFieldSearch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        setUpTextField(textFieldSearch, #imageLiteral(resourceName: "location"))
//        addShasowToView(view: textFieldSearch)
        
        restaurantPreview = RestaurantPreview(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        restaurantCell = RestaurantFullListCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        
        self.view.addSubview(myLocationButton)
        myLocationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        myLocationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        myLocationButton.heightAnchor.constraint(equalTo: myLocationButton.widthAnchor).isActive = true
        
        self.view.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalTo: myLocationButton.widthAnchor).isActive = true
    }
    
    private func setUpTextField(_ textField: UITextField, _ image: UIImage) {
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: textField.frame.height * 0.75 , height: textField.frame.height * 0.75))
        imageView.image = image
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: textField.frame.height, height: textField.frame.height))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    private func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 1.3494, longitude: 108.9323, zoom: 17.0)
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }

    
    //MARK: textfield handling
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        return false
    }
    
    //MARK: CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last!
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        
        showPartyMarker(lat: lat, long: long)
    }
    
    //MARK: Google Map Delegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return false
        }
        let image = customMarkerView.image
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), image: image!, borderColor: UIColor.white, tag: customMarkerView.tag)
        marker.iconView = customMarker
        return false
    }
    
    // Renders the returned restaurant snippet view when the marker is tapped
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return nil
        }
        //TODO - change to actual restaurant data
        let data = mapDemoData[customMarkerView.tag]
        restaurantPreview.setData(data.title, image: data.image)
//        return restaurantPreview
        restaurantCell.setName("Demo")
        restaurantCell.setImage(#imageLiteral(resourceName: "vegie-bar"))
        restaurantCell.setRating(4.0)
        return restaurantCell
    }
    
    // Upon tapping on the re
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return
        }
        let tag = customMarkerView.tag
        //TODO - implement segue here
        resturantTapped(tag)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else {
            return
        }
        let image = customMarkerView.image!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), image: image, borderColor: UIColor.darkGray, tag: customMarkerView.tag)
        marker.iconView = customMarker
    }

    //MARK: Autocomplete logic handling
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        showPartyMarker(lat: lat, long: long)
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        mapView.camera = camera
        textFieldSearch.text = place.formattedAddress!
        chosenPlace = Place(name: place.formattedAddress!, lattitude: lat, longitude: long)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(place.name)"
        marker.snippet = "\(String(describing: place.formattedAddress))"
        marker.map = mapView
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error autocomplete: \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showPartyMarker(lat: Double, long: Double) {
        print("show party marker called")
        mapView.clear()
        for i in 0..<2 {
            let marker = GMSMarker()
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: Constants.RestaurantListPage.restaurantLogoWidth, height: Constants.RestaurantListPage.locationMarkerHeight), image: mapDemoData[i].image, borderColor: UIColor.darkGray, tag: i)
            marker.iconView = customMarker
            let randNum = Double(arc4random_uniform(50) / 10000)
            let randInt = arc4random_uniform(4)
            switch randInt {
            case 0:
                marker.position = CLLocationCoordinate2D(latitude: lat + randNum, longitude: long + randNum)
            case 1:
                marker.position = CLLocationCoordinate2D(latitude: lat + randNum, longitude: long - randNum)
            case 2:
                marker.position = CLLocationCoordinate2D(latitude: lat - randNum, longitude: long + randNum)
            case 3:
                marker.position = CLLocationCoordinate2D(latitude: lat - randNum, longitude: long - randNum)
            default:
                break
            }
            print("marker position: \(marker.position)")
            marker.map = self.mapView
        }
    }
    
    @objc func resturantTapped(_ tag: Int) {
        
    }
    
    @objc func myLocationTapped() {
        if let location = mapView.myLocation {
            mapView.animate(toLocation: location.coordinate)
        }
    }
    
    @objc func unwindButtonTapped() {
        performSegue(withIdentifier: "unwindMapToRestaurantList", sender: self)
    }
    
}
