//
//  Utilities.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

func setUpInputBorder(for inputs: [UITextField]) {
    inputs.forEach {
        let border = CALayer()
        let width = CGFloat(1)
        let inputHeight = inputs[0].frame.size.height
        let inputWidth = inputs[0].frame.size.width
        border.borderColor = UIColor(red:1.00, green:0.84, blue:0.28, alpha:1.0).cgColor
        border.frame = CGRect(x: 0, y: inputHeight - width, width: inputWidth, height: inputHeight)
        border.borderWidth = width
        $0.layer.addSublayer(border)
        $0.layer.masksToBounds = true
    }
}
