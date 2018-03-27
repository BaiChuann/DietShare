//
//  Utilities.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

func addInputBorder(for inputs: [UITextField], withColor color: UIColor) {

    inputs.forEach {
        let border = CALayer()
        let width = CGFloat(1)
        let inputHeight = inputs[0].frame.size.height
        let inputWidth = inputs[0].frame.size.width
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: inputHeight - width, width: inputWidth, height: inputHeight)
        border.borderWidth = width
        $0.layer.addSublayer(border)
        $0.layer.masksToBounds = true
    }
}

func hexToUIColor(hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
        cString.remove(at: cString.startIndex)
    }

    if cString.count != 6 {
        return UIColor.gray
    }

    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
