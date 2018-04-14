//
//  ProfileEditor.swift
//  DietShare
//
//  Created by baichuan on 13/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import TGCameraViewController

class ProfileEditor: UIViewController {
    
    @IBOutlet weak private var userPhoto: UIButton!
    @IBOutlet weak private var table: UITableView!
    private var attributes: [String] = []
    var photo: UIImage!
    var data: [String] = []
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)))
        backButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
        userPhoto.setImage(photo, for: .normal)
        attributes = ["User Name", "Description"]
        data = ["Bai Chuan", "eat less eat healthy"]
        TGCameraColor.setTint(Constants.themeColor)
        TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: false)
        TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditField" {
            if let destinationVC = segue.destination as? EditFieldController {
                guard let session = table.indexPathForSelectedRow?.item else {
                    return
                }
                destinationVC.session = session
                destinationVC.placeHolder = data[session]
            }
        }
    }
    @IBAction func onPhotoClicked(_ sender: Any) {
        openCamera()
    }
    
}

extension ProfileEditor: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
        //return attributes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as? EditCell  else {
            fatalError("The dequeued cell is not an instance of EditCell.")
        }
        let name = attributes[indexPath.item]
        cell.setAttribute(name)
        cell.selectionStyle = .none
        return cell
    }
}

extension ProfileEditor: TGCameraDelegate {
    func cameraDidCancel() {
        dismiss(animated: true)
    }
    func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
        dismiss(animated: true)
        setPhoto(image)
    }
    
    func cameraDidTakePhoto(_ image: UIImage!) {
        dismiss(animated: true)
        setPhoto(image)
    }
    
    // Optional
    func cameraWillTakePhoto() {
        print("cameraWillTakePhoto")
    }
    
    func cameraDidSavePhoto(atPath assetURL: URL!) {
        print("cameraDidSavePhotoAtPath: \(assetURL)")
    }
    
    func cameraDidSavePhotoWithError(_ error: Error!) {
        print("cameraDidSavePhotoWithError \(error)")
    }
    
    private func openCamera() {
        let navigationController = TGCameraNavigationController.new(with: self)
        present(navigationController!, animated: true)
    }
    
    private func setPhoto(_ pickedPhoto: UIImage) {
        userPhoto.setImage(pickedPhoto, for: .normal)
    }
}
