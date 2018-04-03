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

// Crops an image to the given bounds
func cropToBounds(_ image: UIImage, _ width: Double, _ height: Double) -> UIImage {
    
    let contextSize: CGSize = image.size
    
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef = image.cgImage?.cropping(to: rect)
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}

// Crops an image to circular
func makeRoundImg(img: UIImageView) -> UIImageView {
    let imgLayer = CALayer()
    imgLayer.frame = img.bounds
    imgLayer.contents = img.image?.cgImage;
    imgLayer.masksToBounds = true;
    
    imgLayer.cornerRadius = img.frame.width / 2
    
    UIGraphicsBeginImageContext(img.bounds.size)
    imgLayer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIImageView(image: roundedImage);
}

// Adds a rounded rectangular background to a UIView
func addRoundedRectBackground(_ view: UIView, _ radius: CGFloat, _ borderWidth: CGFloat, _ borderColor: CGColor, _ backgroundColor: UIColor) {
    view.backgroundColor = backgroundColor
    view.layer.cornerRadius = radius
    view.layer.borderWidth = borderWidth
    view.layer.borderColor = borderColor
    view.clipsToBounds = true
}
