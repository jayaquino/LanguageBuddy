//
//  FirebaseManager.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import Foundation
import Firebase
import UIKit
import FirebaseStorage

struct FirebaseManager {
    
    let database = Firestore.firestore()
    let currentUser = CurrentUser()
    
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
                var profilePictures : [UIImage] = []
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
    
    func loadAvailabilityProfileImg(availabilities: [Availability], completion: @escaping ([UIImage]) -> ()) {
        var profileImgs : [UIImage] = []
        for i in availabilities {
            if i.username == "Anonymous" {
                profileImgs.append(UIImage(systemName: "person")!)
            } else {
                loadImage(user: i.email) { img in
                    profileImgs.append(img)
                }
            }
        }
        completion(profileImgs)
    }
    
    func deleteAvailability(documentID: String) {
        database.collection(K.FStore.availabilityCollectionName).document(documentID).delete()
    }
    
    func addComment(comment: Comment, document: String, completion: @escaping () -> ()) {
        database.collection(document).addDocument(data: [
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
    
    func loadComment(document: String, completion: @escaping ([Comment]) -> ()) {
        database.collection(document)
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
    
    func getEmail() -> String {
        if let email = Auth.auth().currentUser?.email{
            return email
        } else {
            print("Error in getting email")
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
    
    //MARK: - Firebase Storage
    func uploadImage(img: UIImage) {
        print("uploading img")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImgResize = img.resizeWithPercent(percentage: 0.3)
        let profileImgData = profileImgResize!.jpeg(.low)
        let profilePhoto = storageRef.child("images/\(getEmail()).jpg")

       
        profilePhoto.putData(profileImgData!, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
              print(error?.localizedDescription)
            return
          }
        }
    
    }
    
    func loadImage(user: String,completion: @escaping (UIImage) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePhoto = storageRef.child("images/\(user).jpg")
        profilePhoto.getData(maxSize: 20000000) { data, error in
          if let error = error {
              print(error.localizedDescription)
          } else {
              if let image = UIImage(data: data!) {
              completion(image)
              }
          }
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0.001
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
            imageView.image = self
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            return result
        }
}
