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
    
    private init() {
        let iconZero = UIImage(named: "sticker-icon-1")
        let imageZero = UIImage(named: "sticker-1")
        let rectZero = CGRect(x: 0.1184, y: 0.4308, width: 0.6715, height: 0.5114)
        let stickerZero = StickerLayout(image: imageZero, icon: iconZero, position: rectZero)
        storedLayout.append(stickerZero)

        let iconOne = UIImage(named: "sticker-icon-2")
        let imageOne = UIImage(named: "sticker-2")
        let rectOne = CGRect(x: 0.5483, y: 0.0946, width: 0.4517, height: 0.8511)
        let stickerOne = StickerLayout(image: imageOne, icon: iconOne, position: rectOne)
        storedLayout.append(stickerOne)
        
        let iconTwo = UIImage(named: "sticker-icon-3")
        let imageTwo = UIImage(named: "sticker-3")
        let rectTwo = CGRect(x: 0.1039, y: 0.1349, width: 0.5386, height: 0.6497)
        let stickerTwo = StickerLayout(image: imageTwo, icon: iconTwo, position: rectTwo)
        storedLayout.append(stickerTwo)
    }
    
    var storedLayoutList: [StickerLayout] {
        return storedLayout
    }
    
    func get(_ index: Int) -> StickerLayout? {
        guard index < storedLayout.count else {
            return nil
        }
        return storedLayout[index]
    }
    
}
