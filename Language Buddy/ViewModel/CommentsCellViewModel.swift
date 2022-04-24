//
//  CommentsCellViewModel.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 4/24/22.
//

import Foundation

protocol CommentsCellViewModelDelegate {
    func didFinishFetchingComments(comments: [Comment])
}


struct CommentsCellViewModel {
    
    private let firebaseManager = FirebaseManager.shared
    
    var commentsCellViewModelDelegate : CommentsCellViewModelDelegate!
    
    //MARK: - Firebase Extension Functions
    func addComment(comment: Comment, document: String, completion: @escaping () -> ()) {
        firebaseManager.database.collection(document).addDocument(data: [
            K.FStore.email : comment.email,
            K.FStore.comment : comment.message,
            K.FStore.username : comment.username,
            K.FStore.date : Date().timeIntervalSince1970]) {error in
            if let e = error {
                print(e)
            } else {
                
            }
        }
    }
    
    func loadComment(document: String) {
        firebaseManager.database.collection(document)
            .order(by: K.FStore.date, descending: false)
            .addSnapshotListener { querySnapShot, error in
                var comments : [Comment] = []
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let username = data[K.FStore.username] as? String,
                           let message = data[K.FStore.comment] as? String,
                           let email = data[K.FStore.email] as? String {
                            let comment = Comment(email: email, username: username, message: message)
                            comments.append(comment)
                        }
                    }
                    commentsCellViewModelDelegate.didFinishFetchingComments(comments: comments)
                }
            }
    }
}
