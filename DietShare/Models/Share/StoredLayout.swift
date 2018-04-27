//
//  CollageLayout.swift
//  DietShare
//
//  Created by ZiyangMou on 3/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.

import Foundation
import UIKit

class StoredLayout {
    static let shared = StoredLayout()
    private var storedLayout: [CollageLayout] = []
    var count: Int {
        return storedLayout.count
    }
    
    private init() {
        storedLayout.append(CollageLayout(icon: UIImage(named: "image-placeholder"), format: [CGRect.zero]))
        
        let formatOne = [CGRect(x: 0.0, y: 0.0, width: 0.35, height: 1.0),
                                  CGRect(x: 0.35, y: 0.0, width: 0.65, height: 0.5),
                                  CGRect(x: 0.35, y: 0.5, width: 0.65, height: 0.5)]
        let iconOne: UIImage? = UIImage(named: "layout-1")
        let storedLayoutOne = CollageLayout(icon: iconOne, format: formatOne)
        storedLayout.append(storedLayoutOne)
        
        let formatTwo = [CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.3333),
                                 CGRect(x: 0.0, y: 0.3333, width: 1, height: 0.3334),
                                 CGRect(x: 0.0, y: 0.6667, width: 1, height: 0.3333)]
        let iconTwo: UIImage? = UIImage(named: "layout-2")
        let storedLayoutTwo = CollageLayout(icon: iconTwo, format: formatTwo)
        storedLayout.append(storedLayoutTwo)
        
        let formatThree = [CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.35),
                                 CGRect(x: 0.0, y: 0.35, width: 0.5, height: 0.65),
                                 CGRect(x: 0.5, y: 0.35, width: 0.5, height: 0.65)]
        let iconThree: UIImage? = UIImage(named: "layout-3")
        let storedLayoutThree = CollageLayout(icon: iconThree, format: formatThree)
        storedLayout.append(storedLayoutThree)
        
        let formatFour = [CGRect(x: 0.0, y: 0.0, width: 0.5, height: 0.5),
                                   CGRect(x: 0.5, y: 0.0, width: 0.5, height: 0.5),
                                   CGRect(x: 0.0, y: 0.5, width: 0.5, height: 0.5),
                                   CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)]
        let iconFour: UIImage? = UIImage(named: "layout-4")
        let storedLayoutFour = CollageLayout(icon: iconFour, format: formatFour)
        storedLayout.append(storedLayoutFour)
    }
    
    func getLayout(_ index: Int) -> CollageLayout? {
        guard index < storedLayout.count else {
            return nil
        }
        return storedLayout[index]
    }

    func getLayoutText(_ index: Int) -> String? {
        return index == 0 ? "No Layout" : nil
    }
}
