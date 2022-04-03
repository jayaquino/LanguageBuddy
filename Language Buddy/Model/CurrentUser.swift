//
//  CurrentUser.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import Foundation
import Firebase

struct CurrentUser {
    private let defaults = UserDefaults.standard
    
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
}
