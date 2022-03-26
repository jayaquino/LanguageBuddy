//
//  CommentsVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit

class CommentsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func sendPressed(_ sender: UIButton) {
        print("sending")
        firebaseManager.addComment(comment: textField.text!, document: (availability?.doc!)!) {
            print("comment added")
        }
        textField.text = ""
    }
    
    let firebaseManager = FirebaseManager()
    var availability : Availability?
    var comments : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = availability?.locationName
        tableView.dataSource = self
        textField.delegate = self
        firebaseManager.loadComment(document: (availability?.doc)!) { comments in
            self.comments = comments
            self.tableView.reloadData()
            print(comments)
        }
    }
    
}


extension CommentsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row]
        return cell
    }
}

extension CommentsVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firebaseManager.addComment(comment: textField.text!, document: (availability?.doc!)!) {
            print("comment added")
        }
        textField.text = ""
        view.endEditing(true)
        resignFirstResponder()
        return false
    }
}
