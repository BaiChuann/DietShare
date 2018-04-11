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
    
    private var restaurants: [String] = []
    private var filteredRestaurants: [String] = []
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
        restaurants = ["A", "B", "C", "D"]
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
        print(cell)
        guard let restaurantCell = cell as? PublishRestaurantCell else {
            return cell
        }
        let labelText = isSearching ?
            filteredRestaurants[indexPath.item] :
            restaurants[indexPath.item]
        restaurantCell.setLabelText(text: labelText)
        return restaurantCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurantName = isSearching ?
            filteredRestaurants[indexPath.item] :
            restaurants[indexPath.item]
        delegate?.sendRestaurant(name: restaurantName)
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
            filteredRestaurants = restaurants.filter { name in
                filterText(pattern: searchText, original: name)
            }
        }
        tableView.reloadData()
    }

    func filterText(pattern: String, original: String) -> Bool {
        guard pattern.count <= original.count else {
            return false
        }
        let lowerPattern = pattern.lowercased()
        let lowerOriginal = original.lowercased()
        return lowerOriginal.range(of: lowerPattern) != nil
    }
}
