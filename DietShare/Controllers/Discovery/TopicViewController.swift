//
//  TopicViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var topic: Topic?
    
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicDescription: UITextView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var activeUsers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.TopicPage.numOfDisplayedUsers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.activeUserListCell, for: indexPath as! IndexPath) as! ActiveUserListCell
        return cell
    }
    
    /**
     * View Related functions
     */
    
    private func initView() {
        print("InitView called")
        if let currentTopic = self.topic {
            self.topicName.text = currentTopic.getName()
            addRoundedRectBackground(self.topicName, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
            self.topicImage.image = currentTopic.getImage()
            self.topicImage.alpha = CGFloat(Constants.TopicPage.topicImageAlpha)
            self.topicDescription.text = currentTopic.getDescription()
        }
        
        addRoundedRectBackground(self.followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.white.cgColor, UIColor.clear)
    }
    
    
    /**
     * Utility functions
     */
    
    func setTopic(_ topic: Topic?) {
        self.topic = topic
    }
}
