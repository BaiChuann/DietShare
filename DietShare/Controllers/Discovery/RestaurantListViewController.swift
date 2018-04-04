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

class RestaurantListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var restaurantModel: RestaurantsModelManager<Restaurant>?
    private var selectedRestaurant: Restaurant?
    var currentUser: User?
    
    @IBOutlet weak var restaurantListView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == restaurantListView {
            return Constants.defaultListDisplayCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantFullListCell, for: indexPath as IndexPath) as! RestaurantFullListCell
        if let model = self.restaurantModel {
            let restaurantList = model.getFullRestaurantList()
            cell.setImage(restaurantList[indexPath.item].getImage())
            cell.setName(restaurantList[indexPath.item].getName())
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.restaurantModel {
            let restaurantsList = model.getFullRestaurantList()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RestaurantViewController {
            dest.setRestaurant(self.selectedRestaurant)
            dest.currentUser = self.currentUser
        }
    }
    
    /**
     * Test functions
     */
    // TODO - change to actual user manager when user manager is available
    private func initUser() {
        self.currentUser = User(userId: "1", name: "James", password: "0909", photo: #imageLiteral(resourceName: "vegi-life"))
    }
    
}


