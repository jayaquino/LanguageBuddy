//
//  LocationManager.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 4/15/22.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didChangeAuthorization(manager:CLLocationManager)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private var location: CLLocation?
    private var lat: Double?
    private var lon: Double?
    
    private var manager : CLLocationManager
    
    var locationManagerDelegate : LocationManagerDelegate!
    
    override init() {
        manager = CLLocationManager()
    }

    func managerSetup() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func requestAuth() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getAuthStatus() -> CLAuthorizationStatus {
        return manager.authorizationStatus
    }
    
    func getLocation() -> CLLocation{
        return location!
    }
    
    func getLat() -> Double {
        return lat!
    }
    
    func getLon() -> Double {
        return lon!
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            self.location = location
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            self.manager.startUpdatingLocation()
        }
        locationManagerDelegate.didChangeAuthorization(manager: manager)
    }
    
    
}
