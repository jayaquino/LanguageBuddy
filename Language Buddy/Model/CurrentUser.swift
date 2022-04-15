//
//  CurrentUser.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import Foundation
import FirebaseStorage
import Firebase
import UIKit

struct CurrentUser {
    private let defaults = UserDefaults.standard
    
    var email : String {
        if let email = Auth.auth().currentUser?.email {
            return email
        } else {
            return "Error in email"
        }
    }
    
    var username : String {
        if defaults.object(forKey: "anonymous") as? Bool ?? false == true {
            return "Anonymous"
        } else {
            if let username = Auth.auth().currentUser?.displayName {
                return username
            }
            else {return "Error in Username"}
        }
    }
    
    var profileImage : UIImage {
        var profileImg = UIImage()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let username = Auth.auth().currentUser?.email{
            let profilePhoto = storageRef.child("images/\(username).jpg")
            profilePhoto.getData(maxSize: 20000000) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    profileImg = UIImage(systemName: "person")!
                } else {
                    profileImg = UIImage(data: data!)!
                }
            }
        }
        return profileImg
    }
}
