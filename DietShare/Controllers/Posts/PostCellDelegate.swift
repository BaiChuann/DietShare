//
//  PostCellDelegate.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func goToDetail(_ post: PostCell)
    func goToUser(_ id: String)
    func onCommentClicked(_ postId: String)
}
