//
//  CollageLayout.swift
//  DietShare
//
//  Created by ZiyangMou on 3/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

protocol CollageLayout {
    var layoutNumber: Int { get }
    var numberOfImages: Int { get }
    var layoutFormat: [CGRect] { get }
    
    func getLayoutViews(frame: CGRect) -> [UIImageView]
}

extension CollageLayout {
    func getLayoutViews(frame: CGRect) -> [UIImageView] {
        let width = frame.width
        let height = frame.height
        let views = layoutFormat.map { format in
            CGRect(x: width * format.minX, y: height * format.minY,
                              width: width * format.width, height: height * format.height)
        }.map { UIImageView(frame: $0) }
        return views
    }
}

struct CollageLayoutZero: CollageLayout {
    var layoutNumber: Int = 0
    var numberOfImages: Int = 3
    var layoutFormat: [CGRect] = [CGRect(x: 0.0, y: 0.0, width: 0.35, height: 1.0),
                                  CGRect(x: 0.35, y: 0.0, width: 0.65, height: 0.5),
                                  CGRect(x: 0.35, y: 0.5, width: 0.65, height: 0.5)]
}

struct CollageLayoutOne: CollageLayout {
    var layoutNumber: Int = 1
    var numberOfImages: Int = 3
    var layoutFormat: [CGRect] = [CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.333),
                                  CGRect(x: 0.0, y: 0.333, width: 1.0, height: 0.334),
                                  CGRect(x: 0.0, y: 0.667, width: 1.0, height: 0.333)]
}

struct CollageLayoutTwo: CollageLayout {
    var layoutNumber: Int = 2
    var numberOfImages: Int = 3
    var layoutFormat: [CGRect] = [CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.35),
                                  CGRect(x: 0.0, y: 0.35, width: 0.5, height: 0.65),
                                  CGRect(x: 0.5, y: 0.35, width: 0.5, height: 0.65)]
}

struct CollageLayoutThree: CollageLayout {
    var layoutNumber: Int = 3
    var numberOfImages: Int = 4
    var layoutFormat: [CGRect] = [CGRect(x: 0.0, y: 0.0, width: 0.5, height: 0.5),
                                  CGRect(x: 0.5, y: 0.0, width: 0.5, height: 0.5),
                                  CGRect(x: 0.0, y: 0.5, width: 0.5, height: 0.5),
                                  CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)]
}

