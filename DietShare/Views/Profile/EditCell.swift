//
//  EditCell.swift
//  DietShare
//
//  Created by baichuan on 13/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class EditCell: UITableViewCell {
    
    @IBOutlet weak private var attribute: UILabel!
    func setAttribute(_ name: String) {
        attribute.text = name
    }
}
