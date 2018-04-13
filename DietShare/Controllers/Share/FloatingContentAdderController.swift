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
    func getSelectedLabelInfo() -> FloatingTextInfo?
    func addNewTextLabelInfo(text: String, color: UIColor, size: CGFloat, font: UIFont)
    func updateTextLabelInfo(text: String?, color: UIColor, size: CGFloat, font: UIFont)
}

class FloatingContentAdderController: UIViewController {
    @IBOutlet weak private var canvas: UIView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textPreviewCollectionView: UICollectionView!

    var shareState: ShareState?
    private var fonts = [String]()
    private let textCellIdentifier = "TextPreviewCell"
    private let optionCellMaxHeight: CGFloat = 100
    private var selectedFontIndex: Int?
    private var selectedLabelIndex: Int?
    private var text: String?
    private var textColor: UIColor?
    private var textSize: CGFloat?
    private var textLabels = [FloatingTextInfo]()
    private lazy var floatingTextInputController: FloatingTextInputController = {
        let controller = FloatingTextInputController(nibName: "FloatingTextInputPopup", bundle: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        shareState = ShareState()

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
        showInputPopup()
    }

    private func showInputPopup() {
        let popUp = Presentr(presentationType: .bottomHalf)
        popUp.shouldIgnoreTapOutsideContext = true
        popUp.roundCorners = true
        customPresentViewController(popUp, viewController: floatingTextInputController, animated: true, completion: nil)
    }

    private func addTextLabelView(_ textInfo: FloatingTextInfo) {
        textInfo.label.isUserInteractionEnabled = true
        textInfo.label.layer.borderColor = UIColor.red.cgColor
        textInfo.label.layer.borderWidth = 2
        textInfo.label.text = textInfo.text
        textInfo.label.textColor = textInfo.color
        textInfo.label.font = textInfo.font.withSize(textInfo.size)
        textInfo.label.textAlignment = .center
        textInfo.label.lineBreakMode = .byWordWrapping
        textInfo.label.numberOfLines = 0
        textInfo.label.sizeToFit()
        textInfo.label.center = imageView.center

        let tap = UITapGestureRecognizer(target: self, action: #selector(textLabelTapHandler(sender:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(textLabelPanHandler(sender:)))
        pan.maximumNumberOfTouches = 1
        textInfo.label.addGestureRecognizer(tap)
        textInfo.label.addGestureRecognizer(pan)

        canvas.addSubview(textInfo.label)
    }

    private func updateTextLabelView(_ textInfo: FloatingTextInfo) {
        textInfo.label.text = textInfo.text
        textInfo.label.font = textInfo.font.withSize(textInfo.size)
        textInfo.label.textColor = textInfo.color
        textInfo.label.sizeToFit()
    }

    private func removeTextLabel(at index: Int) {
        let label = textLabels[index].label
        label.removeFromSuperview()
        textLabels.remove(at: index)
    }

    @objc
    private func textLabelTapHandler(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }

        selectedLabelIndex = textLabels.index { $0.label == label }
        print("selected index is \(selectedLabelIndex)")
        showInputPopup()
    }

    @objc
    private func textLabelPanHandler(sender: UIPanGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }

        let location = sender.location(in: canvas)
        let labelHalfWidth = label.frame.width / 2
        let labelHalfHeight = label.frame.height / 2
        let xPos = min(imageView.frame.maxX - labelHalfWidth, max(location.x, labelHalfWidth))
        let yPos = min(imageView.frame.maxY - labelHalfHeight, max(location.y, labelHalfHeight))

        label.center = CGPoint(x: xPos, y: yPos)
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

    func getSelectedLabelInfo() -> FloatingTextInfo? {
        if let index = selectedLabelIndex {
            return textLabels[index]
        } else {
            return nil
        }
    }

    func addNewTextLabelInfo(text: String, color: UIColor, size: CGFloat, font: UIFont) {
        print("add new label with text: \(text), color: \(color), size: \(size)")
        let newTextInfo = FloatingTextInfo(text: text, color: color, font: font, size: size, label: UILabel())
        textLabels.append(newTextInfo)
        addTextLabelView(newTextInfo)
    }

    func updateTextLabelInfo(text: String?, color: UIColor, size: CGFloat, font: UIFont) {
        guard let labelIndex = selectedLabelIndex else {
            print("no selected label found")
            return
        }

        guard let nonEmptyText = text else {
            removeTextLabel(at: labelIndex)
            return
        }

        let textInfo = textLabels[labelIndex]
        textInfo.color = color
        textInfo.text = nonEmptyText
        textInfo.font = font
        textInfo.size = size

        print("update label with text: \(textInfo.text), color: \(textInfo.color), size: \(textInfo.size)")

        updateTextLabelView(textInfo)
    }
}
