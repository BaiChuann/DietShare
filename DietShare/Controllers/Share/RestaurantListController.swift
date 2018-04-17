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

    private var restaurantDataSource: RestaurantsDataSource = RestaurantsLocalDataSource.shared

    private var restaurants: [PublishRestaurant] = []
    private var filteredRestaurants: [PublishRestaurant] = []
    private var isSearching = false
    private var defaultRestaurant = PublishRestaurant(id: "-1", name: "Hide location", address: "")

    private let publishRestaurantIdentifier = "PublishRestaurantCell"
    private let searchBarPlaceHolder = "Search your restaurant here ..."

    weak var delegate: RestaurantSenderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTable()
        setUpSearchBar()
        loadRestaurantData()
    }

    private func setUpUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
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
        restaurants = restaurantDataSource.getAllRestaurants()
            .map { toPublishRestaurant(restaurant: $0) }
        restaurants.insert(defaultRestaurant, at: 0)
    }

    private func toPublishRestaurant(restaurant: Restaurant) -> PublishRestaurant {
        let id = restaurant.getID()
        let name = restaurant.getName()
        let address = restaurant.getAddress()
        return PublishRestaurant(id: id, name: name, address: address)
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
        navigationController?.popViewController(animated: true)
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
