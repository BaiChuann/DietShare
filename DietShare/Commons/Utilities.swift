//
//  Utilities.swift
//  DietShare
//
//  Created by Fan Weiguang on 18/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import CoreLocation

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

// Returns UIColor from hex string
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

// Convert an UIView into UIImage
func getImageFromView(_ view: UIView, cropToSquare: Bool = false) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    defer { UIGraphicsEndImageContext() }
    var resultImage: UIImage? = nil

    if let context = UIGraphicsGetCurrentContext() {
        view.layer.render(in: context)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    if !cropToSquare {
        return resultImage
    }

    if let image = resultImage {
        return cropsToSquareImage(image)
    }

    return nil
}

func getFittedImageView(image: UIImage, frame: CGRect) -> UIImageView {
    let originalSize = image.size
    let frameAspect = frame.width / frame.height
    let imageAspect = originalSize.width / originalSize.height
    var newSize: CGSize
    if frameAspect > imageAspect {
        newSize = CGSize(width: frame.width, height: frame.width / imageAspect)
    } else {
        newSize = CGSize(width: frame.height * imageAspect, height: frame.height)
    }
    let newX = (frame.width - newSize.width) / 2
    let newY = (frame.height - newSize.height) / 2
    let origin = CGPoint(x: newX, y: newY)
    let fittedFrame = CGRect(origin: origin, size: newSize)
    let imageView = UIImageView(frame: fittedFrame)
    imageView.image = image
    return imageView
}

func setFittedImageAsSubview(view: UIView, image: UIImage, alpha: CGFloat) {
    let subview = getFittedImageView(image: image, frame: view.frame)
    subview.alpha = alpha
    view.addSubview(subview)
    view.clipsToBounds = true
}

func cropsToSquareImage(_ image: UIImage) -> UIImage? {
    let size = image.size.width
    let rect = CGRect(x: 0, y: 0, width: size, height: size)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
    let origin = CGPoint(x: rect.origin.x * CGFloat(-1), y: rect.origin.y * CGFloat(-1))
    image.draw(at: origin)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return result
}

// Crops an image to the given bounds
func cropToBounds(_ image: UIImage, _ width: Double, _ height: Double) -> UIImage {

    let contextSize: CGSize = image.size

    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth = CGFloat(width)
    var cgheight = CGFloat(height)

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

    let rect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

    // Create bitmap image from context using the rect
    let imageRef = image.cgImage?.cropping(to: rect)

    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)

    return image
}

func addShadowToView(view: UIView, offset: CGFloat, radius: CGFloat) {
    view.layer.shadowColor = UIColor.gray.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize(width: offset, height: offset)
    view.layer.shadowRadius = radius
}

// Crops an image to circular
func makeRoundImg(img: UIImageView) -> UIImageView {
    let imgLayer = CALayer()
    imgLayer.frame = img.bounds
    imgLayer.contents = img.image?.cgImage
    imgLayer.masksToBounds = true
    imgLayer.cornerRadius = img.frame.width / 2

    UIGraphicsBeginImageContext(img.bounds.size)
    imgLayer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIImageView(image: roundedImage)
}

// Adds a rounded rectangular background to a UIView
func addRoundedRectBackground(_ view: UIView, _ radius: CGFloat, _ borderWidth: CGFloat, _ borderColor: CGColor, _ backgroundColor: UIColor) {
    view.backgroundColor = backgroundColor
    view.layer.cornerRadius = radius
    view.layer.borderWidth = borderWidth
    view.layer.borderColor = borderColor
    view.clipsToBounds = true
}

func getDistanceBetweenLocations(_ locationA: CLLocation, _ locationB: CLLocation) -> Int {
    return Int(locationA.distance(from: locationB) / 1000)
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension UIColor {
    // Compares with another color and returns the result
    func equals(_ rhs: UIColor) -> Bool {
        var lhsR: CGFloat = 0
        var lhsG: CGFloat = 0
        var lhsB: CGFloat = 0
        var lhsA: CGFloat = 0
        self.getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)

        var rhsR: CGFloat = 0
        var rhsG: CGFloat = 0
        var rhsB: CGFloat = 0
        var rhsA: CGFloat = 0
        rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)

        return  lhsR == rhsR &&
            lhsG == rhsG &&
            lhsB == rhsB &&
            lhsA == rhsA
    }
}

extension UIImage {
    // Get a tinted image with color
    func tinted(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self

        }
        guard let cgImage = cgImage else {
            return self
        }

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        context.setBlendMode(.multiply)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()

        return newImage
    }
}
