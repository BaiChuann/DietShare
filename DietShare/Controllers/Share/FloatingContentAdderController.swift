//
//  FloatingContentAdderControllerViewController.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import Presentr

protocol FloatingContentAdderDelegate: class {
    func getSelectedFont() -> String
    func setTextValues(text: String?, color: UIColor?, size: CGFloat?)
}

class FloatingContentAdderController: UIViewController {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textPreviewCollectionView: UICollectionView!

    var shareState: ShareState?
    
    private var fonts = [String]()
    private let textCellIdentifier = "TextPreviewCell"
    private let optionCellMaxHeight: CGFloat = 100
    private var selectedFontIndex: Int?
    private var text: String?
    private var textColor: UIColor?
    private var textSize: CGFloat?
    private lazy var floatingTextInputController: FloatingTextInputController = {
        let controller = FloatingTextInputController(nibName: "FloatingTextInputPopup", bundle: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        fonts = [
            "Verdana",
            "ChalkboardSE-Regular",
            "HelveticaNeue-Light",
            "GillSans-BoldItalic",
            "MarkerFelt-Thin",
            "Noteworthy-Bold",
            "Menlo-Regular"
        ]
    }

    override func viewWillLayoutSubviews() {
        if textPreviewCollectionView.frame.height > optionCellMaxHeight,
            let layout = textPreviewCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            textPreviewCollectionView.reloadData()
        }
    }

    private func setUpUI() {
        imageView.image = shareState?.modifiedPhoto ?? shareState?.originalPhoto

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func onFontSelected(index: Int) {
        print("font \(index) selected")
        selectedFontIndex = index
        let popUp = Presentr(presentationType: .bottomHalf)
        popUp.shouldIgnoreTapOutsideContext = true
        popUp.roundCorners = true
        customPresentViewController(popUp, viewController: floatingTextInputController, animated: true, completion: nil)
    }
}

extension FloatingContentAdderController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textCellIdentifier, for: indexPath)

        guard let textPreviewCell = cell as? TextPreviewCell else {
            return cell
        }

        textPreviewCell.setFont(fonts[indexPath.item])

        return textPreviewCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onFontSelected(index: indexPath.item)
    }
}

extension FloatingContentAdderController: FloatingContentAdderDelegate {
    func getSelectedFont() -> String {
        return fonts[selectedFontIndex ?? 0]
    }

    func setTextValues(text: String?, color: UIColor?, size: CGFloat?) {
        print("Setting text: \(text ?? ""), color: \(color ?? UIColor.white), size: \(size ?? 20)")
        self.text = text
        self.textColor = color
        self.textSize = size
    }
}
