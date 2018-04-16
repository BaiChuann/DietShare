//
//  RestaurantPreview.swift
//  DietShare
//
//  Created by Shuang Yang on 16/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class RestaurantPreview: UIView {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        initViews()
    }
    
    func setData(_ name: String, image: UIImage) {
        self.imageView.image = image
        self.name.text = name
    }
    
    private func initViews() {
        
        Bundle.main.loadNibNamed("RestaurantPreview", owner: self, options: nil)
        addSubview(containerView)
        
        addRoundedRectBackground(name, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
}
