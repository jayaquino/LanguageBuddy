//
//  ViewController.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseMessaging

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toDetails: UIBarButtonItem!
    @IBOutlet weak var toMap: UIBarButtonItem!
    
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
        tableView.rowHeight = 200
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        
        // Nib
        tableView.register(UINib(nibName: "AvailabilityCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        // UI Handling
        toMap.isEnabled = false
        toDetails.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                }
            }
            self.availabilityArray = availabilitiesVariable
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.toDetails {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.delegate = self
            destinationVC.location = location
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
        if tableView.cellForRow(at: indexPath) is AvailabilityCell {
            performSegue(withIdentifier: "toComments", sender: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDetails.isEnabled {
            return availabilityArray.count
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if toDetails.isEnabled {
            // Location
            let cellLocation = CLLocation(latitude: (availabilityArray[indexPath.row].latitude), longitude: availabilityArray[indexPath.row].longitude)
            let distance = self.location.distance(from: cellLocation)
            
            // Cell Details
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! AvailabilityCell
            cell.userLabel.text = availabilityArray[indexPath.row].username
            cell.languageLabel.text = availabilityArray[indexPath.row].targetLanguage
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let t0 = formatter.string(from:Date(timeIntervalSince1970: availabilityArray[indexPath.row].arrivalTime))
            let t1 = formatter.string(from: Date(timeIntervalSince1970: availabilityArray[indexPath.row].departureTime))
            let time = t0 + " - " + t1
            cell.timeLabel.text =  time
            cell.locationLabel.text = availabilityArray[indexPath.row].locationName
            cell.distanceLabel.text = String(round(CGFloat(distance)*10)/10) + " m"
            
            cell.languageLabel.numberOfLines = 0
            cell.userLabel.numberOfLines = 0
            cell.timeLabel.numberOfLines = 0
            
            cell.selectionStyle = .none
            
            firebaseManager.loadImage(user: availabilityArray[indexPath.row].email) { profileImage in
                cell.profileImage.image = profileImage
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
            }
            
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Please enable location services to use features"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(
            withDuration: 2.0,
            delay: 1.0 * Double(indexPath.row),
                        animations: {
                            cell.alpha = 1
                    })
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if tableView.cellForRow(at: indexPath) is AvailabilityCell {
                    tableView.deselectRow(at: indexPath, animated: true)
                    openmaps(latitude: availabilityArray[indexPath.row].latitude, longitude: availabilityArray[indexPath.row].longitude)
                }
            }
        }
    }
    
    func openmaps(latitude: Double, longitude: Double) {
        let latitude: CLLocationDegrees = Double(latitude)
        let longitude: CLLocationDegrees = Double(longitude)
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: options)
    }
}

//MARK: - CLLocationManagerDelegate
extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            self.location = location
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            loadData()
            toDetails.isEnabled = true
            toMap.isEnabled = true
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            toDetails.isEnabled = false
            toMap.isEnabled = false
        } else {
            toDetails.isEnabled = true
            toMap.isEnabled = true
        }
        tableView.reloadData()
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
