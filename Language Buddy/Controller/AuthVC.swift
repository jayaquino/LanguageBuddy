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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let firebaseManager = FirebaseManager.shared
    
    @IBAction func registrationPressed(_ sender: UIButton) {
        if let safeEmail = emailTextField.text, let safePassword = passwordTextField.text {
            firebaseManager.register(email: safeEmail, password: safePassword)
            activityIndicator.startAnimating()
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let safeEmail = emailTextField.text, let safePassword = passwordTextField.text {
            firebaseManager.login(email: safeEmail, password: safePassword)
            activityIndicator.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.loginRegisterDelegate = self
    }
    
    //MARK: - Functions
    func presentErrorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
   
}

//MARK: - CanLoginRegisterUser Delegate Functions
extension AuthVC: CanLoginRegisterUser {
    func didLoginUser(username: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(identifier: "homeVC")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeVC)
    }
    
    func didRegisterUser(username: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: K.toUserInfo, sender: self)
        }
    }
    
    func didFailWithError(error: Error) {
        self.presentErrorAlert(errorMessage: error.localizedDescription)
        activityIndicator.stopAnimating()
    }
    
    func didFailWithOther(error: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.toUserInfo, sender: self)
        }
        activityIndicator.stopAnimating()
    }
}
