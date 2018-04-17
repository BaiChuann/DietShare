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

class RestaurantViewController: UIViewController, UIScrollViewDelegate {
    
    private var restaurant: Restaurant?
    private var locationManager = CLLocationManager()
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
    
    @IBOutlet weak var postsArea: UIView!
    private var postsTable: UITableView!
    private var postsTableController: PostsTableController?
    
    @IBOutlet weak var postAreaHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        requestCoreLocationPermission()

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initView()
        initPosts()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
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
        if let currentRestaurant = self.restaurant, let currentUser = UserModelManager.shared.getCurrentUser() {
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
            if let rating = currentRestaurant.getUserRating(currentUser) {
                self.rateRestaurantLabel.text = Text.yourRating
                setNewRating(rating.getScore())
            }
        }
        
    }
    
    
    private func initPosts() {
        if let postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as? PostsTableController {
            postsTableController.setParentController(self)
            if let restaurant = self.restaurant {
                postsTableController.getRestaurantPosts(restaurant.getID())
            }
            self.addChildViewController(postsTableController)
            
            postsTableController.setScrollDelegate(self)
            postsTable = postsTableController.getTable()
            postAreaHeight.constant = postsTable.contentSize.height
            postsTableController.view.frame.size = postsArea.frame.size
            postsArea.addSubview(postsTableController.view)
            postsTable.bounces = false
            postsTable.isScrollEnabled = false
        }
    }
    
    
    // Hide navigation bar when scrolling up
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y > 0) {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }
    
    @IBOutlet weak var rateRestaurantLabel: UILabel!
    @IBOutlet var newRatings: [UIButton]!
    
    @IBAction func ratingTapped(_ sender: UIButton) {
        let ratingScore = sender.tag
        assert(ratingScore <= 5)
        self.setNewRating(ratingScore)
        if let user = UserModelManager.shared.getCurrentUser(), let restaurant = self.restaurant,
            let score = RatingScore(rawValue: ratingScore) {
            let rating = Rating(user.getUserId(), restaurant.getID(), score)
            restaurant.addRating(rating)
        }
        
    }
    
    private func setNewRating(_ score: Int) {
        assert(score <= 5)
        for i in 0..<5 {
            if i < score {
                UIView.animate(withDuration: Constants.ratingAnimationDuration, animations: {
                    self.newRatings[i].alpha = 0
                    self.newRatings[i].setBackgroundImage(#imageLiteral(resourceName: "star-filled"), for: .normal)
                    self.newRatings[i].alpha = 1
                })
            } else {
                self.newRatings[i].setBackgroundImage(#imageLiteral(resourceName: "star-empty"), for: .normal)
            }
        }
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
    
    func enableUnwindButton() {
        let closeButton = UIButton()
        closeButton.backgroundColor = UIColor.clear
        closeButton.setImage(#imageLiteral(resourceName: "cross-white"), for: .normal)
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(unwindButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor).isActive = true
        addShadowToView(view: closeButton, offset: 0.5, radius: 0.5)
    }
    
    @objc func unwindButtonTapped() {
        performSegue(withIdentifier: Identifiers.unwindRestaurantToMap, sender: self)
    }
    
    /**
     * Test functions
     */
}

extension RestaurantViewController: CLLocationManagerDelegate {
    
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
    }
}


extension RestaurantViewController: ScrollDelegate {
    func didScroll() {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0)
//        {
//            if yOffset >= scrollView.contentSize.height - postsTable.frame.height {
//                scrollView.isScrollEnabled = false
//                postsTable.isScrollEnabled = true
//            }
//
//        }
    }
    func reachTop() {
//        scrollView.isScrollEnabled = true
//        postsTable.isScrollEnabled = false
    }
}
