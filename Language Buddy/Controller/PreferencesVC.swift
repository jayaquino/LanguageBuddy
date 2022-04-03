//
//  PreferencesVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import UIKit

class PreferencesVC: UIViewController {

    @IBOutlet weak var anonymousSwitch: UISwitch!
    
    let firebaseManager = FirebaseManager()
    
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
    }
}
