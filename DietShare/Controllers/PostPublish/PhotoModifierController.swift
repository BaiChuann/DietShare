//
//  PhotoModifierController.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
// swiftlint:disable implicitly_unwrapped_optional

import UIKit
import DKImagePickerController

enum PhotoOptionType: Int {
    case sticker = 0, layout
}

class PhotoModifierController: UIViewController {
    @IBOutlet weak private var segmentControl: UISegmentedControl!
    @IBOutlet weak private var segmentIndicator: UIView!
    @IBOutlet weak private var photoOptionCollectionView: UICollectionView!
    @IBOutlet weak private var canvas: UIView!

    private let photoOptionCellIdentifier = "PhotoOptionCell"
    private let layoutPhotoSelectorIdentifier = "LayoutPhotoSelectorController"
    private var stickers = [UIImage?]()
    private var layout = [UIImage?]()
    private let storedLayout = StoredLayout.shared
    internal let storedSticker = StoredSticker.shared

    internal let tolerance: CGFloat = CGFloat(0.0001)

    var foodImage: UIImage?
    var selectedImages: [UIImage]?
    var selectedLayoutType: Int?

    var layoutPanGestureRecognizer: UIPanGestureRecognizer!
    var stickerPanGestureRecognizer: UIPanGestureRecognizer!
    var layoutLongPressGestureRecognizer: UILongPressGestureRecognizer!
    var movingImageView: UIView?
    var swappedImageView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpGestureRecogizer()
        setUpData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foodImage = UIImage(named: "food-example-1") /* this line is for testing purpose*/
        applyLayout()
    }

    private func setUpUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton

        segmentControl.backgroundColor = .clear
        segmentControl.tintColor = .clear
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: UIControlEvents.valueChanged)

        if let font = UIFont(name: Constants.fontRegular, size: 14) {
            segmentControl.setTitleTextAttributes([
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: Constants.normalTextColor
                ], for: .normal)
            segmentControl.setTitleTextAttributes([
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: Constants.themeColor
                ], for: .selected)
        }
    }

    private func setUpGestureRecogizer() {
        layoutPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        layoutPanGestureRecognizer.maximumNumberOfTouches = 1
        layoutPanGestureRecognizer.isEnabled = false
        layoutPanGestureRecognizer.delegate = self
        canvas.superview?.addGestureRecognizer(layoutPanGestureRecognizer)

        stickerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(sender:)))
        stickerPanGestureRecognizer.maximumNumberOfTouches = 1
        stickerPanGestureRecognizer.isEnabled = false
        stickerPanGestureRecognizer.delegate = self
        canvas.superview?.addGestureRecognizer(stickerPanGestureRecognizer)

        layoutLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        layoutLongPressGestureRecognizer.isEnabled = false
        layoutLongPressGestureRecognizer.minimumPressDuration = 0.5
        layoutLongPressGestureRecognizer.delegate = self
        canvas.superview?.addGestureRecognizer(layoutLongPressGestureRecognizer)
    }

    private func setUpData() {
        layout = storedLayout.storedLayoutList.map { $0.iconImage }
        stickers = storedSticker.storedLayoutList.map { $0.iconImage }
    }

    @objc
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.segmentIndicator.frame.origin.x = self.segmentControl.frame.origin.x + (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
        }

        photoOptionCollectionView.reloadData()
    }

    private func onLayoutSelected(index: Int) {
        selectedLayoutType = index
        print("selected layout \(index)")
        self.performSegue(withIdentifier: "toLayoutSelection", sender: nil)
    }

    private func onStickerSelected(index: Int) {
        print("selected sticker \(index)")
        reset()
        applySticker(index: index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLayoutSelection" {
            if let toViewController = segue.destination as? LayoutPhotoSelectorController {
                toViewController.layoutType = selectedLayoutType
            }
        }
    }

    private func reset() {
        let superView = canvas.superview
        superView?.subviews.filter { $0 !== canvas }.forEach { $0.removeFromSuperview() }
        superView?.gestureRecognizers?.forEach { $0.isEnabled = false }
    }
}

extension PhotoModifierController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoOptionCellIdentifier, for: indexPath)

        guard let photoOptionCell = cell as? PhotoOptionCell else {
            return cell
        }

        var optionImage: UIImage?

        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            optionImage = stickers[indexPath.item]
        case PhotoOptionType.layout.rawValue:
            optionImage = layout[indexPath.item]
        default:
            return cell
        }

        if let optionImage = optionImage {
            photoOptionCell.setOptionImage(optionImage)
        } else {
            photoOptionCell.clearImage()
        }

        return photoOptionCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            return stickers.count
        case PhotoOptionType.layout.rawValue:
            return layout.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item \(indexPath.item)")
        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            onStickerSelected(index: indexPath.item)
            return
        case PhotoOptionType.layout.rawValue:
            onLayoutSelected(index: indexPath.item)
        default:
            return
        }
    }
}

/// Extension for layout
extension PhotoModifierController {
    private func applyLayout() {
        guard let selectedImages = selectedImages, let layoutType = selectedLayoutType else {
            return
        }
        guard let layout = storedLayout.get(layoutType) else {
            return
        }
        let imageViews = layout.getLayoutViews(frame: canvas.frame)
        zip(imageViews, selectedImages).forEach { imageView, selectedImage in
            addImageAsSubview(image: selectedImage, container: imageView)
        }
        layoutPanGestureRecognizer.isEnabled = true
        layoutLongPressGestureRecognizer.isEnabled = false
    }

    // Add image to the container as subview, as add container as subview
    private func addImageAsSubview(image selectedImage: UIImage, container imageView: UIImageView) {
        imageView.clipsToBounds = true
        let subImageView = getFittedImageView(image: selectedImage, frame: imageView.frame)
        imageView.addSubview(subImageView)
        canvas.superview?.addSubview(imageView)
    }

    // Get a UIImageView with give image
    // Its frame will be fitted and centralized to the given frame
    private func getFittedImageView(image: UIImage, frame: CGRect) -> UIImageView {
        let originalSize = image.size
        let frameAspect = frame.width / frame.height
        let imageAspect = originalSize.width / originalSize.height
        var newSize: CGSize
        if frameAspect > imageAspect {
            newSize = CGSize(width: frame.width, height: frame.width / imageAspect)
        } else {
            newSize = CGSize(width: frame.height * imageAspect, height: frame.height)
        }
        let newX = (frame.width - newSize.width) / 2
        let newY = (frame.height - newSize.height) / 2
        let origin = CGPoint(x: newX, y: newY)
        let fittedFrame = CGRect(origin: origin, size: newSize)
        let imageView = UIImageView(frame: fittedFrame)
        imageView.image = image
        return imageView
    }
}


// Extension for sticker
extension PhotoModifierController {
    private func applySticker(index: Int) {
        guard let sticker = storedSticker.get(index) else {
            return
        }
        let imageFrame = sticker.getImageFrame(frame: canvas.frame)
        let stickerImageLayer = UIImageView(frame: imageFrame)
        
        addImageAsSubview(image: foodImage!, container: stickerImageLayer)
        addStickerAsSubview(sticker: sticker)
        
        stickerPanGestureRecognizer.isEnabled = true
    }
    
    private func addStickerAsSubview(sticker: StickerLayout) {
        let stickerLayer = UIImageView(frame: canvas.frame)
        stickerLayer.image = sticker.stickerImage
        canvas.superview?.addSubview(stickerLayer)
    }

}

extension PhotoModifierController {

    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        let location = sender.location(in: superView)

        if sender.state == .began {
            initializeMovingImageView(superView: superView, location: location)
        } else if sender.state == .changed {
            guard let movingImageView = movingImageView,
                let displayView = movingImageView.superview else {
                return
            }
            let translation = sender.translation(in: superView)
            sender.setTranslation(CGPoint.zero, in: superView)

            let currentView = getViewWithLocation(superView: superView, location: location)
            
            if swappedImageView != nil {
                if currentView === movingImageView {
                    swappedImageView = nil
                } else if currentView !== swappedImageView {
                    swappedImageView = currentView
                }
                print("swap")
            } else {
                let change = getCalculatedChange(view: movingImageView, displayView: displayView, translation: translation)

                if abs(change.x) < tolerance && abs(change.y) < tolerance,
                    currentView !== movingImageView {
                        swappedImageView = currentView
                }
                let newFrame = movingImageView.frame.offsetBy(dx: change.x, dy: change.y)
                movingImageView.frame = newFrame
                print("non-swap")
            }
        } else if sender.state == .ended {
            print("ended")
            guard let swappedImageView = swappedImageView else {
                movingImageView = nil
                return
            }
            let swappedImage = (swappedImageView as! UIImageView).image
            let movingImage = (movingImageView as! UIImageView).image
            let swappedImageSuperview = swappedImageView.superview
            let movingImageSuperview = movingImageView?.superview
            swappedImageView.removeFromSuperview()
            movingImageView?.removeFromSuperview()
            let newSwappedImageView = getFittedImageView(image: movingImage!, frame: (swappedImageSuperview?.frame)!)
            movingImageView = getFittedImageView(image: swappedImage!, frame: (movingImageSuperview?.frame)!)
            swappedImageSuperview?.addSubview(newSwappedImageView)
            movingImageSuperview?.addSubview(movingImageView!)

            movingImageView = nil
        }
    }

    private func initializeMovingImageView(superView: UIView?, location: CGPoint) {
        let movingView = getViewWithLocation(superView: superView, location: location)
        movingImageView = movingView
        swappedImageView = nil
    }
    
    private func getViewWithLocation(superView: UIView?, location: CGPoint) -> UIView? {
        return superView?.subviews.first { $0.frame.contains(location) && $0 !== canvas }?
            .subviews.first
    }

    private func swapImage(view1: UIImageView, view2: UIImageView) {
        guard let superView1 = view1.superview,
            let superView2 = view2.superview else {
                return
        }
        guard let image1 = view1.image, let image2 = view1.image else {
            return
        }
        view1.removeFromSuperview()
        view2.removeFromSuperview()
        let newView1 = getFittedImageView(image: image2, frame: superView1.frame)
        let newView2 = getFittedImageView(image: image1, frame: superView2.frame)
        superView1.addSubview(newView1)
        superView2.addSubview(newView2)
    }

    private func getCalculatedChange(view movingImageView: UIView,
                                     displayView: UIView,
                                     translation: CGPoint) -> (x: CGFloat, y: CGFloat) {
        var changeInX: CGFloat = 0
        var changeInY: CGFloat = 0
        if translation.x > 0 {
            changeInX = translation.x + movingImageView.frame.minX > 0 ?
                -movingImageView.frame.minX :
                translation.x
        } else {
            changeInX = translation.x + movingImageView.frame.maxX < displayView.frame.width ?
                displayView.frame.width - movingImageView.frame.maxX :
                translation.x
        }
        if translation.y > 0 {
            changeInY = translation.y + movingImageView.frame.minY > 0 ?
                -movingImageView.frame.minY :
                translation.y
        } else {
            changeInY = translation.y + movingImageView.frame.maxY < displayView.frame.height ?
                displayView.frame.height - movingImageView.frame.maxY :
                translation.y
        }
        return (changeInX, changeInY)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let superView = canvas.superview
        let location = sender.location(in: superView)
        let currentView = superView?.subviews.first {
            $0.frame.contains(location) && $0 !== canvas
        }?.subviews.first
        print("1")
        print(currentView === movingImageView)
    }


}

// Extension for sticker
extension PhotoModifierController {
    
    @objc private func handleStickerPan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        if sender.state == .began {
            let location = sender.location(in: superView)
            movingImageView = superView?.subviews.first {
                $0.frame.contains(location) && $0 !== canvas && !$0.subviews.isEmpty
                }?.subviews.first
        } else if sender.state == .changed {
            guard let movingImageView = movingImageView,
                let displayView = movingImageView.superview else {
                    return
            }
            let translation = sender.translation(in: superView)
            sender.setTranslation(CGPoint.zero, in: superView)
            var changeInX: CGFloat = 0
            var changeInY: CGFloat = 0
            if translation.x > 0 {
                changeInX = translation.x + movingImageView.frame.minX > 0 ?
                    -movingImageView.frame.minX :
                    translation.x
            } else {
                changeInX = translation.x + movingImageView.frame.maxX < displayView.frame.width ?
                    displayView.frame.width - movingImageView.frame.maxX :
                    translation.x
            }
            if translation.y > 0 {
                changeInY = translation.y + movingImageView.frame.minY > 0 ?
                    -movingImageView.frame.minY :
                    translation.y
            } else {
                changeInY = translation.y + movingImageView.frame.maxY < displayView.frame.height ?
                    displayView.frame.height - movingImageView.frame.maxY :
                    translation.y
            }
            let newFrame = movingImageView.frame.offsetBy(dx: changeInX, dy: changeInY)
            movingImageView.frame = newFrame
        } else if sender.state == .ended {
            print("ended")
            movingImageView = nil
        }
    }
}

extension PhotoModifierController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
