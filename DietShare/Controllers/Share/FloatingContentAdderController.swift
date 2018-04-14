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
    private let deleteBannerHeight: CGFloat = 120
    private let textDeleteBanner = UIImageView()
    private let nutritionStickerView = NutritionSticker()
    private var selectedFontIndex: Int?
    private var selectedLabelIndex: Int?
    private var text: String?
    private var textColor: UIColor?
    private var textSize: CGFloat?
    private var textLabels = [FloatingTextInfo]()
    private var nutritionViewOriginalPos = CGPoint(x: 0, y: 0)
    private lazy var floatingTextInputController: FloatingTextInputController = {
        let controller = FloatingTextInputController(nibName: "FloatingTextInputPopup", bundle: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        shareState = ShareState()

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
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear, isDataInited: \(nutritionStickerView.isDataInitialised())")
        super.viewDidAppear(animated)
        
        guard let foodData = shareState?.food, !nutritionStickerView.isDataInitialised() else {
            return
        }
        
        nutritionStickerView.setData(food: foodData)
        
        let originalSize = CGSize(width: 200, height: 125)
        let sizeDelta = nutritionStickerView.getSizeDelta()
        nutritionStickerView.frame = CGRect(
            x: nutritionStickerView.frame.origin.x - sizeDelta.width / 2,
            y: nutritionStickerView.frame.origin.y - sizeDelta.height / 2,
            width: originalSize.width + sizeDelta.width,
            height: originalSize.height + sizeDelta.height
        )
        nutritionStickerView.updateLabelSize(with: sizeDelta)
        nutritionStickerView.center = CGPoint(x: imageView.center.x, y: imageView.center.y + nutritionStickerView.frame.height / 2)
        canvas.addSubview(nutritionStickerView)
        
        UIView.animate(withDuration: 0.3) {
            self.nutritionStickerView.alpha = 1
        }
    }

    private func setUpUI() {
        imageView.image = shareState?.modifiedPhoto ?? shareState?.originalPhoto

        let pan = UIPanGestureRecognizer(target: self, action: #selector(nutritionPanHandler(sender:)))
        pan.maximumNumberOfTouches = 1
        nutritionStickerView.addGestureRecognizer(pan)
        nutritionStickerView.alpha = 0

        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func onFontSelected(index: Int) {
        print("font \(index) selected")
        selectedFontIndex = index
        selectedLabelIndex = nil
        showInputPopup()
    }

    private func showInputPopup() {
        let popUp = Presentr(presentationType: .bottomHalf)
        popUp.shouldIgnoreTapOutsideContext = true
        popUp.roundCorners = true
        customPresentViewController(popUp, viewController: floatingTextInputController, animated: true, completion: nil)
    }
    
    private func calculateLabelSize(for label: UILabel) -> CGSize {
        var size = label.sizeThatFits(imageView.frame.size)
        if size.height > size.width && label.numberOfLines >= 2 {
            size.width = label.preferredMaxLayoutWidth
        }
        
        return size
    }

    private func addTextLabelView(_ textInfo: FloatingTextInfo) {
        textInfo.label.isUserInteractionEnabled = true
        
        // Enable to show the border of label, for dubugging purpose
//        textInfo.label.layer.borderColor = UIColor.red.cgColor
//        textInfo.label.layer.borderWidth = 2
        
        textInfo.label.text = textInfo.text
        textInfo.label.textColor = textInfo.color
        textInfo.label.font = textInfo.font.withSize(textInfo.size)
        textInfo.label.textAlignment = .center
        textInfo.label.lineBreakMode = .byWordWrapping
        textInfo.label.numberOfLines = 0
        textInfo.label.preferredMaxLayoutWidth = 0.75 * imageView.frame.width
        
        var size = calculateLabelSize(for: textInfo.label)
        textInfo.label.sizeToFit()
        
        size.width = min(imageView.frame.width, size.width)
        size.height = min(imageView.frame.height, size.height)
        textInfo.label.frame = CGRect(origin: imageView.center, size: size)
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
        var size = calculateLabelSize(for: textInfo.label)
        textInfo.label.frame = CGRect(origin: textInfo.label.frame.origin, size: size)

        if textInfo.label.frame.minX < 0
            || textInfo.label.frame.minY < 0
            || textInfo.label.frame.maxX > imageView.frame.width
            || textInfo.label.frame.maxY > imageView.frame.height {
            size.width = min(textInfo.label.center.x * 2, (imageView.frame.width - textInfo.label.center.x) * 2)
            size.height = min(textInfo.label.center.y * 2, (imageView.frame.height - textInfo.label.center.y) * 2)
            textInfo.label.frame = CGRect(origin: textInfo.label.frame.origin, size: size)
            textInfo.label.center = imageView.center
        }

        textInfo.label.sizeToFit()
    }

    private func removeTextLabel(at index: Int) {
        let label = textLabels[index].label
        label.removeFromSuperview()
        textLabels.remove(at: index)
        selectedLabelIndex = nil
    }
    
    private func getLabelIndex(for label: UILabel) -> Int? {
        return textLabels.index { $0.label == label }
    }

    @objc
    private func textLabelTapHandler(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }

        selectedLabelIndex = getLabelIndex(for: label)
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

        let navigationBarHeight = (navigationController?.navigationBar.frame.height) ?? CGFloat(0)
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let boundary = deleteBannerHeight - canvas.frame.origin.y - navigationBarHeight - statusBarHeight
        switch sender.state {
        case .began:
            selectedLabelIndex = getLabelIndex(for: label)
            updateDeleteBannerStatus(shouldHide: false, shouldHighlight: false, isInit: true)
        case .changed:
            updateDeleteBannerStatus(shouldHide: false, shouldHighlight: location.y < boundary)
        case .ended:
            if location.y < boundary, let index = selectedLabelIndex {
                removeTextLabel(at: index)
            }
            updateDeleteBannerStatus(shouldHide: true, shouldHighlight: false)
            selectedLabelIndex = nil
        default:
            return
        }
    }

    @objc
    private func nutritionPanHandler(sender: UIPanGestureRecognizer) {
        guard let nutritionView = sender.view else {
            return
        }

        switch sender.state {
        case .began:
            nutritionViewOriginalPos = nutritionView.frame.origin
        case .changed:
            let translation = sender.translation(in: canvas)
            nutritionView.frame.origin = CGPoint(
                x: max(0, min(nutritionViewOriginalPos.x + translation.x, imageView.frame.maxX - nutritionView.frame.width)),
                y: max(0, min(nutritionViewOriginalPos.y + translation.y, imageView.frame.maxY - nutritionView.frame.height))
            )
        default:
            return
        }
    }

    private func updateDeleteBannerStatus(shouldHide: Bool, shouldHighlight: Bool, isInit: Bool = false) {
        if isInit {
            let currentWindow = UIApplication.shared.keyWindow
            currentWindow?.addSubview(textDeleteBanner)
            textDeleteBanner.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
            textDeleteBanner.backgroundColor = Constants.themeColor
            textDeleteBanner.image = UIImage(named: "trash")
            textDeleteBanner.contentMode = .center
            textDeleteBanner.layer.cornerRadius = Constants.cornerRadius
            
            UIView.animate(withDuration: 0.3) {
                self.textDeleteBanner.frame = CGRect(
                    x: 0,
                    y: -Constants.cornerRadius,
                    width: self.view.frame.width,
                    height: self.deleteBannerHeight + Constants.cornerRadius
                )
            }
        }
        
        if shouldHide {
            UIView.animate(withDuration: 0.3, animations: {
                self.textDeleteBanner.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
            }, completion: { _ in
                self.textDeleteBanner.removeFromSuperview()
                return
            })
        }
        
        if shouldHighlight && !textDeleteBanner.isHighlighted {
            textDeleteBanner.isHighlighted = true
            UIView.animate(withDuration: 0.3) {
                self.textDeleteBanner.backgroundColor = hexToUIColor(hex: "FF4848")
            }
        } else if !shouldHighlight && textDeleteBanner.isHighlighted {
            textDeleteBanner.isHighlighted = false
            UIView.animate(withDuration: 0.3) {
                self.textDeleteBanner.backgroundColor = Constants.themeColor
            }
        }
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
