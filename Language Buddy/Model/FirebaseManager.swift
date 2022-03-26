//
//  FirebaseManager.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import Foundation
import Firebase

struct FirebaseManager {
    
    let database = Firestore.firestore()
    
    func addAvailability(availability: Availability, completion: @escaping () -> ()) {
        database.collection(K.FStore.availabilityCollectionName).addDocument(data: [
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
                let currentTime = Date()
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let location = data[K.FStore.locationName] as? String,
                           let address = data[K.FStore.address] as? String,
                           let language = data[K.FStore.targetLanguage] as? String,
                           let arrival = data[K.FStore.arrivalTime] as? String,
                           let departure = data[K.FStore.departureTime] as? String,
                           let latitude = data[K.FStore.latitude] as? Double,
                           let longitude = data[K.FStore.longitude] as? Double {
                            let checkTimeArray = departure.components(separatedBy: ":")
                            let checkTime = Calendar.current.date(bySettingHour: Int(checkTimeArray[0])!, minute: Int(checkTimeArray[1])!, second: 0, of: Date())!
                            if checkTime < currentTime {
                                print(checkTime)
                                print(currentTime)
                                deleteAvailability(documentID: doc.documentID)
                            } else {
                                let availability = Availability(targetLanguage: language, locationName: location, address: address, arrivalTime: arrival, departureTime: departure, latitude: latitude, longitude: longitude, doc: doc.documentID)
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
    
    func addComment(comment: String, document: String, completion: @escaping () -> ()) {
        database.collection(document).addDocument(data: [
            K.FStore.comment : comment,
            K.FStore.date : Date().timeIntervalSince1970]) {error in
            if let e = error {
                print(e)
            } else {
                
            }
        }
    }
    
    func loadComment(document: String, completion: @escaping ([String]) -> ()) {
        database.collection(document)
            .order(by: K.FStore.date, descending: false)
            .addSnapshotListener { querySnapShot, error in
                var comments : [String] = []
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let comment = data[K.FStore.comment] as? String {
                            comments.append(comment)
                        }
                    }
                    completion(comments)
                }
            }
    }
    
    
}
