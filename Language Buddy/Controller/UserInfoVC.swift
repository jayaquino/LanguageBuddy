//
//  UserInfoVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import UIKit
import Firebase

class UserInfoVC: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let firebaseManager = FirebaseManager.shared
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let safeUsername = usernameTextField.text {
            if safeUsername.count <= 10 && safeUsername != "" {
                firebaseManager.setUserInfo(username: safeUsername)
            }
            activityIndicator.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.changeuserDelegate = self
    }
    
    //MARK: - Functions
    func presentErrorAlert(title: String, errorMessage: String) {
            let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
}

extension UserInfoVC: CanChangeUserInfo {
    func didChangeUserInfo(info: String) {
        activityIndicator.stopAnimating()
        self.firebaseManager.sendVerificationEmail()
        let alert = UIAlertController(title: "Verification", message: "Verification Email Sent", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: { alert in
            self.dismiss(animated: true)
        })
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func didFailWithError(error: Error) {
        activityIndicator.stopAnimating()
        self.presentErrorAlert(title: "Error", errorMessage: "Error Registering")
    }
}
