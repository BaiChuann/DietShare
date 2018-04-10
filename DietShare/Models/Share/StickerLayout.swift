//
//  StickerLayout.swift
//  DietShare
//
//  Created by ZiyangMou on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class StickerLayout {
    
    private let image: UIImage?
    private let icon: UIImage?
    private let position: CGRect
    
    init(image: UIImage?, icon: UIImage?, position: CGRect) {
        self.image = image
        self.icon = icon
        self.position = position
    }

    var stickerImage: UIImage? {
        return image
    }

    var iconImage: UIImage? {
        return image
    }

    var imagePosition: CGRect {
        return position
    }

    func getImageFrame(frame: CGRect) -> CGRect {
        let width = frame.width
        let height = frame.height
        let view = CGRect(x: width * position.minX, y: height * position.minY,
                          width: width * position.width, height: height * position.height)
        return view
    }
}
