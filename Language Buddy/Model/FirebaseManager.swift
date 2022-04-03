//
//  FirebaseManager.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import Foundation
import Firebase
import UIKit

struct FirebaseManager {
    
    let database = Firestore.firestore()
    
    //MARK: - Authentication
    func login(email: String, password: String, sender: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            if error != nil {
                if let e = error {
                    presentErrorAlert(errorMessage: e.localizedDescription, sender: sender)
                }
            } else {
                if Auth.auth().currentUser?.displayName != nil {
                    if Auth.auth().currentUser!.isEmailVerified {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeVC = storyboard.instantiateViewController(identifier: "homeVC")
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeVC)
                    }
                    else {
                        let alert = UIAlertController(title: "Verification Email", message: "Please Verify Your Email", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .cancel , handler: nil)
                        alert.addAction(action)
                        sender.present(alert, animated: true)
                    }
                }
                else {
                    sender.performSegue(withIdentifier: K.toUserInfo, sender: sender)
                }
            }
        }
    }
    
    func setUserInfo(username: String,sender: UIViewController) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { error in
            if error != nil {
                if let e = error {
                    presentErrorAlert(errorMessage: e.localizedDescription, sender: sender)
                }
            }
        }
    }
    
    func register(email: String, password: String, sender: UIViewController) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                if let e = error {
                    presentErrorAlert(errorMessage: e.localizedDescription, sender: sender)
                }
            } else {
                DispatchQueue.main.async {
                    sender.performSegue(withIdentifier: K.toUserInfo, sender: self)
                }
            }
        }
    }
    
    func addAvailability(availability: Availability, completion: @escaping () -> ()) {
        database.collection(K.FStore.availabilityCollectionName).addDocument(data: [
            K.FStore.email : availability.email,
            K.FStore.username : availability.username,
            K.FStore.locationName : availability.locationName,
            K.FStore.address : availability.address,
            K.FStore.targetLanguage : availability.targetLanguage,
            K.FStore.arrivalTime : availability.arrivalTime,
            K.FStore.departureTime : availability.departureTime,
            K.FStore.latitude : availability.latitude,
            K.FStore.longitude : availability.longitude,
            K.FStore.date : Date().timeIntervalSince1970]) {error in
            if let e = error {
                print(e)
            } else {
                
            }
        }
    }
    
    func loadAvailability(completion: @escaping ([Availability]) -> ()) {
        database.collection(K.FStore.availabilityCollectionName)
            .order(by: K.FStore.date, descending: true)
            .addSnapshotListener { querySnapShot, error in
                var availabilities : [Availability] = []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let currentTime = Date().timeIntervalSince1970
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let email = data[K.FStore.email] as? String,
                            let username = data[K.FStore.username] as? String,
                           let location = data[K.FStore.locationName] as? String,
                           let address = data[K.FStore.address] as? String,
                           let language = data[K.FStore.targetLanguage] as? String,
                           let arrival = data[K.FStore.arrivalTime] as? Double,
                           let departure = data[K.FStore.departureTime] as? Double,
                           let latitude = data[K.FStore.latitude] as? Double,
                           let longitude = data[K.FStore.longitude] as? Double {
                            if departure < currentTime {
                                deleteAvailability(documentID: doc.documentID)
                            } else {
                                let availability = Availability(email: email, username: username, targetLanguage: language, locationName: location, address: address, arrivalTime: arrival, departureTime: departure, latitude: latitude, longitude: longitude, doc: doc.documentID)
                                availabilities.append(availability)
                            }
                        }
                    }
                    completion(availabilities)
                }
                if let e = error {
                    print(e)
                } else {
                    
                }
            }
    }
    
    func deleteAvailability(documentID: String) {
        print("deleting")
        database.collection(K.FStore.availabilityCollectionName).document(documentID).delete()
    }
    
    func addComment(comment: Comment, document: String, completion: @escaping () -> ()) {
        database.collection(document).addDocument(data: [
            K.FStore.comment : comment.message,
            K.FStore.username : comment.username,
            K.FStore.date : Date().timeIntervalSince1970]) {error in
            if let e = error {
                print(e)
            } else {
                
            }
        }
    }
    
    func loadComment(document: String, completion: @escaping ([Comment]) -> ()) {
        database.collection(document)
            .order(by: K.FStore.date, descending: false)
            .addSnapshotListener { querySnapShot, error in
                var comments : [Comment] = []
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let username = data[K.FStore.username] as? String,
                           let message = data[K.FStore.comment] as? String {
                            let comment = Comment(username: username, message: message)
                            comments.append(comment)
                        }
                    }
                    completion(comments)
                }
            }
    }
    
    func deleteUser(sender: UIViewController) {
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let e = error {
              let alert = UIAlertController(title: "Error Deleting Profile", message: e.localizedDescription, preferredStyle: .alert)
              let action = UIAlertAction(title: "Ok", style: .cancel , handler: nil)
              alert.addAction(action)
              sender.present(alert, animated: true)
          } else {
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
              let authVC = storyboard.instantiateViewController(identifier: "authVC")
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(authVC)
          }
        }
    }
    
    
    //MARK: - Getter
    func getUserID() -> String {
        if let username = Auth.auth().currentUser?.displayName {
            return username
        } else {
            print("No username")
            return ""
        }
    }
    
    //MARK: - Functions
    func presentErrorAlert(errorMessage: String, sender: UIViewController) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        sender.present(alert, animated: true)
    }
}
