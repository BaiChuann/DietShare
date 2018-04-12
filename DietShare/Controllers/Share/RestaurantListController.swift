//
//  RestaurantListController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class RestaurantListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private var restaurantModel: RestaurantsModelManager<Restaurant>?

    private var restaurants: [PublishRestaurant] = []
    private var filteredRestaurants: [PublishRestaurant] = []
    private var isSearching = false

    private let publishRestaurantIdentifier = "PublishRestaurantCell"
    private let searchBarPlaceHolder = "Search your restaurant here ..."
    
    weak var delegate: RestaurantSenderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setUpSearchBar()
        loadRestaurantData()
    }

    private func setUpTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = searchBarPlaceHolder
    }

    private func loadRestaurantData() {
        restaurants = [PublishRestaurant(id: "1", name: "r1", address: "221B Baker Street"),
                       PublishRestaurant(id: "2", name: "c1", address: "221B Baker Street"),
                       PublishRestaurant(id: "3", name: "g4", address: "221B Baker Street"),
                       PublishRestaurant(id: "4", name: "hello", address: "221B Baker Street"),
                       PublishRestaurant(id: "5", name: "science", address: "221B Baker Street"),
                       PublishRestaurant(id: "6", name: "computing", address: "221B Baker Street"),
                       PublishRestaurant(id: "7", name: "home", address: "221B Baker Street"),
                       PublishRestaurant(id: "8", name: "3217", address: "221B Baker Street"),
                       PublishRestaurant(id: "9", name: "lol", address: "221B Baker Street"),
                       PublishRestaurant(id: "10", name: "pwn", address: "221B Baker Street"),
                       PublishRestaurant(id: "11", name: "cd", address: "221B Baker Street"),
        ]
    }
}

extension RestaurantListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredRestaurants.count
        }
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: publishRestaurantIdentifier, for: indexPath)
        guard let restaurantCell = cell as? PublishRestaurantCell else {
            return cell
        }
        let restaurant = isSearching ?
            filteredRestaurants[indexPath.item] :
            restaurants[indexPath.item]
        restaurantCell.setLabelText(name: restaurant.name, address: restaurant.address)
        return restaurantCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = isSearching ?
            filteredRestaurants[indexPath.item] :
            restaurants[indexPath.item]
        delegate?.sendRestaurant(restaurant: (restaurant.id, restaurant.name))
        navigationController?.popViewController(animated: false)
    }
}

extension RestaurantListController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            filteredRestaurants = restaurants.filter { restaurant in
                filterText(pattern: searchText, original: restaurant.name)
            }
        }
        tableView.reloadData()
    }

    private func filterText(pattern: String, original: String) -> Bool {
        guard pattern.count <= original.count else {
            return false
        }
        let lowerPattern = pattern.lowercased()
        let lowerOriginal = original.lowercased()
        return lowerOriginal.range(of: lowerPattern) != nil
    }
}

private class PublishRestaurant {
    
    private(set) var id: String
    private(set) var name: String
    private(set) var address: String
    
    init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}
