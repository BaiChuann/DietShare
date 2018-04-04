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

    var foodImage: UIImage?
    var selectedImages: [UIImage]?
    var selectedLayoutType: Int?
    var selectedLayout: CollageLayout?

    var movingImageView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

        // prepare for data for stickers and layout
        for i in 1...5 {
            stickers.append(UIImage(named: "sticker-\(i)"))
            layout.append(UIImage(named: "layout-\(i)"))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

        /*let photoSelector = AppStoryboard.share.instance.instantiateViewController(withIdentifier: layoutPhotoSelectorIdentifier)
        navigationController?.present(photoSelector, animated: true, completion: nil)*/

        self.performSegue(withIdentifier: "toLayoutSelection", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLayoutSelection" {
            if let toViewController = segue.destination as? LayoutPhotoSelectorController {
                toViewController.layoutType = selectedLayoutType
            }
        }
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
            return
        case PhotoOptionType.layout.rawValue:
            onLayoutSelected(index: indexPath.item)
        default:
            return
        }
    }
}

extension PhotoModifierController {
    private func applyLayout() {
        guard let selectedImages = selectedImages, let layoutType = selectedLayoutType else {
            return
        }
        guard let layout = getLayout(type: layoutType) else {
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
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let superView = canvas.superview
        if sender.state == .began {
            let location = sender.location(in: superView)
            let movingView = superView?.subviews.first {
                $0.frame.contains(location) && $0 !== canvas
            }?.subviews.first
            movingImageView = movingView
            print(movingImageView?.frame)
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

    private func getLayout(type: Int) -> CollageLayout? {
        switch type {
        case 0:
            return CollageLayoutZero()
        case 1:
            return CollageLayoutOne()
        case 2:
            return CollageLayoutTwo()
        case 3:
            return CollageLayoutThree()
        default:
            print("error: layout not implemented")
            return nil
        }
    }
}
