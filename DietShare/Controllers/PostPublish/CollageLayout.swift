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

struct CollageLayoutThree: CollageLayout {
    var layoutNumber: Int = 3
    var numberOfImages: Int = 4
    var layoutFormat: [CGRect] = [CGRect(x: 0.0, y: 0.0, width: 0.5, height: 0.5),
                                  CGRect(x: 0.5, y: 0.0, width: 0.5, height: 0.5),
                                  CGRect(x: 0.0, y: 0.5, width: 0.5, height: 0.5),
                                  CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)]
}
