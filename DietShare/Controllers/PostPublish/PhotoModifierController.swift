//
//  PhotoModifierController.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

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
    private let storedSticker = StoredSticker.shared

    private let tolerance: CGFloat = CGFloat(0.000_1)
    private let swappingAlpha: CGFloat = 0.6

    private var foodImage: UIImage?
    private var selectedImages: [UIImage]?
    private var selectedLayoutType: Int?

    private var layoutPanGestureRecognizer: UIPanGestureRecognizer!
    private var stickerPanGestureRecognizer: UIPanGestureRecognizer!
    private var layoutLongPressGestureRecognizer: UILongPressGestureRecognizer!

    private var movingImageView: UIView?
    private var swappedImageView: UIView?

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
        layoutPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleLayoutPan(sender:)))
        layoutPanGestureRecognizer.maximumNumberOfTouches = 1
        layoutPanGestureRecognizer.isEnabled = false
        canvas.superview?.addGestureRecognizer(layoutPanGestureRecognizer)

        stickerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(sender:)))
        stickerPanGestureRecognizer.maximumNumberOfTouches = 1
        stickerPanGestureRecognizer.isEnabled = false
        canvas.superview?.addGestureRecognizer(stickerPanGestureRecognizer)

        layoutLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        layoutLongPressGestureRecognizer.isEnabled = false
        layoutLongPressGestureRecognizer.minimumPressDuration = 0.5
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

/// Extension for layout and stickre
extension PhotoModifierController {

    // Apply layout selected
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

    // Apply sticker selected
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

    // Add sticker image as image subview
    private func addStickerAsSubview(sticker: StickerLayout) {
        let stickerLayer = UIImageView(frame: canvas.frame)
        stickerLayer.image = sticker.stickerImage
        canvas.superview?.addSubview(stickerLayer)
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

    private func setBorder(view: inout UIView, width: CGFloat, color: UIColor) {
        view.layer.borderWidth = width
        view.layer.borderColor = color.cgColor
    }

    private func unsetBorder(view: inout UIView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = nil
    }
}

// Extension for handler of gestures
extension PhotoModifierController {

    @objc private func handleLayoutPan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        let location = sender.location(in: superView)

        switch sender.state {
        case .began:
            movingImageView = getViewWithLocation(superView: superView, location: location)

        case .changed:
            guard let movingImageView = movingImageView,
                let displayView = movingImageView.superview else {
                    return
            }

            let translation = sender.translation(in: superView)
            sender.setTranslation(CGPoint.zero, in: superView)

            let currentView = getViewWithLocation(superView: superView, location: location)
            var currentSuperview = currentView?.superview

            guard swappedImageView == nil else {
                var swappedSuperview = swappedImageView?.superview

                if currentView === movingImageView {
                    swappedImageView = nil
                    unsetBorder(view: &swappedSuperview!)
                    movingImageView.alpha = 1
                } else if currentView !== swappedImageView {
                    unsetBorder(view: &swappedSuperview!)
                    swappedImageView = currentView
                    setBorder(view: &currentSuperview!, width: 3, color: .blue)
                }
                return
            }

            let change = getCalculatedChange(view: movingImageView, displayView: displayView, translation: translation)

            if abs(change.x) < tolerance && abs(change.y) < tolerance,
                currentView !== movingImageView {
                swappedImageView = currentView
                setBorder(view: &currentSuperview!, width: 3, color: .blue)
                movingImageView.alpha = swappingAlpha
            }

            let newFrame = movingImageView.frame.offsetBy(dx: change.x, dy: change.y)
            movingImageView.frame = newFrame

        case .ended:
            if swappedImageView != nil {
                var swappedSuperview = swappedImageView?.superview

                movingImageView?.alpha = 1
                swapImage(view1: movingImageView as! UIImageView,
                          view2: swappedImageView as! UIImageView)
                unsetBorder(view: &swappedSuperview!)
                print("swap")
            }

            swappedImageView = nil
            movingImageView = nil

        default:
            return
        }
    }

    @objc private func handleStickerPan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        let location = sender.location(in: superView)

        switch sender.state {
        case .began:
            movingImageView = getViewWithLocation(superView: superView, location: location)

        case .changed:
            guard let movingImageView = movingImageView,
                let displayView = movingImageView.superview else {
                    return
            }

            let translation = sender.translation(in: superView)
            sender.setTranslation(CGPoint.zero, in: superView)

            let change = getCalculatedChange(view: movingImageView, displayView: displayView, translation: translation)
            let newFrame = movingImageView.frame.offsetBy(dx: change.x, dy: change.y)
            movingImageView.frame = newFrame

        case .ended:
            movingImageView = nil
            swappedImageView = nil

        default:
            return
        }
    }

    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        // TODO: maybe add long press gesture to flip image
    }
}

// Extension of helper function of gesture handlers
extension PhotoModifierController {

    // Get a view with a location
    private func getViewWithLocation(superView: UIView?, location: CGPoint) -> UIView? {
        return superView?.subviews.first { $0.frame.contains(location) && $0 !== canvas }?
            .subviews.first
    }

    // Swap two images from two ImageViews, then scale them to fit
    private func swapImage(view1: UIImageView, view2: UIImageView) {
        guard let superView1 = view1.superview, let superView2 = view2.superview else {
            return
        }
        guard let image1 = view1.image, let image2 = view2.image else {
            return
        }
        view1.removeFromSuperview()
        view2.removeFromSuperview()
        let newView1 = getFittedImageView(image: image2, frame: superView1.frame)
        let newView2 = getFittedImageView(image: image1, frame: superView2.frame)
        superView1.addSubview(newView1)
        superView2.addSubview(newView2)
    }

    // Calculate actual change should be applied on the view based on displayView
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
}
