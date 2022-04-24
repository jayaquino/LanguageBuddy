//
//  HomeCellViewModel.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 4/15/22.
//

import UIKit
import CoreLocation

protocol HomeCellViewModelDelegate {
    func didFinishFetchingAvailability(availabilities: [Availability])
}

struct HomeCellViewModel {
    
    private let firebaseManager = FirebaseManager.shared
    
    var homeCellViewModelDelegate : HomeCellViewModelDelegate!
    
    let locationArray : [CLLocation] = []
    let timeArray : [String] = []
    let distanceArray : [String] = []
    let imgArray : [UIImage] = []
    
    let imageCache = NSCache<AnyObject, AnyObject>()

//MARK: - Firebase Extension Functions
    func addAvailability(availability: Availability, completion: @escaping () -> ()) {
        firebaseManager.database.collection(K.FStore.availabilityCollectionName).addDocument(data: [
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
    
    func loadAvailability() {
        firebaseManager.database.collection(K.FStore.availabilityCollectionName)
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
                                firebaseManager.deleteData(documentID: doc.documentID, collectionName: K.FStore.availabilityCollectionName)
                            } else {
                                let availability = Availability(email: email, username: username, targetLanguage: language, locationName: location, address: address, arrivalTime: arrival, departureTime: departure, latitude: latitude, longitude: longitude, doc: doc.documentID)
                                availabilities.append(availability)
                            }
                        }
                    }
                    self.homeCellViewModelDelegate.didFinishFetchingAvailability(availabilities: availabilities)
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
                 firebaseManager.loadImage(user: i.email) { img in
                     profileImgs.append(img)
                 }
             }
         }
         completion(profileImgs)
     }
    
}
