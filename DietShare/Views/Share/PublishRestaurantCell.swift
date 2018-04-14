//
//  RestaurentCell.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class PublishRestaurantCell: UITableViewCell {
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var addressLabel: UILabel!
    
    func setLabelText(name: String, address: String) {
        nameLabel.text = name
        addressLabel.text = address
    }
}
