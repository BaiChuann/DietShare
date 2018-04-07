//
//  PhotoModifierController.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.

import UIKit
import DKImagePickerController

protocol PhotoModifierDelegate: class {
    func importImagesForLayout(images: [UIImage])
    func getLayoutImageCount() -> Int
}

enum PhotoOptionType: Int {
    case sticker = 0, layout, filter
}

class PhotoModifierController: UIViewController {
    @IBOutlet weak private var segmentControl: UISegmentedControl!
    @IBOutlet weak private var segmentIndicator: UIView!
    @IBOutlet weak private var photoOptionCollectionView: UICollectionView!
    @IBOutlet weak private var canvas: UIImageView!

    var originalPhoto = UIImage(named: "food-example-1")
    private let photoOptionCellIdentifier = "PhotoOptionCell"
    private let layoutPhotoSelectorIdentifier = "LayoutPhotoSelectorController"
    private let context = CIContext()
    private var stickerIcons = [UIImage?]()
    private var layoutIcons = [UIImage?]()
    private var filters = [String]()
    private let storedLayout = StoredLayout.shared
    private var selectedImages: [UIImage]?
    private var selectedLayoutIndex: Int = -1
    private var selectedFilterIndex: Int = -1
    private var movingImageView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        canvas.image = originalPhoto
        setUpUI()

        // prepare for data for stickers and layout
        for i in 1...5 {
            stickerIcons.append(UIImage(named: "sticker-\(i)"))
        }
        filters = [
            "No Filter",
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CILinearToSRGBToneCurve",
            "CISRGBToneCurveToLinear"
        ]

        layoutIcons = storedLayout.storedLayoutList.map { $0.iconImage }
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

    @objc
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.segmentIndicator.frame.origin.x = self.segmentControl.frame.origin.x + (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
        }

        photoOptionCollectionView.reloadData()
    }

    private func onLayoutSelected(index: Int) {
        let curIndexPath = IndexPath(item: index, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedFilterIndex, 0), section: 0)
        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)

        selectedLayoutIndex = index
        guard let photoSelector = AppStoryboard.share.instance.instantiateViewController(withIdentifier: layoutPhotoSelectorIdentifier) as? LayoutPhotoSelectorController else {
            print("error when showing layout photo selector")
            return
        }

        photoSelector.delegate = self
        navigationController?.present(photoSelector, animated: true, completion: nil)
    }

    private func onFilterSelected(index: Int) {
        let curIndexPath = IndexPath(item: index, section: 0)
        let prevIndexPath = IndexPath(item: max(selectedFilterIndex, 0), section: 0)
        updateCellSelectionStatus(curAt: curIndexPath, prevAt: prevIndexPath)

        selectedFilterIndex = index
        if index > 0 {
            let filterName = filters[selectedFilterIndex]
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
            optionImage = stickerIcons[indexPath.item]
        case PhotoOptionType.layout.rawValue:
            optionImage = layoutIcons[indexPath.item]
            photoOptionCell.isSelected = indexPath.item == selectedLayoutIndex
        case PhotoOptionType.filter.rawValue:
            optionImage = indexPath.item > 0 ? getFilteredImage(filter: filters[indexPath.item]) : originalPhoto
            photoOptionCell.isSelected = indexPath.item == selectedFilterIndex
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
        let maxSize: CGFloat = 100
        let size = min(maxSize, photoOptionCollectionView.frame.height)
        return CGSize(width: size, height: size)
    }
}

extension PhotoModifierController {
    private func applyLayout() {
        guard let selectedImages = selectedImages, let layout = storedLayout.get(selectedLayoutIndex) else {
            return
        }

        let imageViews = layout.getLayoutViews(frame: canvas.frame)
        zip(imageViews, selectedImages).forEach { imageView, selectedImage in
            imageView.clipsToBounds = true
            let subImageView = getFittedImageView(image: selectedImage, frame: imageView.frame)
            imageView.addSubview(subImageView)
            canvas.superview?.addSubview(imageView)
        }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        canvas.superview?.addGestureRecognizer(panGestureRecognizer)
    }

    // need to refactor
    // TODO: add swapping image
    @objc
    private func handlePan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        if sender.state == .began {
            let location = sender.location(in: superView)
            let movingView = superView?.subviews.first {
                $0.frame.contains(location) && $0 !== canvas
                }?.subviews.first
            movingImageView = movingView
            print(movingImageView?.frame ?? "Empty moving image view")
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

extension PhotoModifierController: PhotoModifierDelegate {
    func importImagesForLayout(images: [UIImage]) {
        selectedImages = images
        applyLayout()
    }

    func getLayoutImageCount() -> Int {
        if let layout = storedLayout.get(selectedLayoutIndex) {
            return layout.count
        } else {
            return 0
        }
    }
}
