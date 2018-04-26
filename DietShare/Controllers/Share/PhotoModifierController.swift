//
//  PhotoModifierController.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.

import UIKit
import DKImagePickerController

/*
 A delegate for PhotoModifierController that allows import images for photo layout.
 */
protocol PhotoModifierDelegate: class {
    func importImagesForLayout(images: [UIImage], layoutIndex: Int)
    func getLayoutImageCount(index: Int) -> Int
}

enum PhotoOptionType: Int {
    case sticker = 0, layout, filter
}

/*
 A view controller for the page where user can modify the photo with sticker/layout/filter.
 */
class PhotoModifierController: UIViewController {
    @IBOutlet weak private var segmentControl: UISegmentedControl!
    @IBOutlet weak private var segmentIndicator: UIView!
    @IBOutlet weak private var photoOptionCollectionView: UICollectionView!
    @IBOutlet weak private var canvas: UIView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var spacingConstraint: NSLayoutConstraint!

    var shareState: ShareState?
    private let photoOptionCellIdentifier = "PhotoOptionCell"
    private let layoutPhotoSelectorIdentifier = "LayoutPhotoSelectorController"
    private let context = CIContext()
    private var isShowingNutrition = true

    private let storedLayout = StoredLayout.shared
    private let storedSticker = StoredSticker.shared
    private let storedFilter = StoredFilter.shared

    private let tolerance: CGFloat = CGFloat(0.000_1)
    private let swappingAlpha: CGFloat = 0.6

    private var layoutPanGestureRecognizer: UIPanGestureRecognizer?
    private var stickerPanGestureRecognizer: UIPanGestureRecognizer?
    private var layoutLongPressGestureRecognizer: UILongPressGestureRecognizer?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?

    private var movingImageView: UIView?
    private var swappedImageView: UIView?
    private var addedImageViews = [UIImageView]()

    private var selectedImages = [UIImage]()
    private var selectedStickerIndex: Int = 0
    private var selectedLayoutIndex: Int = 0
    private var selectedFilterIndex: Int = 0

    private let optionCellMaxHeight: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpGestureRecogizer()
    }

    override func viewWillLayoutSubviews() {
        if photoOptionCollectionView.bounds.height < optionCellMaxHeight {
            spacingConstraint.constant = 0
            photoOptionCollectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if selectedLayoutIndex > 0 {
            applyLayout(index: selectedLayoutIndex)
        }

        if selectedStickerIndex > 0 {
            applySticker(index: selectedStickerIndex)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFloatingContentAdder" {
            if let destinationVC = segue.destination as? FloatingContentAdderController {
                shareState?.modifiedPhoto = getImageFromView(canvas, cropToSquare: true)
                destinationVC.shareState = shareState
            }
        }
    }

    private func setUpUI() {
        imageView.image = shareState?.originalPhoto

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
        stickerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(sender:)))
        layoutLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))

        guard let layoutPanGR = layoutPanGestureRecognizer,
            let stickerPanGR = stickerPanGestureRecognizer,
            let layoutLongPressGR = layoutLongPressGestureRecognizer,
            let pinchGR = pinchGestureRecognizer else {
                return
        }

        layoutPanGR.maximumNumberOfTouches = 1
        layoutPanGR.isEnabled = false
        canvas.addGestureRecognizer(layoutPanGR)

        stickerPanGR.maximumNumberOfTouches = 1
        stickerPanGR.isEnabled = false
        canvas.addGestureRecognizer(stickerPanGR)

        layoutLongPressGR.isEnabled = false
        layoutLongPressGR.minimumPressDuration = 0.5
        canvas.addGestureRecognizer(layoutLongPressGR)

        pinchGR.isEnabled = false
        canvas.addGestureRecognizer(pinchGR)
    }

    @objc
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.segmentIndicator.frame.origin.x = self.segmentControl.frame.origin.x + (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
        }

        photoOptionCollectionView.reloadData()
    }

    private func onStickerSelected(index: Int) {
        applySticker(index: index)

        let curIndexPath = IndexPath(item: index, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedStickerIndex, 0), section: 0)
        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)
        selectedStickerIndex = index
        selectedLayoutIndex = 0
    }

    private func onLayoutSelected(index: Int) {
        if index == 0 {
            resetCanvas()

            let currentIndex = IndexPath(item: index, section: 0)
            let previousIndex = IndexPath(item: selectedLayoutIndex, section: 0)
            selectedLayoutIndex = index
            updateCellSelectionStatus(curAt: currentIndex, prevAt: previousIndex)

            return
        }

        guard let photoSelector = AppStoryboard.share.instance.instantiateViewController(withIdentifier: layoutPhotoSelectorIdentifier) as? LayoutPhotoSelectorController else {
            print("error when showing layout photo selector")
            return
        }

        photoSelector.delegate = self
        photoSelector.layoutIndex = index
        navigationController?.present(photoSelector, animated: true, completion: nil)
    }

    private func onFilterSelected(index: Int) {
        guard let originalPhoto = shareState?.originalPhoto else {
            return
        }

        let curIndexPath = IndexPath(item: index, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedFilterIndex, 0), section: 0)
        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)

        selectedFilterIndex = index
        imageView.image = getFilteredImage(originalPhoto, filterIndex: selectedFilterIndex)

        if selectedStickerIndex > 0 {
            updateStickerWithFilter()
        }

        if selectedLayoutIndex > 0 {
            updateLayoutWithFilter()
        }
    }

    private func updateCellSelectionStatus(curAt: IndexPath, prevAt: IndexPath) {
        guard let curCell = photoOptionCollectionView.cellForItem(at: curAt) as? PhotoOptionCell else {
            return
        }

        curCell.setSelected(true)
        if prevAt.item != curAt.item,
            let prevCell = photoOptionCollectionView.cellForItem(at: prevAt) as? PhotoOptionCell {
            prevCell.setSelected(false)
        }
    }

    private func getFilteredImage(_ image: UIImage, filterIndex: Int) -> UIImage {
        if filterIndex <= 0 {
            return image
        }

        let filterName = storedFilter.getFilterName(filterIndex)
        guard let filter = CIFilter(name: filterName) else {
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

    private func resetCanvas() {
        let superView = imageView.superview
        addedImageViews.forEach { $0.removeFromSuperview() }
        superView?.gestureRecognizers?.forEach { $0.isEnabled = false }
        addedImageViews.removeAll()
    }
}

extension PhotoModifierController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoOptionCellIdentifier, for: indexPath)

        guard let photoOptionCell = cell as? PhotoOptionCell,
            let originalPhoto = shareState?.originalPhoto else {
            return cell
        }

        var optionImage: UIImage?
        var labelText: String?

        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            optionImage = storedSticker.getSticker(indexPath.item)?.stickerImage
            photoOptionCell.setSelected(indexPath.item == selectedStickerIndex)
            labelText = storedSticker.getStickerText(indexPath.item)
        case PhotoOptionType.layout.rawValue:
            optionImage = storedLayout.getLayout(indexPath.item)?.iconImage
            photoOptionCell.setSelected(indexPath.item == selectedLayoutIndex)
            labelText = storedLayout.getLayoutText(indexPath.item)
        case PhotoOptionType.filter.rawValue:
            optionImage = indexPath.item > 0 ? getFilteredImage(originalPhoto, filterIndex: indexPath.item) : shareState?.originalPhoto
            photoOptionCell.setSelected(indexPath.item == selectedFilterIndex)
            labelText = storedFilter.getFilterText(indexPath.item)
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
            return storedSticker.count
        case PhotoOptionType.layout.rawValue:
            return storedLayout.count
        case PhotoOptionType.filter.rawValue:
            return storedFilter.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch segmentControl.selectedSegmentIndex {
        case PhotoOptionType.sticker.rawValue:
            onStickerSelected(index: indexPath.item)
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

/// Extension for layout and sticker
extension PhotoModifierController {

    // Apply layout selected
    private func applyLayout(index: Int) {
        resetCanvas()

        guard let layout = storedLayout.getLayout(index) else {
            return
        }

        let imageViews = layout.getLayoutViews(frame: imageView.frame)
        zip(imageViews, selectedImages).forEach { imageView, selectedImage in
            addImageAsSubview(image: getFilteredImage(selectedImage, filterIndex: selectedFilterIndex), container: imageView)
        }

        layoutPanGestureRecognizer?.isEnabled = true
        layoutLongPressGestureRecognizer?.isEnabled = false
        pinchGestureRecognizer?.isEnabled = true
    }

    private func updateLayoutWithFilter() {
        let count = selectedImages.count

        for i in 0..<count {
            guard let subview = addedImageViews[i].subviews.first as? UIImageView else {
                continue
            }

            let originalImage = selectedImages[i]
            subview.image = getFilteredImage(originalImage, filterIndex: selectedFilterIndex)
        }
    }

    // Apply sticker selected
    private func applySticker(index: Int) {
        resetCanvas()

        if index == 0 {
            return
        }

        guard let originalPhoto = shareState?.originalPhoto, let sticker = storedSticker.getSticker(index) else {
            return
        }

        var filteredImage = shareState?.originalPhoto
        if selectedFilterIndex > 0 {
            filteredImage = getFilteredImage(originalPhoto, filterIndex: selectedFilterIndex)
        }

        guard let baseImage = filteredImage else {
            return
        }

        let imageFrame = sticker.getImageFrame(frame: imageView.frame)
        let stickerImageLayer = UIImageView(frame: imageFrame)

        addImageAsSubview(image: baseImage, container: stickerImageLayer)
        addStickerAsSubview(sticker: sticker)

        stickerPanGestureRecognizer?.isEnabled = true
        pinchGestureRecognizer?.isEnabled = true
    }

    private func updateStickerWithFilter() {
        guard let imageView = addedImageViews.first?.subviews.first as? UIImageView,
            let originalPhoto = shareState?.originalPhoto else {
            return
        }

        imageView.image = getFilteredImage(originalPhoto, filterIndex: selectedFilterIndex)
    }

    // Add sticker image as image subview
    private func addStickerAsSubview(sticker: StickerLayout) {
        let stickerLayer = UIImageView(frame: imageView.frame)
        stickerLayer.image = sticker.stickerImage
        canvas.addSubview(stickerLayer)
        addedImageViews.append(stickerLayer)
    }

    // Add image to the container as subview, as add container as subview
    private func addImageAsSubview(image selectedImage: UIImage, container imageView: UIImageView) {
        imageView.clipsToBounds = true
        let subImageView = getFittedImageView(image: selectedImage, frame: imageView.frame)
        imageView.addSubview(subImageView)
        canvas.addSubview(imageView)
        addedImageViews.append(imageView)
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
        
        UIView.animate(withDuration: 0.3) {
            view.layer.borderWidth = width
            view.layer.borderColor = color.cgColor
        }
    }

    // Unset border for a view
    private func unsetBorder(view: inout UIView?) {
        guard let view = view else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            view.layer.borderWidth = 0
            view.layer.borderColor = nil
        }
    }
}

// Extension for handler of gestures
extension PhotoModifierController {

    @objc
    private func handleLayoutPan(sender: UIPanGestureRecognizer) {
        let superView = imageView.superview
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

            guard swappedImageView == nil,
                imageView.frame.contains(location) else {
                var swappedSuperview = swappedImageView?.superview

                if currentView === movingImageView {
                    swappedImageView = nil
                    unsetBorder(view: &swappedSuperview)
                    movingImageView.alpha = 1
                } else if currentView !== swappedImageView {
                    unsetBorder(view: &swappedSuperview)
                    swappedImageView = currentView
                    setBorder(view: &currentSuperview, width: 3, color: Constants.themeColor)
                }
                return
            }

            let change = getCalculatedChange(view: movingImageView, displayView: displayView, translation: translation)

            if abs(change.x) < tolerance && abs(change.y) < tolerance,
                currentView !== movingImageView,
                imageView.frame.contains(location) {
                swappedImageView = currentView
                setBorder(view: &currentSuperview, width: 3, color: Constants.themeColor)
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

    @objc
    private func handleStickerPan(sender: UIPanGestureRecognizer) {
        let superView = imageView.superview
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

    @objc
    private func handleLongPress(sender: UILongPressGestureRecognizer) {
        // TODO: maybe add long press gesture to flip image
    }

    @objc
    private func handlePinch(sender: UIPinchGestureRecognizer) {
        let superView = imageView.superview
        let location = sender.location(in: superView)

        switch sender.state {
        case .began:
            movingImageView = getViewWithLocation(superView: superView, location: location)

        case .changed:
            guard let movingImageView = movingImageView,
                let displayView = movingImageView.superview else {
                    return
            }

            let newHeight = movingImageView.frame.height * sender.scale
            let newWidth = movingImageView.frame.width * sender.scale

            var actualScale = sender.scale
            if newHeight < displayView.frame.height || newWidth < displayView.frame.width {
                actualScale = 1.0
            }

            movingImageView.frame = CGRect(
                x: movingImageView.frame.origin.x,
                y: movingImageView.frame.origin.y,
                width: movingImageView.frame.width * actualScale,
                height: movingImageView.frame.height * actualScale
            )
            movingImageView.center = displayView.convert(displayView.center, from: displayView.superview)
            sender.scale = 1.0

        case .ended:
            movingImageView = nil

        default:
            return
        }
    }
}

// Extension of helper function of gesture handlers
extension PhotoModifierController {

    // Get a view with a location
    private func getViewWithLocation(superView: UIView?, location: CGPoint) -> UIView? {
        return addedImageViews.first { $0.frame.contains(location) }?.subviews.first
    }

    // Swap two images from two ImageViews, then scale them to fit
    private func swapImage(view1: UIImageView, view2: UIImageView) {
        guard let superView1 = view1.superview as? UIImageView,
            let superView2 = view2.superview as? UIImageView else {
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

        if let index1 = addedImageViews.index(of: superView1),
            let index2 = addedImageViews.index(of: superView2) {
            let temp = selectedImages[index1]
            selectedImages[index1] = selectedImages[index2]
            selectedImages[index2] = temp
        }
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

    // Get the number of images allowed in this layout
    func getLayoutImageCount(index: Int) -> Int {
        if let count = storedLayout.getLayout(index)?.count {
            return count - 1
        } else {
            return 0
        }
    }

    // Import images for this layout.
    func importImagesForLayout(images: [UIImage], layoutIndex: Int) {
        guard let originalPhoto = shareState?.originalPhoto else {
            return
        }

        selectedImages = images
        selectedImages.append(originalPhoto)
        let curIndexPath = IndexPath(item: layoutIndex, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedLayoutIndex, 0), section: 0)
        selectedLayoutIndex = layoutIndex
        selectedStickerIndex = 0

        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)
        applyLayout(index: layoutIndex)

        // If there is a filter currently selected, update all the photos with filter.
        if selectedFilterIndex > 0 {
            updateLayoutWithFilter()
        }
    }
}
