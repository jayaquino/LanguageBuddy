//
//  CommentsVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class CommentsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    let currentUser = CurrentUser()
    var commentsCellViewModel = CommentsCellViewModel()
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if textField.text != "" {
<<<<<<< HEAD
            commentsCellViewModel.addComment(comment: Comment(email: currentUser.email, username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
=======
            firebaseManager.addComment(comment: Comment(email: currentUser.email, username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
            }
            textField.text = ""
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if let safeAvailability = availability?.doc {
            firebaseManager.deleteData(documentID: safeAvailability, collectionName: K.FStore.availabilityCollectionName)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    var availability : Availability?
    var comments : [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
<<<<<<< HEAD
        commentsCellViewModel.commentsCellViewModelDelegate = self
        
=======
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        if let email = Auth.auth().currentUser?.email, let availabilityEmail = availability?.email {
            if email == availabilityEmail {
                deleteButton.isEnabled = true
            } else {
                deleteButton.isEnabled = false
            }
        }
        title = availability?.locationName
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        textField.delegate = self
        commentsCellViewModel.loadComment(document: (availability?.doc)!)
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
        
        if comments[(comments.count-1) - indexPath.row].email == currentUser.email {
<<<<<<< HEAD
            cell.usernameLabel.backgroundColor = .systemBlue
=======
            cell.usernameLabel.backgroundColor = .systemPink
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        }
        
        return cell
    }
}

extension CommentsVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
<<<<<<< HEAD
        commentsCellViewModel.addComment(comment: Comment(email: currentUser.email, username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
=======
        firebaseManager.addComment(comment: Comment(email: currentUser.email, username: currentUser.username, message: textField.text!), document: (availability?.doc!)!) {
            print("comment added")
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        }
        textField.text = ""
        view.endEditing(true)
        resignFirstResponder()
        return false
    }
}

extension CommentsVC : CommentsCellViewModelDelegate {
    func didFinishFetchingComments(comments: [Comment]) {
        self.comments = comments
        tableView.reloadData()
    }
}
