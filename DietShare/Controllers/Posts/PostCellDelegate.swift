//
//  PostCellDelegate.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func goToDetail(_ post: String, _ session: Int)
    func goToUser(_ id: String)
    func onCommentClicked(_ postId: String)
    func updateCell()
    func goToRestaurant(_ id: String)
    func goToTopic(_ id: String)
}
