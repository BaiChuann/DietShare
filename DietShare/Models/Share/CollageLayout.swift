//
//  CollageLayout.swift
//  DietShare
//
//  Created by ZiyangMou on 6/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

struct CollageLayout {

    private let icon: UIImage?
    private let numberOfImages: Int
    private let format: [CGRect]

    init(icon: UIImage?, format: [CGRect]) {
        self.icon = icon
        self.format = format
        self.numberOfImages = format.count
    }

    var count: Int {
        return numberOfImages
    }

    var layoutFormat: [CGRect] {
        return format
    }

    var iconImage: UIImage? {
        return icon
    }

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
