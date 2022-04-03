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
    
    let firebaseManager = FirebaseManager()
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let safeUsername = usernameTextField.text {
            if safeUsername.count <= 10 && safeUsername != "" {
                firebaseManager.setUserInfo(username: safeUsername, sender: self)
                DispatchQueue.main.async {
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if error == nil {
                            let alert = UIAlertController(title: "Verification Email", message: "Sent", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .cancel) { action in
                                self.dismiss(animated: true)
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true)
                        } else {
                            print(error)
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Username is invalid", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
