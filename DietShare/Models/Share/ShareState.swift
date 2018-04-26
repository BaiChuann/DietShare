//
//  ShareState.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

/*
 Stores the state that is going to be passed around in all view controllers in Share component.
 It stores the original photo taken/selected by user, food info for the picture and the modified picture
 after filter/layout/sticker/text.
 */
class ShareState {
    var originalPhoto: UIImage?
    var food: Food?
    var modifiedPhoto: UIImage?
}
