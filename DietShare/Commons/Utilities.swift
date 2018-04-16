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

func addShasowToView(view: UIView) {
    view.layer.shadowColor = UIColor.gray.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    view.layer.shadowRadius = 1
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

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension UIImage {
    func averageColor() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        let smallImage = resizeImage(image: self, targetSize: CGSize(width: 40, height: 40))
        if #available(iOS 9.0, *) {
            let context = CIContext()
            let inputImage = smallImage.ciImage ?? CIImage(cgImage: smallImage.cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrderMask.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = smallImage.cgImage ?? CIContext().createCGImage(smallImage.ciImage!, from: smallImage.ciImage!.extent)
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    
    func edgeColor() -> UIColor {
        return getMostColors(forEdge: true)
    }
    
    func mostColor() -> UIColor {
        return getMostColors(forEdge: false)
    }
    
    func getMostColors(forEdge:Bool) -> UIColor {
        let smallImage = resizeImage(image: self, targetSize: CGSize(width: 40, height: 40))
        let edgeWidth = 5
        let pixelData = smallImage.cgImage!.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let colors = NSCountedSet(capacity:Int(smallImage.size.width * smallImage.size.height))
        for x in 0...Int(smallImage.size.width) {
            for y in 0...Int(smallImage.size.height) {
                let pixelInfo: Int = ((Int(smallImage.size.width) * y) + x) * 4
                let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                if (x > edgeWidth && (x + edgeWidth) < Int(smallImage.size.width)) && (y > edgeWidth && (y + edgeWidth) < Int(smallImage.size.height)) && forEdge{
                    continue
                }
                colors.add(UIColor(red: b, green: g, blue: r, alpha: a))
            }
        }
        let enumerator =  colors.objectEnumerator()
        var mostColor = UIColor()
        var MaxCount = 0
        while let currrentColor = enumerator.nextObject() {
            let tmpCount =  colors.count(for: currrentColor)
            if tmpCount > MaxCount {
                MaxCount = tmpCount
                mostColor = currrentColor as! UIColor
            }
        }
        return mostColor
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(targetSize, hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
