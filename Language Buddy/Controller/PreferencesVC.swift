//
//  PreferencesVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import UIKit

class PreferencesVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    
    let firebaseManager = FirebaseManager.shared

    var imagePicker = UIImagePickerController()
    
    @IBAction func anonymousSwitchPressed(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "anonymous")
    }
    
    @IBAction func deleteAccountPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Account Deletion", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete Account", style: .default) { action in
            self.firebaseManager.deleteUser(sender: self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert,animated: true)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        anonymousSwitch.isOn = defaults.object(forKey: "anonymous") as? Bool ?? false

        // Image View Gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        firebaseManager.loadImage(user: firebaseManager.getEmail()) { profileImage in
            self.imageView.image = profileImage
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
}

extension PreferencesVC : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] {
            imageView.image = img as? UIImage
            firebaseManager.uploadImage(img: imageView.image!)
        }
       
        picker.dismiss(animated: true)
    }
}


