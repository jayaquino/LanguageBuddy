//
//  MapVC.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/26/22.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var location : CLLocation?
    var availabilityArray : [Availability]?
    private var annotations = [MKPointAnnotation()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let safeLocation = location {
            let viewRegion = MKCoordinateRegion(center: safeLocation.coordinate, latitudinalMeters: 7500, longitudinalMeters: 7500)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        if let safeAvailabilityArray = availabilityArray {
            for userAvailability in safeAvailabilityArray {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: userAvailability.latitude, longitude: userAvailability.longitude)
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }
    }
}
