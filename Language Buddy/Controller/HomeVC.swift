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
    
    private let time = Date()
    private let formatter = DateFormatter()
    private var availabilityArray : [Availability] = []

    let imageCache = NSCache<AnyObject, AnyObject>()
<<<<<<< HEAD
    
    let firebaseManager = FirebaseManager.shared
    let locationManager = LocationManager.shared
    
    var homeCellViewModel = HomeCellViewModel()
=======
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location Manager Setup
        locationManager.managerSetup()
        locationManager.locationManagerDelegate = self
        
        // Table View Setup
        tableView.delegate = self
        tableView.dataSource = self
        homeCellViewModel.homeCellViewModelDelegate = self
        homeCellViewModel.loadAvailability()
        tableView.rowHeight = 200
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        
        // Nib Setup
        tableView.register(UINib(nibName: "AvailabilityCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
<<<<<<< HEAD
=======
        
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        toDetails.isEnabled = false
        toMap.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
<<<<<<< HEAD
        let locationAuthStatus = locationManager.getAuthStatus()
        switch locationAuthStatus {
        case .notDetermined:
            locationManager.requestAuth()
        case .restricted:
            break
        case .denied:
            locationManager.requestAuth()
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .authorized:
            break
=======
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
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.toDetails {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.location = locationManager.getLocation()
            destinationVC.delegate = self
        }
        else if segue.identifier == K.toComments {
            if let sender = sender as? IndexPath {
                let destinationVC = segue.destination as! CommentsVC
                destinationVC.availability = availabilityArray[sender.row]
            }
        }
        else if segue.identifier == K.toMap {
            let destinationVC = segue.destination as! MapVC
            destinationVC.location = locationManager.getLocation()
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
        
        if toDetails.isEnabled && toMap.isEnabled {
            // Location
            let cellLocation = CLLocation(latitude: (availabilityArray[indexPath.row].latitude), longitude: availabilityArray[indexPath.row].longitude)
            let location = locationManager.getLocation()
            let distance = location.distance(from: cellLocation)
            
            // Cell Details
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! AvailabilityCell
            cell.userLabel.text = availabilityArray[indexPath.row].username
            cell.languageLabel.text = availabilityArray[indexPath.row].targetLanguage
            cell.profileImage.image = UIImage(systemName: "person")
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/5
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
            
            if availabilityArray[indexPath.row].username != "Anonymous" {
                if let cachedImage = imageCache.object(forKey: availabilityArray[indexPath.row].email as NSString) as? UIImage {
                    cell.profileImage.image = cachedImage
                    return cell
                }
<<<<<<< HEAD
=======
                print(availabilityArray[indexPath.row].username)
                print(indexPath.row)
                print("changing to not anon")
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
                firebaseManager.loadImage(user: availabilityArray[indexPath.row].email) { img in
                    DispatchQueue.main.async {
                        self.imageCache.setObject(img, forKey: self.availabilityArray[indexPath.row].email as NSString)
                        cell.profileImage.image = img
                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/5
                    }
                }
            }
<<<<<<< HEAD
=======
            
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Please enable location services to use features"
            return cell
        }
    }
    
<<<<<<< HEAD
=======
    
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if tableView.cellForRow(at: indexPath) is AvailabilityCell {
                    tableView.deselectRow(at: indexPath, animated: true)
                    openmaps(latitude: availabilityArray[indexPath.row].latitude, longitude: availabilityArray[indexPath.row].longitude)
                } else {
                    locationManager.requestAuth()
                }
            }
        }
    }
    
    /// Opens Apple Maps During Long Press
    /// - Parameters:
    ///   - latitude: The poster's latitude location
    ///   - longitude: The poster's longitude location
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

<<<<<<< HEAD
//MARK: - Protocols
extension HomeVC : isAbleToReceiveData {
    func pass(availability: Availability) {
        homeCellViewModel.addAvailability(availability: availability) {
        }
    }
}

//MARK: - LocationManager Delegate
extension HomeVC: LocationManagerDelegate {
    func didChangeAuthorization(manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            toMap.isEnabled = false
            toDetails.isEnabled = false
        case .restricted:
            toMap.isEnabled = false
            toDetails.isEnabled = false
        case .denied:
            toMap.isEnabled = false
            toDetails.isEnabled = false
        case .authorizedAlways:
            toMap.isEnabled = true
            toDetails.isEnabled = true
        case .authorizedWhenInUse:
            toMap.isEnabled = true
            toDetails.isEnabled = true
        case .authorized:
            toMap.isEnabled = true
            toDetails.isEnabled = true
=======
//MARK: - CLLocationManagerDelegate
extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            self.location = location
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            manager.stopUpdatingLocation()
            toDetails.isEnabled = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .denied {
            toDetails.isEnabled = true
        } else {
            toDetails.isEnabled = false
>>>>>>> 37bb767f6a67122252c62e19361220fdca2fa91b
        }
    }
}

extension HomeVC: HomeCellViewModelDelegate {
    func didFinishFetchingAvailability(availabilities: [Availability]) {
        availabilityArray = availabilities
        tableView.reloadData()
    }
}
