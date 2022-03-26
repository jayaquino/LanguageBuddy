//
//  DetailsVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/25/22.
//

import UIKit

class DetailsVC: UIViewController {

    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var arrivalTimeButton: UIButton!
    @IBOutlet weak var departureTimeButton: UIButton!
    
    var latitude : Double?
    var longitude : Double?
    var delegate : isAbleToReceiveData?
    

    
    //MARK: - IBActions
    @IBAction func addAvailabilityPressed(_ sender: UIButton) {
        
        if languageTextField.text != "" && locationTextField.text != "" && addressTextField.text != "" && arrivalTimeButton.currentTitle != nil && departureTimeButton.currentTitle != nil {
            if let location = locationTextField.text, let address = addressTextField.text, let language = languageTextField.text, let arrival = arrivalTimeButton.titleLabel?.text, let departure = departureTimeButton.titleLabel?.text {
                delegate!.pass(availability: Availability(targetLanguage: language, locationName: location, address: address, arrivalTime: arrival, departureTime: departure, latitude: latitude!, longitude: longitude!, doc: nil))
            }
            self.dismiss(animated: true)
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
            dateFormatter.dateFormat = "HH:mm"
            let strDate = dateFormatter.string(from: timePickerView.date)
            sender.setTitle(strDate, for: .normal)
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

