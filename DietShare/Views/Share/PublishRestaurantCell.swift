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
    @IBOutlet private(set) var label: UILabel!
    
    func setLabelText(text: String) {
        label.text = text
    }
}
