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


protocol CanLoginRegisterUser {
    func didLoginUser (username: String)
    func didRegisterUser(username: String)
    func didFailWithError (error: Error)
    func didFailWithOther (error: String)
}

protocol CanChangeUserInfo {
    func didChangeUserInfo (info: String)
    func didFailWithError (error: Error)
}

protocol CanFetchLoadData {
    func didFetchData (availability : Availability)
    func didLoadData (availabilities : [Availability])
    func didDeleteData (availability: Availability)
    func didFailWithError (error: Error)
    
}

public class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    private let currentUser = CurrentUser()
    
    var loginRegisterDelegate: CanLoginRegisterUser?
    var changeuserDelegate: CanChangeUserInfo?
    var dataDelegate: CanFetchLoadData?
    
    //MARK: - Authentication
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            if error != nil {
                guard let e = error else {return}
                print("error login")
                self.loginRegisterDelegate?.didFailWithError(error: e)
            } else {
                
                if Auth.auth().currentUser!.isEmailVerified {
                    print("a")
                    self.loginRegisterDelegate?.didLoginUser(username: email)
                }
                else {
                    print("b")
                    self.loginRegisterDelegate?.didFailWithOther(error: "Not Verified")
                }
                
            }
        }
    }
    
    func setUserInfo(username: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { error in
            if error != nil {
                guard let e = error else {return}
                self.changeuserDelegate?.didFailWithError(error: e)
            }
            else {
                self.changeuserDelegate?.didChangeUserInfo(info: username)
            }
        }
    }
    
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                guard let e = error else {return}
                self.loginRegisterDelegate?.didFailWithError(error: e)
            } else {
                self.loginRegisterDelegate?.didRegisterUser(username: email)
            }
        }
    }
    
    func sendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
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
    
    func deleteData(documentID: String, collectionName: String) {
        database.collection(collectionName).document(documentID).delete()
    }
    
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0.0
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
