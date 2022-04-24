//
//  DetailsVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit
import CoreLocation
import Firebase

class DetailsVC: UIViewController {
    
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var departureTimeButton: UIButton!
    
    var location : CLLocation?
    var delegate : isAbleToReceiveData?
    let currentUser = CurrentUser()
    var address = String()
    var selectedDepartureDate = Double()
    
    //MARK: - IBActions
    @IBAction func addAvailabilityPressed(_ sender: UIButton) {
        
        if languageTextField.text != "" && locationTextField.text != "" && departureTimeButton.currentTitle != nil {
            
            if let location = locationTextField.text, let language = languageTextField.text, let geolocation = self.location, let email = Auth.auth().currentUser?.email {
    
                let geocoder = CLGeocoder()
                // Look up the location and pass it to the completion handler
                geocoder.reverseGeocodeLocation(geolocation,
                            completionHandler: { (placemarks, error) in
                    if error == nil {
                        if let firstAddress = placemarks?[0]{
                            self.address = firstAddress.thoroughfare ?? "empty"
                            self.delegate!.pass(availability: Availability(email: email, username: self.currentUser.username, targetLanguage: language, locationName: location, address: self.address, arrivalTime: Date().timeIntervalSince1970, departureTime: self.selectedDepartureDate, latitude: geolocation.coordinate.latitude, longitude: geolocation.coordinate.longitude, doc: nil))
                            DispatchQueue.main.async {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                })
            }
            } else {
                let alert = UIAlertController(title: "Complete All Fields", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                present(alert, animated: true)
            }
    }
    
    @IBAction func setTimeTapped(_ sender: UIButton) {
        // Views and Subviews
        let vc = UIViewController()
        let alert = UIAlertController(title: "Select Time", message: "", preferredStyle: .alert)
        let timePickerView = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 75))
        vc.preferredContentSize = CGSize(width: 250,height: 75)
        timePickerView.datePickerMode = .time
        timePickerView.largeContentTitle = "Arrival"
        timePickerView.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        vc.view.addSubview(timePickerView)
        
        // Constraints
        let horizontalConstraint = NSLayoutConstraint(item: timePickerView, attribute: .centerX, relatedBy: .equal, toItem: vc.view, attribute: .centerX, multiplier: 1, constant: 0)
        timePickerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addConstraint(horizontalConstraint)
        alert.setValue(vc, forKey: "contentViewController")
        
        let action = UIAlertAction(title: "Set", style: .default) { action in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm"
            let strDate = dateFormatter.string(from: timePickerView.date)
            sender.setTitle(String(strDate.split(separator: " ")[1]), for: .normal)
            
            self.selectedDepartureDate = timePickerView.date.timeIntervalSince1970
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    

}

