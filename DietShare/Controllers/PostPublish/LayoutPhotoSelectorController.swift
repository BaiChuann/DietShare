//
//  LayoutPhotoSelectorController.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import DKImagePickerController

class LayoutPhotoSelectorController: UIViewController {
    @IBOutlet weak private var preview: UIView!
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    @IBOutlet weak private var previewCollectionView: UICollectionView!

    private let pickerController = DKImagePickerController()
    private let spacing = CGFloat(5)
    private let maxNumberOfImages = 4
    private let previewCellIdentifier = "LayoutPhotoPreviewCell"
    private var selectedAssets = [DKAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpPicker()
    }

    private func setUpUI() {
        nextButton.layer.cornerRadius = Constants.cornerRadius
    }

    private func setUpPicker() {
        pickerController.inline = true
        pickerController.sourceType = .photo
        pickerController.assetType = .allPhotos
        pickerController.UIDelegate = LayoutPhotoSelectorUIDelegate()
        pickerController.maxSelectableCount = maxNumberOfImages

        if let pickerView = pickerController.view {
            let startingY = backButton.frame.origin.y + backButton.bounds.height + spacing
            let height = preview.frame.origin.y - startingY
            pickerView.frame = CGRect(x: 0, y: startingY, width: view.bounds.width, height: height)
            pickerView.backgroundColor = Constants.photoLibraryBackgroundColor
            view.addSubview(pickerView)
        }

        pickerController.selectedChanged = { [unowned self] in
            print("selected changed")
            self.updateSelection()
        }
    }

    private func updateSelection() {
        selectedAssets = pickerController.selectedAssets
        previewCollectionView.reloadData()
    }

    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onNextButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LayoutPhotoSelectorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewCellIdentifier, for: indexPath)

        guard let previewCell = cell as? LayoutPhotoPreviewCell else {
            return cell
        }

        let asset = selectedAssets[indexPath.item]
        asset.fetchOriginalImage(true) { image, _ in
            if let image = image {
                previewCell.setImage(image)
            }
        }

        return previewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = previewCollectionView.bounds.height
        return CGSize(width: size, height: size)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
}
