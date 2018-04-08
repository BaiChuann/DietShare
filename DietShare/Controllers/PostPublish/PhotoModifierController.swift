//
//  PhotoModifierController.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
// swiftlint:disable implicitly_unwrapped_optional force_unwrapping


import UIKit
import DKImagePickerController

protocol PhotoModifierDelegate: class {
    func importImagesForLayout(images: [UIImage], layoutIndex: Int)
    func getLayoutImageCount(index: Int) -> Int
}

enum PhotoOptionType: Int {
    case sticker = 0, layout, filter
}

class PhotoModifierController: UIViewController {
    @IBOutlet weak private var segmentControl: UISegmentedControl!
    @IBOutlet weak private var segmentIndicator: UIView!
    @IBOutlet weak private var photoOptionCollectionView: UICollectionView!
    @IBOutlet weak private var canvas: UIImageView!
    @IBOutlet weak private var spacingConstraint: NSLayoutConstraint!

    var originalPhoto = UIImage(named: "food-example-1")
    private let photoOptionCellIdentifier = "PhotoOptionCell"
    private let layoutPhotoSelectorIdentifier = "LayoutPhotoSelectorController"
    private let context = CIContext()
    private var stickerIcons = [UIImage?]()
    private var layoutIcons = [UIImage?]()
    private var filters = [(String, String)]()

    private let storedLayout = StoredLayout.shared
    private let storedSticker = StoredSticker.shared

    private let tolerance: CGFloat = CGFloat(0.000_1)
    private let swappingAlpha: CGFloat = 0.6
    private let stickerTag = 99
    private let collageTag = 100

    private var selectedImages: [UIImage]?

    private var layoutPanGestureRecognizer: UIPanGestureRecognizer!
    private var stickerPanGestureRecognizer: UIPanGestureRecognizer!
    private var layoutLongPressGestureRecognizer: UILongPressGestureRecognizer!

    private var movingImageView: UIView?
    private var swappedImageView: UIView?

    private var selectedLayoutIndex: Int = -1
    private var selectedFilterIndex: Int = -1

    private let optionCellMaxHeight: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        canvas.image = originalPhoto
        setUpUI()
        setUpGestureRecogizer()
        setUpData()

        filters = [
        ("Normal", "No Filter"),
        ("Chrome", "CIPhotoEffectChrome"),
        ("Fade", "CIPhotoEffectFade"),
        ("Instant", "CIPhotoEffectInstant"),
        ("Mono", "CIPhotoEffectMono"),
        ("Noir", "CIPhotoEffectNoir"),
        ("Process", "CIPhotoEffectProcess"),
        ("Tonal", "CIPhotoEffectTonal"),
        ("Transfer", "CIPhotoEffectTransfer"),
        ("Tone", "CILinearToSRGBToneCurve"),
        ("Linear", "CISRGBToneCurveToLinear")
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyLayout()
    }

    override func viewWillLayoutSubviews() {
        if photoOptionCollectionView.bounds.height < optionCellMaxHeight {
            spacingConstraint.constant = 0
            photoOptionCollectionView.reloadData()
        }
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
        layoutIcons = storedLayout.storedLayoutList.map { $0.iconImage }
        stickerIcons = storedSticker.storedLayoutList.map { $0.iconImage }
    }

    @objc
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.segmentIndicator.frame.origin.x = self.segmentControl.frame.origin.x + (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
        }

        photoOptionCollectionView.reloadData()
    }

    private func onLayoutSelected(index: Int) {

        guard let photoSelector = AppStoryboard.share.instance.instantiateViewController(withIdentifier: layoutPhotoSelectorIdentifier) as? LayoutPhotoSelectorController else {
            print("error when showing layout photo selector")
            return
        }

        photoSelector.delegate = self
        photoSelector.layoutIndex = index
        navigationController?.present(photoSelector, animated: true, completion: nil)
    }

    private func onStickerSelected(index: Int) {
        print("selected sticker \(index)")
        reset()
        applySticker(index: index)
    }

    private func onFilterSelected(index: Int) {
        let curIndexPath = IndexPath(item: index, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedFilterIndex, 0), section: 0)
        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)

        selectedFilterIndex = index
        if index > 0 {
            let filterName = filters[selectedFilterIndex].1
            canvas.image = getFilteredImage(filter: filterName)
        }
    }

    private func updateCellSelectionStatus(curAt indexPath: IndexPath, prevAt: IndexPath) {
        guard let curCell = photoOptionCollectionView.cellForItem(at: indexPath) as? PhotoOptionCell,
            let prevCell = photoOptionCollectionView.cellForItem(at: prevAt) as? PhotoOptionCell else {
                return
        }

        curCell.isSelected = true
        prevCell.isSelected = false
    }

    private func getFilteredImage(filter: String) -> UIImage {
        guard let image = originalPhoto, let filter = CIFilter(name: filter) else {
            print("current photo or filter is nil")
            return UIImage()
        }

        let sourceImage = CIImage(image: image)
        filter.setDefaults()
        filter.setValue(sourceImage, forKey: kCIInputImageKey)

        guard let filteredImage = filter.outputImage,
            let outputCGImage = context.createCGImage(filteredImage, from: filteredImage.extent) else {
                print("error when applying filter to image")
                return UIImage()
        }

        return UIImage(cgImage: outputCGImage)
    }

    private func reset() {
        let superView = canvas.superview
        superView?.subviews.filter { $0.tag == collageTag || $0.tag == stickerTag }
            .forEach { $0.removeFromSuperview() }
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
        var labelText: String?

        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            optionImage = stickerIcons[indexPath.item]
        case PhotoOptionType.layout.rawValue:
            optionImage = layoutIcons[indexPath.item]
            photoOptionCell.isSelected = indexPath.item == selectedLayoutIndex
        case PhotoOptionType.filter.rawValue:
            optionImage = indexPath.item > 0 ? getFilteredImage(filter: filters[indexPath.item].1) : originalPhoto
            photoOptionCell.isSelected = indexPath.item == selectedFilterIndex
            labelText = filters[indexPath.item].0
        default:
            return cell
        }

        photoOptionCell.setLabelText(labelText)
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
            return stickerIcons.count
        case PhotoOptionType.layout.rawValue:
            return layoutIcons.count
        case PhotoOptionType.filter.rawValue:
            return filters.count
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
        case PhotoOptionType.filter.rawValue:
            onFilterSelected(index: indexPath.item)
        default:
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 20
        let size = min(optionCellMaxHeight, photoOptionCollectionView.frame.height - inset)
        return CGSize(width: size, height: size + inset)
    }
}

/// Extension for layout and stickre
extension PhotoModifierController {

    // Apply layout selected
    private func applyLayout() {
        reset()
        guard let selectedImages = selectedImages, let layout = storedLayout.get(selectedLayoutIndex) else {
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

        addImageAsSubview(image: originalPhoto!, container: stickerImageLayer)
        addStickerAsSubview(sticker: sticker)

        stickerPanGestureRecognizer.isEnabled = true
    }

    // Add sticker image as image subview
    private func addStickerAsSubview(sticker: StickerLayout) {
        let stickerLayer = UIImageView(frame: canvas.frame)
        stickerLayer.image = sticker.stickerImage
        stickerLayer.tag = stickerTag
        canvas.superview?.addSubview(stickerLayer)
    }

    // Add image to the container as subview, as add container as subview
    private func addImageAsSubview(image selectedImage: UIImage, container imageView: UIImageView) {
        imageView.clipsToBounds = true
        let subImageView = getFittedImageView(image: selectedImage, frame: imageView.frame)
        imageView.addSubview(subImageView)
        imageView.tag = collageTag
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

    // Set border for a view
    private func setBorder(view: inout UIView?, width: CGFloat, color: UIColor) {
        guard let view = view else {
            return
        }
        view.layer.borderWidth = width
        view.layer.borderColor = color.cgColor
    }

    // Unset border for a view
    private func unsetBorder(view: inout UIView?) {
        guard let view = view else {
            return
        }
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
                    unsetBorder(view: &swappedSuperview)
                    movingImageView.alpha = 1
                } else if currentView !== swappedImageView {
                    unsetBorder(view: &swappedSuperview)
                    swappedImageView = currentView
                    setBorder(view: &currentSuperview, width: 3, color: .blue)
                }
                return
            }

            let change = getCalculatedChange(view: movingImageView, displayView: displayView, translation: translation)

            if abs(change.x) < tolerance && abs(change.y) < tolerance,
                currentView !== movingImageView {
                swappedImageView = currentView
                setBorder(view: &currentSuperview, width: 3, color: .blue)
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
                unsetBorder(view: &swappedSuperview)
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
        return superView?.subviews.first { $0.tag == collageTag && $0.frame.contains(location) }?
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

extension PhotoModifierController: PhotoModifierDelegate {
    func getLayoutImageCount(index: Int) -> Int {
        if let count = storedLayout.get(index)?.count {
            return count
        } else {
            return 0
        }
    }

    func importImagesForLayout(images: [UIImage], layoutIndex: Int) {
        selectedImages = images
        selectedLayoutIndex = layoutIndex
        let curIndexPath = IndexPath(item: layoutIndex, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedFilterIndex, 0), section: 0)
        selectedLayoutIndex = layoutIndex

        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)
        applyLayout()
    }
}
