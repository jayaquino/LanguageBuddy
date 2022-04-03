//
//  CommentsVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit
import Firebase

class CommentsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    let currentUser = CurrentUser()
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if textField.text != "" {
            firebaseManager.addComment(comment: Comment(username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
            }
            textField.text = ""
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if let safeAvailability = availability?.doc {
            firebaseManager.deleteAvailability(documentID: safeAvailability)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    let firebaseManager = FirebaseManager()
    var availability : Availability?
    var comments : [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = Auth.auth().currentUser?.email, let availabilityEmail = availability?.email {
            if email == availabilityEmail {
                deleteButton.isEnabled = true
            } else {
                deleteButton.isEnabled = false
            }
        }
        title = availability?.locationName
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1);
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        textField.delegate = self
        firebaseManager.loadComment(document: (availability?.doc)!) { comments in
            self.comments = comments
            self.tableView.reloadData()
        }
    }
    
}


extension CommentsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        
        cell.usernameLabel.text = comments[(comments.count-1) - indexPath.row].username
        cell.messageLabel.text = comments[(comments.count-1) - indexPath.row].message
        cell.messageLabel.numberOfLines = 0
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}

extension CommentsVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firebaseManager.addComment(comment: Comment(username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
            print("comment added")
        }
        textField.text = ""
        view.endEditing(true)
        resignFirstResponder()
        return false
    }
}
