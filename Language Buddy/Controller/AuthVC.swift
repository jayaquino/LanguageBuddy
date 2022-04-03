//
//  AuthVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import UIKit
import Firebase

class AuthVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebaseManager = FirebaseManager()
    
    @IBAction func registrationPressed(_ sender: UIButton) {
        if let safeEmail = emailTextField.text, let safePassword = passwordTextField.text {
            firebaseManager.register(email: safeEmail, password: safePassword, sender: self)
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let safeEmail = emailTextField.text, let safePassword = passwordTextField.text {
            firebaseManager.login(email: safeEmail, password: safePassword, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
   
}
