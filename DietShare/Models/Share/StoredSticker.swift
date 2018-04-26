//
//  StoredSticker.swift
//  DietShare
//
//  Created by ZiyangMou on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class StoredSticker {
    static let shared = StoredSticker()
    private var storedLayout: [StickerLayout] = []
    var count: Int {
        return storedLayout.count
    }
    
    private init() {
        storedLayout.append(StickerLayout(image: UIImage(named: "image-placeholder"), position: CGRect.zero))
        
        let imageOne = UIImage(named: "sticker-1")
        let rectOne = CGRect(x: 0.1184, y: 0.4308, width: 0.6715, height: 0.5114)
        let stickerOne = StickerLayout(image: imageOne, position: rectOne)
        storedLayout.append(stickerOne)

        let imageTwo = UIImage(named: "sticker-2")
        let rectTwo = CGRect(x: 0.5483, y: 0.0946, width: 0.4517, height: 0.8511)
        let stickerTwo = StickerLayout(image: imageTwo, position: rectTwo)
        storedLayout.append(stickerTwo)

        let imageThree = UIImage(named: "sticker-3")
        let rectThree = CGRect(x: 0.1039, y: 0.1349, width: 0.5386, height: 0.6497)
        let stickerThree = StickerLayout(image: imageThree, position: rectThree)
        storedLayout.append(stickerThree)
    }
    
    func getSticker(_ index: Int) -> StickerLayout? {
        guard index < storedLayout.count else {
            return nil
        }
        return storedLayout[index]
    }

    func getStickerText(_ index: Int) -> String? {
        return index == 0 ? "No Sticker" : nil
    }
}
