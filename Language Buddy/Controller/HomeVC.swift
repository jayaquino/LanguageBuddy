//
//  ViewController.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let locationManager = CLLocationManager()
    private let time = Date()
    private let formatter = DateFormatter()
    private var lat = Double()
    private var lon = Double()
    private var location = CLLocation()
    private let firebaseManager = FirebaseManager()
    private var availabilityArray : [Availability] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Location
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        // Firebase
        loadData()
    }
    
    func loadData(){
        
        firebaseManager.loadAvailability { availabilities in
            var availabilitiesVariable = availabilities
            for (i,availability) in availabilities.enumerated().reversed() {
                let cellLocation = CLLocation(latitude: (availability.latitude), longitude: availability.longitude)
                let distance = self.location.distance(from: cellLocation)
                if distance > 10000 {
                    availabilitiesVariable.remove(at: i)
                    print("removed since distance is \(distance)")
                }
            }
            self.availabilityArray = availabilitiesVariable
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.toDetails {
            print("arrived in VC")
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.delegate = self
            destinationVC.latitude = self.lat
            destinationVC.longitude = self.lon
        }
        else if segue.identifier == K.toComments {
            if let sender = sender as? IndexPath {
                let destinationVC = segue.destination as! CommentsVC
                destinationVC.availability = availabilityArray[sender.row]
            }
        }
        else if segue.identifier == K.toMap {
            let destinationVC = segue.destination as! MapVC
            destinationVC.location = self.location
            destinationVC.availabilityArray = self.availabilityArray
        }
        
    }
}

//MARK: - Table View Delegate and Data Source
extension HomeVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availabilityArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Location
        let cellLocation = CLLocation(latitude: (availabilityArray[indexPath.row].latitude), longitude: availabilityArray[indexPath.row].longitude)
        let distance = self.location.distance(from: cellLocation)
        
        // Cell Details
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        cell.textLabel?.text = "Language — " + availabilityArray[indexPath.row].targetLanguage + "\n" + "Location — "+availabilityArray[indexPath.row].locationName + "\n" + "Distance — \(round(distance*100)/100.0) m"
    
        cell.textLabel?.font = UIFont(name: "Gill Sans", size: 15)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}

//MARK: - CLLocationManagerDelegate
extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            self.location = location
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            locationManager.stopUpdatingLocation()
            loadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - Protocols
extension HomeVC : isAbleToReceiveData {
    func pass(availability: Availability) {
        firebaseManager.addAvailability(availability: availability) {
            
        }
    }
}
